; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -march=amdgcn -mcpu=fiji -verify-machineinstrs < %s | FileCheck -check-prefixes=SDAG-VI %s
; RUN: llc -march=amdgcn -mcpu=gfx900 -verify-machineinstrs < %s | FileCheck -check-prefixes=SDAG-GFX9 %s
; RUN: llc -march=amdgcn -mcpu=gfx1101 -verify-machineinstrs < %s | FileCheck -check-prefixes=GFX11,SDAG-GFX11 %s

; RUN: llc -march=amdgcn -mcpu=fiji -verify-machineinstrs -global-isel < %s | FileCheck -check-prefixes=GISEL-VI %s
; RUN: llc -march=amdgcn -mcpu=gfx900 -verify-machineinstrs -global-isel < %s | FileCheck -check-prefixes=GISEL-GFX9 %s
; RUN: llc -march=amdgcn -mcpu=gfx1101 -verify-machineinstrs -global-isel < %s | FileCheck -check-prefixes=GFX11,GISEL-GFX11 %s

; <GFX9 has no V_SAT_PK, GFX9+ has V_SAT_PK, GFX11 has V_SAT_PK with t16

declare i16 @llvm.smin.i16(i16, i16)
declare i16 @llvm.smax.i16(i16, i16)

declare <2 x i16> @llvm.smin.v2i16(<2 x i16>, <2 x i16>)
declare <2 x i16> @llvm.smax.v2i16(<2 x i16>, <2 x i16>)

define <2 x i16> @basic_smax_smin(i16 %src0, i16 %src1) {
; SDAG-VI-LABEL: basic_smax_smin:
; SDAG-VI:       ; %bb.0:
; SDAG-VI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SDAG-VI-NEXT:    v_max_i16_e32 v0, 0, v0
; SDAG-VI-NEXT:    v_max_i16_e32 v1, 0, v1
; SDAG-VI-NEXT:    v_mov_b32_e32 v2, 0xff
; SDAG-VI-NEXT:    v_min_i16_sdwa v1, v1, v2 dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:DWORD
; SDAG-VI-NEXT:    v_min_i16_e32 v0, 0xff, v0
; SDAG-VI-NEXT:    v_or_b32_e32 v0, v0, v1
; SDAG-VI-NEXT:    s_setpc_b64 s[30:31]
;
; SDAG-GFX9-LABEL: basic_smax_smin:
; SDAG-GFX9:       ; %bb.0:
; SDAG-GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SDAG-GFX9-NEXT:    v_mov_b32_e32 v2, 0xff
; SDAG-GFX9-NEXT:    v_med3_i16 v0, v0, 0, v2
; SDAG-GFX9-NEXT:    v_med3_i16 v1, v1, 0, v2
; SDAG-GFX9-NEXT:    s_mov_b32 s4, 0x5040100
; SDAG-GFX9-NEXT:    v_perm_b32 v0, v1, v0, s4
; SDAG-GFX9-NEXT:    s_setpc_b64 s[30:31]
;
; SDAG-GFX11-LABEL: basic_smax_smin:
; SDAG-GFX11:       ; %bb.0:
; SDAG-GFX11-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SDAG-GFX11-NEXT:    v_med3_i16 v0, v0, 0, 0xff
; SDAG-GFX11-NEXT:    v_med3_i16 v1, v1, 0, 0xff
; SDAG-GFX11-NEXT:    s_delay_alu instid0(VALU_DEP_1)
; SDAG-GFX11-NEXT:    v_perm_b32 v0, v1, v0, 0x5040100
; SDAG-GFX11-NEXT:    s_setpc_b64 s[30:31]
;
; GISEL-VI-LABEL: basic_smax_smin:
; GISEL-VI:       ; %bb.0:
; GISEL-VI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GISEL-VI-NEXT:    v_max_i16_e32 v0, 0, v0
; GISEL-VI-NEXT:    v_max_i16_e32 v1, 0, v1
; GISEL-VI-NEXT:    v_mov_b32_e32 v2, 0xff
; GISEL-VI-NEXT:    v_min_i16_e32 v0, 0xff, v0
; GISEL-VI-NEXT:    v_min_i16_sdwa v1, v1, v2 dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:DWORD
; GISEL-VI-NEXT:    v_or_b32_e32 v0, v0, v1
; GISEL-VI-NEXT:    s_setpc_b64 s[30:31]
;
; GISEL-GFX9-LABEL: basic_smax_smin:
; GISEL-GFX9:       ; %bb.0:
; GISEL-GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GISEL-GFX9-NEXT:    v_mov_b32_e32 v2, 0xff
; GISEL-GFX9-NEXT:    v_med3_i16 v0, v0, 0, v2
; GISEL-GFX9-NEXT:    v_med3_i16 v1, v1, 0, v2
; GISEL-GFX9-NEXT:    v_and_b32_e32 v0, 0xffff, v0
; GISEL-GFX9-NEXT:    v_lshl_or_b32 v0, v1, 16, v0
; GISEL-GFX9-NEXT:    s_setpc_b64 s[30:31]
;
; GISEL-GFX11-LABEL: basic_smax_smin:
; GISEL-GFX11:       ; %bb.0:
; GISEL-GFX11-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GISEL-GFX11-NEXT:    v_med3_i16 v0, v0, 0, 0xff
; GISEL-GFX11-NEXT:    v_med3_i16 v1, v1, 0, 0xff
; GISEL-GFX11-NEXT:    s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)
; GISEL-GFX11-NEXT:    v_and_b32_e32 v0, 0xffff, v0
; GISEL-GFX11-NEXT:    v_lshl_or_b32 v0, v1, 16, v0
; GISEL-GFX11-NEXT:    s_setpc_b64 s[30:31]
  %src0.max = call i16 @llvm.smax.i16(i16 %src0, i16 0)
  %src0.clamp = call i16 @llvm.smin.i16(i16 %src0.max, i16 255)
  %src1.max = call i16 @llvm.smax.i16(i16 %src1, i16 0)
  %src1.clamp = call i16 @llvm.smin.i16(i16 %src1.max, i16 255)
  %insert.0 = insertelement <2 x i16> undef, i16 %src0.clamp, i32 0
  %vec = insertelement <2 x i16> %insert.0, i16 %src1.clamp, i32 1
  ret <2 x i16> %vec
}

; Check that we don't emit a VALU instruction for SGPR inputs.
define amdgpu_kernel void @basic_smax_smin_sgpr(ptr addrspace(1) %out, i32 inreg %src0ext, i32 inreg %src1ext) {
; SDAG-VI-LABEL: basic_smax_smin_sgpr:
; SDAG-VI:       ; %bb.0:
; SDAG-VI-NEXT:    s_load_dwordx4 s[0:3], s[0:1], 0x24
; SDAG-VI-NEXT:    v_mov_b32_e32 v0, 0xff
; SDAG-VI-NEXT:    s_waitcnt lgkmcnt(0)
; SDAG-VI-NEXT:    v_max_i16_e64 v1, s2, 0
; SDAG-VI-NEXT:    v_max_i16_e64 v2, s3, 0
; SDAG-VI-NEXT:    v_min_i16_sdwa v0, v2, v0 dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:DWORD
; SDAG-VI-NEXT:    v_min_i16_e32 v1, 0xff, v1
; SDAG-VI-NEXT:    v_or_b32_e32 v2, v1, v0
; SDAG-VI-NEXT:    v_mov_b32_e32 v0, s0
; SDAG-VI-NEXT:    v_mov_b32_e32 v1, s1
; SDAG-VI-NEXT:    flat_store_dword v[0:1], v2
; SDAG-VI-NEXT:    s_endpgm
;
; SDAG-GFX9-LABEL: basic_smax_smin_sgpr:
; SDAG-GFX9:       ; %bb.0:
; SDAG-GFX9-NEXT:    s_load_dwordx4 s[0:3], s[0:1], 0x24
; SDAG-GFX9-NEXT:    v_mov_b32_e32 v1, 0xff
; SDAG-GFX9-NEXT:    v_mov_b32_e32 v0, 0
; SDAG-GFX9-NEXT:    s_waitcnt lgkmcnt(0)
; SDAG-GFX9-NEXT:    v_med3_i16 v2, s2, 0, v1
; SDAG-GFX9-NEXT:    v_med3_i16 v1, s3, 0, v1
; SDAG-GFX9-NEXT:    v_and_b32_e32 v2, 0xffff, v2
; SDAG-GFX9-NEXT:    v_lshl_or_b32 v1, v1, 16, v2
; SDAG-GFX9-NEXT:    global_store_dword v0, v1, s[0:1]
; SDAG-GFX9-NEXT:    s_endpgm
;
; SDAG-GFX11-LABEL: basic_smax_smin_sgpr:
; SDAG-GFX11:       ; %bb.0:
; SDAG-GFX11-NEXT:    s_load_b128 s[0:3], s[0:1], 0x24
; SDAG-GFX11-NEXT:    v_mov_b32_e32 v2, 0
; SDAG-GFX11-NEXT:    s_waitcnt lgkmcnt(0)
; SDAG-GFX11-NEXT:    v_med3_i16 v0, s2, 0, 0xff
; SDAG-GFX11-NEXT:    v_med3_i16 v1, s3, 0, 0xff
; SDAG-GFX11-NEXT:    s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)
; SDAG-GFX11-NEXT:    v_and_b32_e32 v0, 0xffff, v0
; SDAG-GFX11-NEXT:    v_lshl_or_b32 v0, v1, 16, v0
; SDAG-GFX11-NEXT:    global_store_b32 v2, v0, s[0:1]
; SDAG-GFX11-NEXT:    s_sendmsg sendmsg(MSG_DEALLOC_VGPRS)
; SDAG-GFX11-NEXT:    s_endpgm
;
; GISEL-VI-LABEL: basic_smax_smin_sgpr:
; GISEL-VI:       ; %bb.0:
; GISEL-VI-NEXT:    s_load_dwordx4 s[0:3], s[0:1], 0x24
; GISEL-VI-NEXT:    s_sext_i32_i16 s4, 0
; GISEL-VI-NEXT:    s_sext_i32_i16 s5, 0xff
; GISEL-VI-NEXT:    s_waitcnt lgkmcnt(0)
; GISEL-VI-NEXT:    s_sext_i32_i16 s3, s3
; GISEL-VI-NEXT:    s_sext_i32_i16 s2, s2
; GISEL-VI-NEXT:    s_max_i32 s3, s3, s4
; GISEL-VI-NEXT:    s_max_i32 s2, s2, s4
; GISEL-VI-NEXT:    s_sext_i32_i16 s3, s3
; GISEL-VI-NEXT:    s_sext_i32_i16 s2, s2
; GISEL-VI-NEXT:    s_min_i32 s3, s3, s5
; GISEL-VI-NEXT:    s_min_i32 s2, s2, s5
; GISEL-VI-NEXT:    s_and_b32 s3, 0xffff, s3
; GISEL-VI-NEXT:    s_and_b32 s2, 0xffff, s2
; GISEL-VI-NEXT:    s_lshl_b32 s3, s3, 16
; GISEL-VI-NEXT:    s_or_b32 s2, s2, s3
; GISEL-VI-NEXT:    v_mov_b32_e32 v0, s0
; GISEL-VI-NEXT:    v_mov_b32_e32 v2, s2
; GISEL-VI-NEXT:    v_mov_b32_e32 v1, s1
; GISEL-VI-NEXT:    flat_store_dword v[0:1], v2
; GISEL-VI-NEXT:    s_endpgm
;
; GISEL-GFX9-LABEL: basic_smax_smin_sgpr:
; GISEL-GFX9:       ; %bb.0:
; GISEL-GFX9-NEXT:    s_load_dwordx4 s[0:3], s[0:1], 0x24
; GISEL-GFX9-NEXT:    s_sext_i32_i16 s4, 0
; GISEL-GFX9-NEXT:    s_sext_i32_i16 s5, 0xff
; GISEL-GFX9-NEXT:    v_mov_b32_e32 v1, 0
; GISEL-GFX9-NEXT:    s_waitcnt lgkmcnt(0)
; GISEL-GFX9-NEXT:    s_sext_i32_i16 s2, s2
; GISEL-GFX9-NEXT:    s_sext_i32_i16 s3, s3
; GISEL-GFX9-NEXT:    s_max_i32 s2, s2, s4
; GISEL-GFX9-NEXT:    s_max_i32 s3, s3, s4
; GISEL-GFX9-NEXT:    s_sext_i32_i16 s2, s2
; GISEL-GFX9-NEXT:    s_sext_i32_i16 s3, s3
; GISEL-GFX9-NEXT:    s_min_i32 s2, s2, s5
; GISEL-GFX9-NEXT:    s_min_i32 s3, s3, s5
; GISEL-GFX9-NEXT:    s_pack_ll_b32_b16 s2, s2, s3
; GISEL-GFX9-NEXT:    v_mov_b32_e32 v0, s2
; GISEL-GFX9-NEXT:    global_store_dword v1, v0, s[0:1]
; GISEL-GFX9-NEXT:    s_endpgm
;
; GISEL-GFX11-LABEL: basic_smax_smin_sgpr:
; GISEL-GFX11:       ; %bb.0:
; GISEL-GFX11-NEXT:    s_load_b128 s[0:3], s[0:1], 0x24
; GISEL-GFX11-NEXT:    s_sext_i32_i16 s4, 0
; GISEL-GFX11-NEXT:    s_sext_i32_i16 s5, 0xff
; GISEL-GFX11-NEXT:    v_mov_b32_e32 v1, 0
; GISEL-GFX11-NEXT:    s_waitcnt lgkmcnt(0)
; GISEL-GFX11-NEXT:    s_sext_i32_i16 s2, s2
; GISEL-GFX11-NEXT:    s_sext_i32_i16 s3, s3
; GISEL-GFX11-NEXT:    s_max_i32 s2, s2, s4
; GISEL-GFX11-NEXT:    s_max_i32 s3, s3, s4
; GISEL-GFX11-NEXT:    s_sext_i32_i16 s2, s2
; GISEL-GFX11-NEXT:    s_sext_i32_i16 s3, s3
; GISEL-GFX11-NEXT:    s_min_i32 s2, s2, s5
; GISEL-GFX11-NEXT:    s_min_i32 s3, s3, s5
; GISEL-GFX11-NEXT:    s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)
; GISEL-GFX11-NEXT:    s_pack_ll_b32_b16 s2, s2, s3
; GISEL-GFX11-NEXT:    v_mov_b32_e32 v0, s2
; GISEL-GFX11-NEXT:    global_store_b32 v1, v0, s[0:1]
; GISEL-GFX11-NEXT:    s_sendmsg sendmsg(MSG_DEALLOC_VGPRS)
; GISEL-GFX11-NEXT:    s_endpgm
  %src0 = trunc i32 %src0ext to i16
  %src1 = trunc i32 %src1ext to i16
  %src0.max = call i16 @llvm.smax.i16(i16 %src0, i16 0)
  %src0.clamp = call i16 @llvm.smin.i16(i16 %src0.max, i16 255)
  %src1.max = call i16 @llvm.smax.i16(i16 %src1, i16 0)
  %src1.clamp = call i16 @llvm.smin.i16(i16 %src1.max, i16 255)
  %insert.0 = insertelement <2 x i16> undef, i16 %src0.clamp, i32 0
  %vec = insertelement <2 x i16> %insert.0, i16 %src1.clamp, i32 1
  store <2 x i16> %vec, ptr addrspace(1) %out
  ret void
}

define <2 x i16> @basic_smin_smax(i16 %src0, i16 %src1) {
; SDAG-VI-LABEL: basic_smin_smax:
; SDAG-VI:       ; %bb.0:
; SDAG-VI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SDAG-VI-NEXT:    v_min_i16_e32 v0, 0xff, v0
; SDAG-VI-NEXT:    v_min_i16_e32 v1, 0xff, v1
; SDAG-VI-NEXT:    v_mov_b32_e32 v2, 0
; SDAG-VI-NEXT:    v_max_i16_sdwa v1, v1, v2 dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:DWORD
; SDAG-VI-NEXT:    v_max_i16_e32 v0, 0, v0
; SDAG-VI-NEXT:    v_or_b32_e32 v0, v0, v1
; SDAG-VI-NEXT:    s_setpc_b64 s[30:31]
;
; SDAG-GFX9-LABEL: basic_smin_smax:
; SDAG-GFX9:       ; %bb.0:
; SDAG-GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SDAG-GFX9-NEXT:    v_mov_b32_e32 v2, 0xff
; SDAG-GFX9-NEXT:    v_med3_i16 v0, v0, 0, v2
; SDAG-GFX9-NEXT:    v_med3_i16 v1, v1, 0, v2
; SDAG-GFX9-NEXT:    s_mov_b32 s4, 0x5040100
; SDAG-GFX9-NEXT:    v_perm_b32 v0, v1, v0, s4
; SDAG-GFX9-NEXT:    s_setpc_b64 s[30:31]
;
; SDAG-GFX11-LABEL: basic_smin_smax:
; SDAG-GFX11:       ; %bb.0:
; SDAG-GFX11-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SDAG-GFX11-NEXT:    v_med3_i16 v0, v0, 0, 0xff
; SDAG-GFX11-NEXT:    v_med3_i16 v1, v1, 0, 0xff
; SDAG-GFX11-NEXT:    s_delay_alu instid0(VALU_DEP_1)
; SDAG-GFX11-NEXT:    v_perm_b32 v0, v1, v0, 0x5040100
; SDAG-GFX11-NEXT:    s_setpc_b64 s[30:31]
;
; GISEL-VI-LABEL: basic_smin_smax:
; GISEL-VI:       ; %bb.0:
; GISEL-VI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GISEL-VI-NEXT:    v_min_i16_e32 v0, 0xff, v0
; GISEL-VI-NEXT:    v_min_i16_e32 v1, 0xff, v1
; GISEL-VI-NEXT:    v_mov_b32_e32 v2, 0
; GISEL-VI-NEXT:    v_max_i16_e32 v0, 0, v0
; GISEL-VI-NEXT:    v_max_i16_sdwa v1, v1, v2 dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:DWORD
; GISEL-VI-NEXT:    v_or_b32_e32 v0, v0, v1
; GISEL-VI-NEXT:    s_setpc_b64 s[30:31]
;
; GISEL-GFX9-LABEL: basic_smin_smax:
; GISEL-GFX9:       ; %bb.0:
; GISEL-GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GISEL-GFX9-NEXT:    v_mov_b32_e32 v2, 0xff
; GISEL-GFX9-NEXT:    v_med3_i16 v0, v0, 0, v2
; GISEL-GFX9-NEXT:    v_med3_i16 v1, v1, 0, v2
; GISEL-GFX9-NEXT:    v_and_b32_e32 v0, 0xffff, v0
; GISEL-GFX9-NEXT:    v_lshl_or_b32 v0, v1, 16, v0
; GISEL-GFX9-NEXT:    s_setpc_b64 s[30:31]
;
; GISEL-GFX11-LABEL: basic_smin_smax:
; GISEL-GFX11:       ; %bb.0:
; GISEL-GFX11-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GISEL-GFX11-NEXT:    v_med3_i16 v0, v0, 0, 0xff
; GISEL-GFX11-NEXT:    v_med3_i16 v1, v1, 0, 0xff
; GISEL-GFX11-NEXT:    s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)
; GISEL-GFX11-NEXT:    v_and_b32_e32 v0, 0xffff, v0
; GISEL-GFX11-NEXT:    v_lshl_or_b32 v0, v1, 16, v0
; GISEL-GFX11-NEXT:    s_setpc_b64 s[30:31]
  %src0.min = call i16 @llvm.smin.i16(i16 %src0, i16 255)
  %src0.clamp = call i16 @llvm.smax.i16(i16 %src0.min, i16 0)
  %src1.min = call i16 @llvm.smin.i16(i16 %src1, i16 255)
  %src1.clamp = call i16 @llvm.smax.i16(i16 %src1.min, i16 0)
  %insert.0 = insertelement <2 x i16> undef, i16 %src0.clamp, i32 0
  %vec = insertelement <2 x i16> %insert.0, i16 %src1.clamp, i32 1
  ret <2 x i16> %vec
}

define <2 x i16> @basic_smin_smax_combined(i16 %src0, i16 %src1) {
; SDAG-VI-LABEL: basic_smin_smax_combined:
; SDAG-VI:       ; %bb.0:
; SDAG-VI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SDAG-VI-NEXT:    v_min_i16_e32 v0, 0xff, v0
; SDAG-VI-NEXT:    v_max_i16_e32 v1, 0, v1
; SDAG-VI-NEXT:    v_mov_b32_e32 v2, 0xff
; SDAG-VI-NEXT:    v_min_i16_sdwa v1, v1, v2 dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:DWORD
; SDAG-VI-NEXT:    v_max_i16_e32 v0, 0, v0
; SDAG-VI-NEXT:    v_or_b32_e32 v0, v0, v1
; SDAG-VI-NEXT:    s_setpc_b64 s[30:31]
;
; SDAG-GFX9-LABEL: basic_smin_smax_combined:
; SDAG-GFX9:       ; %bb.0:
; SDAG-GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SDAG-GFX9-NEXT:    v_mov_b32_e32 v2, 0xff
; SDAG-GFX9-NEXT:    v_med3_i16 v0, v0, 0, v2
; SDAG-GFX9-NEXT:    v_med3_i16 v1, v1, 0, v2
; SDAG-GFX9-NEXT:    s_mov_b32 s4, 0x5040100
; SDAG-GFX9-NEXT:    v_perm_b32 v0, v1, v0, s4
; SDAG-GFX9-NEXT:    s_setpc_b64 s[30:31]
;
; SDAG-GFX11-LABEL: basic_smin_smax_combined:
; SDAG-GFX11:       ; %bb.0:
; SDAG-GFX11-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SDAG-GFX11-NEXT:    v_med3_i16 v0, v0, 0, 0xff
; SDAG-GFX11-NEXT:    v_med3_i16 v1, v1, 0, 0xff
; SDAG-GFX11-NEXT:    s_delay_alu instid0(VALU_DEP_1)
; SDAG-GFX11-NEXT:    v_perm_b32 v0, v1, v0, 0x5040100
; SDAG-GFX11-NEXT:    s_setpc_b64 s[30:31]
;
; GISEL-VI-LABEL: basic_smin_smax_combined:
; GISEL-VI:       ; %bb.0:
; GISEL-VI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GISEL-VI-NEXT:    v_min_i16_e32 v0, 0xff, v0
; GISEL-VI-NEXT:    v_max_i16_e32 v1, 0, v1
; GISEL-VI-NEXT:    v_mov_b32_e32 v2, 0xff
; GISEL-VI-NEXT:    v_max_i16_e32 v0, 0, v0
; GISEL-VI-NEXT:    v_min_i16_sdwa v1, v1, v2 dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:DWORD
; GISEL-VI-NEXT:    v_or_b32_e32 v0, v0, v1
; GISEL-VI-NEXT:    s_setpc_b64 s[30:31]
;
; GISEL-GFX9-LABEL: basic_smin_smax_combined:
; GISEL-GFX9:       ; %bb.0:
; GISEL-GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GISEL-GFX9-NEXT:    v_mov_b32_e32 v2, 0xff
; GISEL-GFX9-NEXT:    v_med3_i16 v0, v0, 0, v2
; GISEL-GFX9-NEXT:    v_med3_i16 v1, v1, 0, v2
; GISEL-GFX9-NEXT:    v_and_b32_e32 v0, 0xffff, v0
; GISEL-GFX9-NEXT:    v_lshl_or_b32 v0, v1, 16, v0
; GISEL-GFX9-NEXT:    s_setpc_b64 s[30:31]
;
; GISEL-GFX11-LABEL: basic_smin_smax_combined:
; GISEL-GFX11:       ; %bb.0:
; GISEL-GFX11-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GISEL-GFX11-NEXT:    v_med3_i16 v0, v0, 0, 0xff
; GISEL-GFX11-NEXT:    v_med3_i16 v1, v1, 0, 0xff
; GISEL-GFX11-NEXT:    s_delay_alu instid0(VALU_DEP_2) | instskip(NEXT) | instid1(VALU_DEP_1)
; GISEL-GFX11-NEXT:    v_and_b32_e32 v0, 0xffff, v0
; GISEL-GFX11-NEXT:    v_lshl_or_b32 v0, v1, 16, v0
; GISEL-GFX11-NEXT:    s_setpc_b64 s[30:31]
  %src0.min = call i16 @llvm.smin.i16(i16 %src0, i16 255)
  %src0.clamp = call i16 @llvm.smax.i16(i16 %src0.min, i16 0)
  %src1.max = call i16 @llvm.smax.i16(i16 %src1, i16 0)
  %src1.clamp = call i16 @llvm.smin.i16(i16 %src1.max, i16 255)
  %insert.0 = insertelement <2 x i16> undef, i16 %src0.clamp, i32 0
  %vec = insertelement <2 x i16> %insert.0, i16 %src1.clamp, i32 1
  ret <2 x i16> %vec
}

define <2 x i16> @vec_smax_smin(<2 x i16> %src) {
; SDAG-VI-LABEL: vec_smax_smin:
; SDAG-VI:       ; %bb.0:
; SDAG-VI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SDAG-VI-NEXT:    v_mov_b32_e32 v1, 0
; SDAG-VI-NEXT:    v_max_i16_sdwa v1, v0, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
; SDAG-VI-NEXT:    v_max_i16_e32 v0, 0, v0
; SDAG-VI-NEXT:    v_mov_b32_e32 v2, 0xff
; SDAG-VI-NEXT:    v_min_i16_e32 v0, 0xff, v0
; SDAG-VI-NEXT:    v_min_i16_sdwa v1, v1, v2 dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:DWORD
; SDAG-VI-NEXT:    v_or_b32_e32 v0, v0, v1
; SDAG-VI-NEXT:    s_setpc_b64 s[30:31]
;
; SDAG-GFX9-LABEL: vec_smax_smin:
; SDAG-GFX9:       ; %bb.0:
; SDAG-GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SDAG-GFX9-NEXT:    v_pk_max_i16 v0, v0, 0
; SDAG-GFX9-NEXT:    s_movk_i32 s4, 0xff
; SDAG-GFX9-NEXT:    v_pk_min_i16 v0, v0, s4 op_sel_hi:[1,0]
; SDAG-GFX9-NEXT:    s_setpc_b64 s[30:31]
;
; GFX11-LABEL: vec_smax_smin:
; GFX11:       ; %bb.0:
; GFX11-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX11-NEXT:    v_pk_max_i16 v0, v0, 0
; GFX11-NEXT:    s_delay_alu instid0(VALU_DEP_1)
; GFX11-NEXT:    v_pk_min_i16 v0, 0xff, v0 op_sel_hi:[0,1]
; GFX11-NEXT:    s_setpc_b64 s[30:31]
;
; GISEL-VI-LABEL: vec_smax_smin:
; GISEL-VI:       ; %bb.0:
; GISEL-VI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GISEL-VI-NEXT:    v_mov_b32_e32 v2, 0
; GISEL-VI-NEXT:    v_max_i16_e32 v1, 0, v0
; GISEL-VI-NEXT:    v_max_i16_sdwa v0, v0, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
; GISEL-VI-NEXT:    v_mov_b32_e32 v2, 0xff
; GISEL-VI-NEXT:    v_min_i16_e32 v1, 0xff, v1
; GISEL-VI-NEXT:    v_min_i16_sdwa v0, v0, v2 dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:DWORD
; GISEL-VI-NEXT:    v_or_b32_e32 v0, v1, v0
; GISEL-VI-NEXT:    s_setpc_b64 s[30:31]
;
; GISEL-GFX9-LABEL: vec_smax_smin:
; GISEL-GFX9:       ; %bb.0:
; GISEL-GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GISEL-GFX9-NEXT:    v_pk_max_i16 v0, v0, 0
; GISEL-GFX9-NEXT:    v_mov_b32_e32 v1, 0xff00ff
; GISEL-GFX9-NEXT:    v_pk_min_i16 v0, v0, v1
; GISEL-GFX9-NEXT:    s_setpc_b64 s[30:31]
  %src.max = call <2 x i16> @llvm.smax.v2i16(<2 x i16> %src, <2 x i16> <i16 0, i16 0>)
  %src.clamp = call <2 x i16> @llvm.smin.v2i16(<2 x i16> %src.max, <2 x i16> <i16 255, i16 255>)
  ret <2 x i16> %src.clamp
}

; Check that we don't emit a VALU instruction for SGPR inputs.
define amdgpu_kernel void @vec_smax_smin_sgpr(ptr addrspace(1) %out, <2 x i16> inreg %src) {
; SDAG-VI-LABEL: vec_smax_smin_sgpr:
; SDAG-VI:       ; %bb.0:
; SDAG-VI-NEXT:    s_load_dword s2, s[0:1], 0x2c
; SDAG-VI-NEXT:    s_load_dwordx2 s[0:1], s[0:1], 0x24
; SDAG-VI-NEXT:    v_mov_b32_e32 v0, 0xff
; SDAG-VI-NEXT:    s_waitcnt lgkmcnt(0)
; SDAG-VI-NEXT:    s_lshr_b32 s3, s2, 16
; SDAG-VI-NEXT:    v_max_i16_e64 v1, s2, 0
; SDAG-VI-NEXT:    v_max_i16_e64 v2, s3, 0
; SDAG-VI-NEXT:    v_min_i16_e32 v1, 0xff, v1
; SDAG-VI-NEXT:    v_min_i16_sdwa v0, v2, v0 dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:DWORD
; SDAG-VI-NEXT:    v_or_b32_e32 v2, v1, v0
; SDAG-VI-NEXT:    v_mov_b32_e32 v0, s0
; SDAG-VI-NEXT:    v_mov_b32_e32 v1, s1
; SDAG-VI-NEXT:    flat_store_dword v[0:1], v2
; SDAG-VI-NEXT:    s_endpgm
;
; SDAG-GFX9-LABEL: vec_smax_smin_sgpr:
; SDAG-GFX9:       ; %bb.0:
; SDAG-GFX9-NEXT:    s_load_dword s4, s[0:1], 0x2c
; SDAG-GFX9-NEXT:    s_load_dwordx2 s[2:3], s[0:1], 0x24
; SDAG-GFX9-NEXT:    s_movk_i32 s0, 0xff
; SDAG-GFX9-NEXT:    v_mov_b32_e32 v0, 0
; SDAG-GFX9-NEXT:    s_waitcnt lgkmcnt(0)
; SDAG-GFX9-NEXT:    v_pk_max_i16 v1, s4, 0
; SDAG-GFX9-NEXT:    v_pk_min_i16 v1, v1, s0 op_sel_hi:[1,0]
; SDAG-GFX9-NEXT:    global_store_dword v0, v1, s[2:3]
; SDAG-GFX9-NEXT:    s_endpgm
;
; SDAG-GFX11-LABEL: vec_smax_smin_sgpr:
; SDAG-GFX11:       ; %bb.0:
; SDAG-GFX11-NEXT:    s_clause 0x1
; SDAG-GFX11-NEXT:    s_load_b32 s2, s[0:1], 0x2c
; SDAG-GFX11-NEXT:    s_load_b64 s[0:1], s[0:1], 0x24
; SDAG-GFX11-NEXT:    v_mov_b32_e32 v1, 0
; SDAG-GFX11-NEXT:    s_waitcnt lgkmcnt(0)
; SDAG-GFX11-NEXT:    v_pk_max_i16 v0, s2, 0
; SDAG-GFX11-NEXT:    s_delay_alu instid0(VALU_DEP_1)
; SDAG-GFX11-NEXT:    v_pk_min_i16 v0, 0xff, v0 op_sel_hi:[0,1]
; SDAG-GFX11-NEXT:    global_store_b32 v1, v0, s[0:1]
; SDAG-GFX11-NEXT:    s_sendmsg sendmsg(MSG_DEALLOC_VGPRS)
; SDAG-GFX11-NEXT:    s_endpgm
;
; GISEL-VI-LABEL: vec_smax_smin_sgpr:
; GISEL-VI:       ; %bb.0:
; GISEL-VI-NEXT:    s_load_dword s2, s[0:1], 0x2c
; GISEL-VI-NEXT:    s_load_dwordx2 s[0:1], s[0:1], 0x24
; GISEL-VI-NEXT:    s_sext_i32_i16 s3, 0
; GISEL-VI-NEXT:    s_waitcnt lgkmcnt(0)
; GISEL-VI-NEXT:    s_lshr_b32 s4, s2, 16
; GISEL-VI-NEXT:    s_sext_i32_i16 s2, s2
; GISEL-VI-NEXT:    s_sext_i32_i16 s4, s4
; GISEL-VI-NEXT:    s_max_i32 s2, s2, s3
; GISEL-VI-NEXT:    s_max_i32 s3, s4, s3
; GISEL-VI-NEXT:    s_sext_i32_i16 s4, 0xff
; GISEL-VI-NEXT:    s_sext_i32_i16 s3, s3
; GISEL-VI-NEXT:    s_sext_i32_i16 s2, s2
; GISEL-VI-NEXT:    s_min_i32 s3, s3, s4
; GISEL-VI-NEXT:    s_min_i32 s2, s2, s4
; GISEL-VI-NEXT:    s_and_b32 s3, 0xffff, s3
; GISEL-VI-NEXT:    s_and_b32 s2, 0xffff, s2
; GISEL-VI-NEXT:    s_lshl_b32 s3, s3, 16
; GISEL-VI-NEXT:    s_or_b32 s2, s2, s3
; GISEL-VI-NEXT:    v_mov_b32_e32 v0, s0
; GISEL-VI-NEXT:    v_mov_b32_e32 v2, s2
; GISEL-VI-NEXT:    v_mov_b32_e32 v1, s1
; GISEL-VI-NEXT:    flat_store_dword v[0:1], v2
; GISEL-VI-NEXT:    s_endpgm
;
; GISEL-GFX9-LABEL: vec_smax_smin_sgpr:
; GISEL-GFX9:       ; %bb.0:
; GISEL-GFX9-NEXT:    s_load_dword s4, s[0:1], 0x2c
; GISEL-GFX9-NEXT:    s_load_dwordx2 s[2:3], s[0:1], 0x24
; GISEL-GFX9-NEXT:    s_sext_i32_i16 s0, 0
; GISEL-GFX9-NEXT:    v_mov_b32_e32 v1, 0
; GISEL-GFX9-NEXT:    s_waitcnt lgkmcnt(0)
; GISEL-GFX9-NEXT:    s_sext_i32_i16 s1, s4
; GISEL-GFX9-NEXT:    s_ashr_i32 s4, s4, 16
; GISEL-GFX9-NEXT:    s_max_i32 s0, s1, s0
; GISEL-GFX9-NEXT:    s_max_i32 s1, s4, 0
; GISEL-GFX9-NEXT:    s_pack_ll_b32_b16 s0, s0, s1
; GISEL-GFX9-NEXT:    s_sext_i32_i16 s1, s0
; GISEL-GFX9-NEXT:    s_ashr_i32 s0, s0, 16
; GISEL-GFX9-NEXT:    s_sext_i32_i16 s4, 0xff00ff
; GISEL-GFX9-NEXT:    s_min_i32 s1, s1, s4
; GISEL-GFX9-NEXT:    s_min_i32 s0, s0, 0xff
; GISEL-GFX9-NEXT:    s_pack_ll_b32_b16 s0, s1, s0
; GISEL-GFX9-NEXT:    v_mov_b32_e32 v0, s0
; GISEL-GFX9-NEXT:    global_store_dword v1, v0, s[2:3]
; GISEL-GFX9-NEXT:    s_endpgm
;
; GISEL-GFX11-LABEL: vec_smax_smin_sgpr:
; GISEL-GFX11:       ; %bb.0:
; GISEL-GFX11-NEXT:    s_clause 0x1
; GISEL-GFX11-NEXT:    s_load_b32 s2, s[0:1], 0x2c
; GISEL-GFX11-NEXT:    s_load_b64 s[0:1], s[0:1], 0x24
; GISEL-GFX11-NEXT:    s_sext_i32_i16 s3, 0
; GISEL-GFX11-NEXT:    v_mov_b32_e32 v1, 0
; GISEL-GFX11-NEXT:    s_waitcnt lgkmcnt(0)
; GISEL-GFX11-NEXT:    s_sext_i32_i16 s4, s2
; GISEL-GFX11-NEXT:    s_ashr_i32 s2, s2, 16
; GISEL-GFX11-NEXT:    s_max_i32 s3, s4, s3
; GISEL-GFX11-NEXT:    s_max_i32 s2, s2, 0
; GISEL-GFX11-NEXT:    s_delay_alu instid0(SALU_CYCLE_1)
; GISEL-GFX11-NEXT:    s_pack_ll_b32_b16 s2, s3, s2
; GISEL-GFX11-NEXT:    s_sext_i32_i16 s3, 0xff00ff
; GISEL-GFX11-NEXT:    s_sext_i32_i16 s4, s2
; GISEL-GFX11-NEXT:    s_ashr_i32 s2, s2, 16
; GISEL-GFX11-NEXT:    s_min_i32 s3, s4, s3
; GISEL-GFX11-NEXT:    s_min_i32 s2, s2, 0xff
; GISEL-GFX11-NEXT:    s_delay_alu instid0(SALU_CYCLE_1) | instskip(NEXT) | instid1(SALU_CYCLE_1)
; GISEL-GFX11-NEXT:    s_pack_ll_b32_b16 s2, s3, s2
; GISEL-GFX11-NEXT:    v_mov_b32_e32 v0, s2
; GISEL-GFX11-NEXT:    global_store_b32 v1, v0, s[0:1]
; GISEL-GFX11-NEXT:    s_sendmsg sendmsg(MSG_DEALLOC_VGPRS)
; GISEL-GFX11-NEXT:    s_endpgm
  %src.max = call <2 x i16> @llvm.smax.v2i16(<2 x i16> %src, <2 x i16> <i16 0, i16 0>)
  %src.clamp = call <2 x i16> @llvm.smin.v2i16(<2 x i16> %src.max, <2 x i16> <i16 255, i16 255>)
  store <2 x i16> %src.clamp, ptr addrspace(1) %out
  ret void
}

define <2 x i16> @vec_smin_smax(<2 x i16> %src) {
; SDAG-VI-LABEL: vec_smin_smax:
; SDAG-VI:       ; %bb.0:
; SDAG-VI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SDAG-VI-NEXT:    v_mov_b32_e32 v1, 0xff
; SDAG-VI-NEXT:    v_min_i16_sdwa v1, v0, v1 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
; SDAG-VI-NEXT:    v_min_i16_e32 v0, 0xff, v0
; SDAG-VI-NEXT:    v_mov_b32_e32 v2, 0
; SDAG-VI-NEXT:    v_max_i16_e32 v0, 0, v0
; SDAG-VI-NEXT:    v_max_i16_sdwa v1, v1, v2 dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:DWORD
; SDAG-VI-NEXT:    v_or_b32_e32 v0, v0, v1
; SDAG-VI-NEXT:    s_setpc_b64 s[30:31]
;
; SDAG-GFX9-LABEL: vec_smin_smax:
; SDAG-GFX9:       ; %bb.0:
; SDAG-GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; SDAG-GFX9-NEXT:    s_movk_i32 s4, 0xff
; SDAG-GFX9-NEXT:    v_pk_min_i16 v0, v0, s4 op_sel_hi:[1,0]
; SDAG-GFX9-NEXT:    v_pk_max_i16 v0, v0, 0
; SDAG-GFX9-NEXT:    s_setpc_b64 s[30:31]
;
; GFX11-LABEL: vec_smin_smax:
; GFX11:       ; %bb.0:
; GFX11-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GFX11-NEXT:    v_pk_min_i16 v0, 0xff, v0 op_sel_hi:[0,1]
; GFX11-NEXT:    s_delay_alu instid0(VALU_DEP_1)
; GFX11-NEXT:    v_pk_max_i16 v0, v0, 0
; GFX11-NEXT:    s_setpc_b64 s[30:31]
;
; GISEL-VI-LABEL: vec_smin_smax:
; GISEL-VI:       ; %bb.0:
; GISEL-VI-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GISEL-VI-NEXT:    v_mov_b32_e32 v2, 0xff
; GISEL-VI-NEXT:    v_min_i16_e32 v1, 0xff, v0
; GISEL-VI-NEXT:    v_min_i16_sdwa v0, v0, v2 dst_sel:DWORD dst_unused:UNUSED_PAD src0_sel:WORD_1 src1_sel:DWORD
; GISEL-VI-NEXT:    v_mov_b32_e32 v2, 0
; GISEL-VI-NEXT:    v_max_i16_e32 v1, 0, v1
; GISEL-VI-NEXT:    v_max_i16_sdwa v0, v0, v2 dst_sel:WORD_1 dst_unused:UNUSED_PAD src0_sel:DWORD src1_sel:DWORD
; GISEL-VI-NEXT:    v_or_b32_e32 v0, v1, v0
; GISEL-VI-NEXT:    s_setpc_b64 s[30:31]
;
; GISEL-GFX9-LABEL: vec_smin_smax:
; GISEL-GFX9:       ; %bb.0:
; GISEL-GFX9-NEXT:    s_waitcnt vmcnt(0) expcnt(0) lgkmcnt(0)
; GISEL-GFX9-NEXT:    v_mov_b32_e32 v1, 0xff00ff
; GISEL-GFX9-NEXT:    v_pk_min_i16 v0, v0, v1
; GISEL-GFX9-NEXT:    v_pk_max_i16 v0, v0, 0
; GISEL-GFX9-NEXT:    s_setpc_b64 s[30:31]
  %src.min = call <2 x i16> @llvm.smin.v2i16(<2 x i16> %src, <2 x i16> <i16 255, i16 255>)
  %src.clamp = call <2 x i16> @llvm.smax.v2i16(<2 x i16> %src.min, <2 x i16> <i16 0, i16 0>)
  ret <2 x i16> %src.clamp
}
