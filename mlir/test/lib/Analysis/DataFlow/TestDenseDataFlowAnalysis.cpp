//===- TestDenseDataFlowAnalysis.cpp - Test dense data flow analysis ------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "TestDenseDataFlowAnalysis.h"
#include "mlir/Analysis/DataFlow/ConstantPropagationAnalysis.h"
#include "mlir/Analysis/DataFlow/DeadCodeAnalysis.h"
#include "mlir/Analysis/DataFlow/DenseAnalysis.h"
#include "mlir/Interfaces/SideEffectInterfaces.h"
#include "mlir/Pass/Pass.h"
#include <optional>

using namespace mlir;
using namespace mlir::dataflow;
using namespace mlir::dataflow::test;

namespace {

/// This lattice represents, for a given memory resource, the potential last
/// operations that modified the resource.
class LastModification : public AbstractDenseLattice,
                         public test::AccessLatticeBase {
public:
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(LastModification)

  using AbstractDenseLattice::AbstractDenseLattice;

  /// Join the last modifications.
  ChangeResult join(const AbstractDenseLattice &lattice) override {
    return AccessLatticeBase::merge(static_cast<test::AccessLatticeBase>(
        static_cast<const LastModification &>(lattice)));
  }

  void print(raw_ostream &os) const override {
    return AccessLatticeBase::print(os);
  }
};

class LastModifiedAnalysis : public DenseDataFlowAnalysis<LastModification> {
public:
  using DenseDataFlowAnalysis::DenseDataFlowAnalysis;

  /// Visit an operation. If the operation has no memory effects, then the state
  /// is propagated with no change. If the operation allocates a resource, then
  /// its reaching definitions is set to empty. If the operation writes to a
  /// resource, then its reaching definition is set to the written value.
  void visitOperation(Operation *op, const LastModification &before,
                      LastModification *after) override;

  /// At an entry point, the last modifications of all memory resources are
  /// unknown.
  void setToEntryState(LastModification *lattice) override {
    propagateIfChanged(lattice, lattice->reset());
  }
};
} // end anonymous namespace

void LastModifiedAnalysis::visitOperation(Operation *op,
                                          const LastModification &before,
                                          LastModification *after) {
  auto memory = dyn_cast<MemoryEffectOpInterface>(op);
  // If we can't reason about the memory effects, then conservatively assume we
  // can't deduce anything about the last modifications.
  if (!memory)
    return setToEntryState(after);

  SmallVector<MemoryEffects::EffectInstance> effects;
  memory.getEffects(effects);

  ChangeResult result = after->join(before);
  for (const auto &effect : effects) {
    Value value = effect.getValue();

    // If we see an effect on anything other than a value, assume we can't
    // deduce anything about the last modifications.
    if (!value)
      return setToEntryState(after);

    value = UnderlyingValueAnalysis::getMostUnderlyingValue(
        value, [&](Value value) {
          return getOrCreateFor<UnderlyingValueLattice>(op, value);
        });
    if (!value)
      return;

    // Nothing to do for reads.
    if (isa<MemoryEffects::Read>(effect.getEffect()))
      continue;

    result |= after->set(value, op);
  }
  propagateIfChanged(after, result);
}

namespace {
struct TestLastModifiedPass
    : public PassWrapper<TestLastModifiedPass, OperationPass<>> {
  MLIR_DEFINE_EXPLICIT_INTERNAL_INLINE_TYPE_ID(TestLastModifiedPass)

  StringRef getArgument() const override { return "test-last-modified"; }

  void runOnOperation() override {
    Operation *op = getOperation();

    DataFlowSolver solver;
    solver.load<DeadCodeAnalysis>();
    solver.load<SparseConstantPropagation>();
    solver.load<LastModifiedAnalysis>();
    solver.load<UnderlyingValueAnalysis>();
    if (failed(solver.initializeAndRun(op)))
      return signalPassFailure();

    raw_ostream &os = llvm::errs();

    op->walk([&](Operation *op) {
      auto tag = op->getAttrOfType<StringAttr>("tag");
      if (!tag)
        return;
      os << "test_tag: " << tag.getValue() << ":\n";
      const LastModification *lastMods =
          solver.lookupState<LastModification>(op);
      assert(lastMods && "expected a dense lattice");
      for (auto [index, operand] : llvm::enumerate(op->getOperands())) {
        os << " operand #" << index << "\n";
        Value value = UnderlyingValueAnalysis::getMostUnderlyingValue(
            operand, [&](Value value) {
              return solver.lookupState<UnderlyingValueLattice>(value);
            });
        assert(value && "expected an underlying value");
        if (std::optional<ArrayRef<Operation *>> lastMod =
                lastMods->getAdjacentAccess(value)) {
          for (Operation *lastModifier : *lastMod) {
            if (auto tagName =
                    lastModifier->getAttrOfType<StringAttr>("tag_name")) {
              os << "  - " << tagName.getValue() << "\n";
            } else {
              os << "  - " << lastModifier->getName() << "\n";
            }
          }
        } else {
          os << "  - <unknown>\n";
        }
      }
    });
  }
};
} // end anonymous namespace

namespace mlir {
namespace test {
void registerTestLastModifiedPass() {
  PassRegistration<TestLastModifiedPass>();
}
} // end namespace test
} // end namespace mlir
