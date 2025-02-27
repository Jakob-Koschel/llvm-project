//===-- MachineFunctionSplitter.cpp - Split machine functions //-----------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// \file
// Uses profile information to split out cold blocks.
//
// This pass splits out cold machine basic blocks from the parent function. This
// implementation leverages the basic block section framework. Blocks marked
// cold by this pass are grouped together in a separate section prefixed with
// ".text.unlikely.*". The linker can then group these together as a cold
// section. The split part of the function is a contiguous region identified by
// the symbol "foo.cold". Grouping all cold blocks across functions together
// decreases fragmentation and improves icache and itlb utilization. Note that
// the overall changes to the binary size are negligible; only a small number of
// additional jump instructions may be introduced.
//
// For the original RFC of this pass please see
// https://groups.google.com/d/msg/llvm-dev/RUegaMg-iqc/wFAVxa6fCgAJ
//===----------------------------------------------------------------------===//

#include "llvm/ADT/SmallVector.h"
#include "llvm/Analysis/BlockFrequencyInfo.h"
#include "llvm/Analysis/BranchProbabilityInfo.h"
#include "llvm/Analysis/EHUtils.h"
#include "llvm/Analysis/ProfileSummaryInfo.h"
#include "llvm/CodeGen/BasicBlockSectionUtils.h"
#include "llvm/CodeGen/MachineBasicBlock.h"
#include "llvm/CodeGen/MachineBlockFrequencyInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineModuleInfo.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/IR/Function.h"
#include "llvm/InitializePasses.h"
#include "llvm/Support/CommandLine.h"
#include <optional>

using namespace llvm;

// FIXME: This cutoff value is CPU dependent and should be moved to
// TargetTransformInfo once we consider enabling this on other platforms.
// The value is expressed as a ProfileSummaryInfo integer percentile cutoff.
// Defaults to 999950, i.e. all blocks colder than 99.995 percentile are split.
// The default was empirically determined to be optimal when considering cutoff
// values between 99%-ile to 100%-ile with respect to iTLB and icache metrics on
// Intel CPUs.
static cl::opt<unsigned>
    PercentileCutoff("mfs-psi-cutoff",
                     cl::desc("Percentile profile summary cutoff used to "
                              "determine cold blocks. Unused if set to zero."),
                     cl::init(999950), cl::Hidden);

static cl::opt<unsigned> ColdCountThreshold(
    "mfs-count-threshold",
    cl::desc(
        "Minimum number of times a block must be executed to be retained."),
    cl::init(1), cl::Hidden);

static cl::opt<bool> SplitAllEHCode(
    "mfs-split-ehcode",
    cl::desc("Splits all EH code and it's descendants by default."),
    cl::init(false), cl::Hidden);

namespace {

class MachineFunctionSplitter : public MachineFunctionPass {
public:
  static char ID;
  MachineFunctionSplitter() : MachineFunctionPass(ID) {
    initializeMachineFunctionSplitterPass(*PassRegistry::getPassRegistry());
  }

  StringRef getPassName() const override {
    return "Machine Function Splitter Transformation";
  }

  void getAnalysisUsage(AnalysisUsage &AU) const override;

  bool runOnMachineFunction(MachineFunction &F) override;
};
} // end anonymous namespace

/// setDescendantEHBlocksCold - This splits all EH pads and blocks reachable
/// only by EH pad as cold. This will help mark EH pads statically cold
/// instead of relying on profile data.
static void setDescendantEHBlocksCold(MachineFunction &MF) {
  DenseSet<MachineBasicBlock *> EHBlocks;
  computeEHOnlyBlocks(MF, EHBlocks);
  for (auto Block : EHBlocks) {
    Block->setSectionID(MBBSectionID::ColdSectionID);
  }
}

static void finishAdjustingBasicBlocksAndLandingPads(MachineFunction &MF) {
  auto Comparator = [](const MachineBasicBlock &X, const MachineBasicBlock &Y) {
    return X.getSectionID().Type < Y.getSectionID().Type;
  };
  llvm::sortBasicBlocksAndUpdateBranches(MF, Comparator);
  llvm::avoidZeroOffsetLandingPad(MF);
}

static bool isColdBlock(const MachineBasicBlock &MBB,
                        const MachineBlockFrequencyInfo *MBFI,
                        ProfileSummaryInfo *PSI, bool HasAccurateProfile) {
  std::optional<uint64_t> Count = MBFI->getBlockProfileCount(&MBB);
  // If using accurate profile, no count means cold.
  // If no accurate profile, no count means "do not judge
  // coldness".
  if (!Count)
    return HasAccurateProfile;

  if (PercentileCutoff > 0)
    return PSI->isColdCountNthPercentile(PercentileCutoff, *Count);
  return (*Count < ColdCountThreshold);
}

bool MachineFunctionSplitter::runOnMachineFunction(MachineFunction &MF) {
  // We target functions with profile data. Static information in the form
  // of exception handling code may be split to cold if user passes the
  // mfs-split-ehcode flag.
  bool UseProfileData = MF.getFunction().hasProfileData();
  if (!UseProfileData && !SplitAllEHCode)
    return false;

  // TODO: We don't split functions where a section attribute has been set
  // since the split part may not be placed in a contiguous region. It may also
  // be more beneficial to augment the linker to ensure contiguous layout of
  // split functions within the same section as specified by the attribute.
  if (MF.getFunction().hasSection() ||
      MF.getFunction().hasFnAttribute("implicit-section-name"))
    return false;

  // We don't want to proceed further for cold functions
  // or functions of unknown hotness. Lukewarm functions have no prefix.
  std::optional<StringRef> SectionPrefix = MF.getFunction().getSectionPrefix();
  if (SectionPrefix &&
      (*SectionPrefix == "unlikely" || *SectionPrefix == "unknown")) {
    return false;
  }

  // Renumbering blocks here preserves the order of the blocks as
  // sortBasicBlocksAndUpdateBranches uses the numeric identifier to sort
  // blocks. Preserving the order of blocks is essential to retaining decisions
  // made by prior passes such as MachineBlockPlacement.
  MF.RenumberBlocks();
  MF.setBBSectionsType(BasicBlockSection::Preset);

  MachineBlockFrequencyInfo *MBFI = nullptr;
  ProfileSummaryInfo *PSI = nullptr;
  // Whether this pass is using FSAFDO profile (not accurate) or IRPGO
  // (accurate). HasAccurateProfile is only used when UseProfileData is true,
  // but giving it a default value to silent any possible warning.
  bool HasAccurateProfile = false;
  if (UseProfileData) {
    MBFI = &getAnalysis<MachineBlockFrequencyInfo>();
    PSI = &getAnalysis<ProfileSummaryInfoWrapperPass>().getPSI();
    // "HasAccurateProfile" is false for FSAFDO, true when using IRPGO
    // (traditional instrumented FDO) or CSPGO profiles.
    HasAccurateProfile =
        PSI->hasInstrumentationProfile() || PSI->hasCSInstrumentationProfile();
    // If HasAccurateProfile is false, we only trust hot functions,
    // which have many samples, and consider them as split
    // candidates. On the other hand, if HasAccurateProfile (likeIRPGO), we
    // trust both cold and hot functions.
    if (!HasAccurateProfile && !PSI->isFunctionHotInCallGraph(&MF, *MBFI)) {
      // Split all EH code and it's descendant statically by default.
      if (SplitAllEHCode)
        setDescendantEHBlocksCold(MF);
      finishAdjustingBasicBlocksAndLandingPads(MF);
      return true;
    }
  }

  SmallVector<MachineBasicBlock *, 2> LandingPads;
  for (auto &MBB : MF) {
    if (MBB.isEntryBlock())
      continue;

    if (MBB.isEHPad())
      LandingPads.push_back(&MBB);
    else if (UseProfileData &&
             isColdBlock(MBB, MBFI, PSI, HasAccurateProfile) && !SplitAllEHCode)
      MBB.setSectionID(MBBSectionID::ColdSectionID);
  }

  // Split all EH code and it's descendant statically by default.
  if (SplitAllEHCode)
    setDescendantEHBlocksCold(MF);
  // We only split out eh pads if all of them are cold.
  else {
    // Here we have UseProfileData == true.
    bool HasHotLandingPads = false;
    for (const MachineBasicBlock *LP : LandingPads) {
      if (!isColdBlock(*LP, MBFI, PSI, HasAccurateProfile))
        HasHotLandingPads = true;
    }
    if (!HasHotLandingPads) {
      for (MachineBasicBlock *LP : LandingPads)
        LP->setSectionID(MBBSectionID::ColdSectionID);
    }
  }

  finishAdjustingBasicBlocksAndLandingPads(MF);
  return true;
}

void MachineFunctionSplitter::getAnalysisUsage(AnalysisUsage &AU) const {
  AU.addRequired<MachineModuleInfoWrapperPass>();
  AU.addRequired<MachineBlockFrequencyInfo>();
  AU.addRequired<ProfileSummaryInfoWrapperPass>();
}

char MachineFunctionSplitter::ID = 0;
INITIALIZE_PASS(MachineFunctionSplitter, "machine-function-splitter",
                "Split machine functions using profile information", false,
                false)

MachineFunctionPass *llvm::createMachineFunctionSplitterPass() {
  return new MachineFunctionSplitter();
}
