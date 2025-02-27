; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --check-attributes --check-globals
; RUN: opt -aa-pipeline=basic-aa -passes=openmp-opt -attributor-manifest-internal  -attributor-annotate-decl-cs -S < %s | FileCheck %s --check-prefixes=CHECK,TUNIT
; RUN: opt -aa-pipeline=basic-aa -passes=openmp-opt-cgscc -attributor-manifest-internal  -attributor-annotate-decl-cs -S < %s | FileCheck %s --check-prefixes=CHECK,CGSCC

target triple = "amdgcn-amd-amdhsa"

%struct.ident_t = type { i32, i32, i32, i32, ptr }

@G = internal addrspace(3) global i32 undef, align 4
@H = internal addrspace(3) global i32 undef, align 4
@X = internal addrspace(3) global i32 undef, align 4
@QA1 = internal addrspace(3) global i32 undef, align 4
@QB1 = internal addrspace(3) global i32 undef, align 4
@QC1 = internal addrspace(3) global i32 undef, align 4
@QD1 = internal addrspace(3) global i32 undef, align 4
@QA2 = internal addrspace(3) global i32 undef, align 4
@QB2 = internal addrspace(3) global i32 undef, align 4
@QC2 = internal addrspace(3) global i32 undef, align 4
@QD2 = internal addrspace(3) global i32 undef, align 4
@QA3 = internal addrspace(3) global i32 undef, align 4
@QB3 = internal addrspace(3) global i32 undef, align 4
@QC3 = internal addrspace(3) global i32 undef, align 4
@QD3 = internal addrspace(3) global i32 undef, align 4
@UAA1 = internal addrspace(3) global i32 undef, align 4
@UAA2 = internal addrspace(3) global i32 undef, align 4
@str = private unnamed_addr addrspace(4) constant [1 x i8] c"\00", align 1

; Make sure we do not delete the stores to @G without also replacing the load with `1`.
;.
; TUNIT: @G = internal addrspace(3) global i32 undef, align 4
; TUNIT: @H = internal addrspace(3) global i32 undef, align 4
; TUNIT: @X = internal addrspace(3) global i32 undef, align 4
; TUNIT: @QA1 = internal addrspace(3) global i32 undef, align 4
; TUNIT: @QB1 = internal addrspace(3) global i32 undef, align 4
; TUNIT: @QC1 = internal addrspace(3) global i32 undef, align 4
; TUNIT: @QD1 = internal addrspace(3) global i32 undef, align 4
; TUNIT: @QA2 = internal addrspace(3) global i32 undef, align 4
; TUNIT: @QB2 = internal addrspace(3) global i32 undef, align 4
; TUNIT: @QC2 = internal addrspace(3) global i32 undef, align 4
; TUNIT: @QD2 = internal addrspace(3) global i32 undef, align 4
; TUNIT: @QA3 = internal addrspace(3) global i32 undef, align 4
; TUNIT: @QB3 = internal addrspace(3) global i32 undef, align 4
; TUNIT: @QC3 = internal addrspace(3) global i32 undef, align 4
; TUNIT: @QD3 = internal addrspace(3) global i32 undef, align 4
; TUNIT: @UAA1 = internal addrspace(3) global i32 undef, align 4
; TUNIT: @UAA2 = internal addrspace(3) global i32 undef, align 4
; TUNIT: @str = private unnamed_addr addrspace(4) constant [1 x i8] zeroinitializer, align 1
; TUNIT: @kernel_nested_parallelism = weak constant i8 0
;.
; CGSCC: @G = internal addrspace(3) global i32 undef, align 4
; CGSCC: @H = internal addrspace(3) global i32 undef, align 4
; CGSCC: @X = internal addrspace(3) global i32 undef, align 4
; CGSCC: @QA1 = internal addrspace(3) global i32 undef, align 4
; CGSCC: @QB1 = internal addrspace(3) global i32 undef, align 4
; CGSCC: @QC1 = internal addrspace(3) global i32 undef, align 4
; CGSCC: @QD1 = internal addrspace(3) global i32 undef, align 4
; CGSCC: @QA2 = internal addrspace(3) global i32 undef, align 4
; CGSCC: @QB2 = internal addrspace(3) global i32 undef, align 4
; CGSCC: @QC2 = internal addrspace(3) global i32 undef, align 4
; CGSCC: @QD2 = internal addrspace(3) global i32 undef, align 4
; CGSCC: @QA3 = internal addrspace(3) global i32 undef, align 4
; CGSCC: @QB3 = internal addrspace(3) global i32 undef, align 4
; CGSCC: @QC3 = internal addrspace(3) global i32 undef, align 4
; CGSCC: @QD3 = internal addrspace(3) global i32 undef, align 4
; CGSCC: @UAA1 = internal addrspace(3) global i32 undef, align 4
; CGSCC: @UAA2 = internal addrspace(3) global i32 undef, align 4
; CGSCC: @str = private unnamed_addr addrspace(4) constant [1 x i8] zeroinitializer, align 1
;.
define void @kernel() "kernel" {
;
; TUNIT: Function Attrs: norecurse
; TUNIT-LABEL: define {{[^@]+}}@kernel
; TUNIT-SAME: () #[[ATTR0:[0-9]+]] {
; TUNIT-NEXT:    [[CALL:%.*]] = call i32 @__kmpc_target_init(ptr undef, i8 1, i1 false)
; TUNIT-NEXT:    [[CMP:%.*]] = icmp eq i32 [[CALL]], -1
; TUNIT-NEXT:    br i1 [[CMP]], label [[IF_THEN:%.*]], label [[IF_ELSE:%.*]]
; TUNIT:       if.then:
; TUNIT-NEXT:    br label [[IF_MERGE:%.*]]
; TUNIT:       if.else:
; TUNIT-NEXT:    call void @barrier() #[[ATTR6:[0-9]+]]
; TUNIT-NEXT:    call void @use1(i32 1) #[[ATTR7:[0-9]+]]
; TUNIT-NEXT:    call void @llvm.assume(i1 true)
; TUNIT-NEXT:    call void @barrier() #[[ATTR6]]
; TUNIT-NEXT:    br label [[IF_MERGE]]
; TUNIT:       if.merge:
; TUNIT-NEXT:    call void @use1(i32 2) #[[ATTR7]]
; TUNIT-NEXT:    br i1 [[CMP]], label [[IF_THEN2:%.*]], label [[IF_END:%.*]]
; TUNIT:       if.then2:
; TUNIT-NEXT:    call void @barrier() #[[ATTR6]]
; TUNIT-NEXT:    br label [[IF_END]]
; TUNIT:       if.end:
; TUNIT-NEXT:    call void @__kmpc_target_deinit(ptr undef, i8 1)
; TUNIT-NEXT:    ret void
;
; CGSCC: Function Attrs: norecurse
; CGSCC-LABEL: define {{[^@]+}}@kernel
; CGSCC-SAME: () #[[ATTR0:[0-9]+]] {
; CGSCC-NEXT:    [[CALL:%.*]] = call i32 @__kmpc_target_init(ptr undef, i8 1, i1 false)
; CGSCC-NEXT:    [[CMP:%.*]] = icmp eq i32 [[CALL]], -1
; CGSCC-NEXT:    br i1 [[CMP]], label [[IF_THEN:%.*]], label [[IF_ELSE:%.*]]
; CGSCC:       if.then:
; CGSCC-NEXT:    br label [[IF_MERGE:%.*]]
; CGSCC:       if.else:
; CGSCC-NEXT:    call void @barrier() #[[ATTR6:[0-9]+]]
; CGSCC-NEXT:    call void @use1(i32 1) #[[ATTR6]]
; CGSCC-NEXT:    call void @llvm.assume(i1 true)
; CGSCC-NEXT:    call void @barrier() #[[ATTR6]]
; CGSCC-NEXT:    br label [[IF_MERGE]]
; CGSCC:       if.merge:
; CGSCC-NEXT:    call void @use1(i32 2) #[[ATTR6]]
; CGSCC-NEXT:    br i1 [[CMP]], label [[IF_THEN2:%.*]], label [[IF_END:%.*]]
; CGSCC:       if.then2:
; CGSCC-NEXT:    call void @barrier() #[[ATTR6]]
; CGSCC-NEXT:    br label [[IF_END]]
; CGSCC:       if.end:
; CGSCC-NEXT:    call void @__kmpc_target_deinit(ptr undef, i8 1)
; CGSCC-NEXT:    ret void
;
  %call = call i32 @__kmpc_target_init(ptr undef, i8 1, i1 false)
  %cmp = icmp eq i32 %call, -1
  br i1 %cmp, label %if.then, label %if.else
if.then:
  store i32 1, ptr addrspace(3) @G
  store i32 2, ptr addrspace(3) @H
  br label %if.merge
if.else:
  call void @barrier();
  %l = load i32, ptr addrspace(3) @G
  call void @use1(i32 %l)
  %hv = load i32, ptr addrspace(3) @H
  %hc = icmp eq i32 %hv, 2
  call void @llvm.assume(i1 %hc)
  call void @barrier();
  br label %if.merge
if.merge:
  %hreload = load i32, ptr addrspace(3) @H
  call void @use1(i32 %hreload)
  br i1 %cmp, label %if.then2, label %if.end
if.then2:
  store i32 2, ptr addrspace(3) @G
  call void @barrier();
  br label %if.end
if.end:
  call void @__kmpc_target_deinit(ptr undef, i8 1)
  ret void
}

define void @test_assume() {
; CHECK-LABEL: define {{[^@]+}}@test_assume() {
; CHECK-NEXT:    call void @llvm.assume(i1 icmp ne (ptr addrspacecast (ptr addrspace(4) @str to ptr), ptr null))
; CHECK-NEXT:    ret void
;
  call void @llvm.assume(i1 icmp ne (ptr addrspacecast (ptr addrspace(4) @str to ptr), ptr null))
  ret void
}

; We can't ignore the sync, hence this might store 2 into %p
define void @kernel2(ptr %p) "kernel" {
; CHECK-LABEL: define {{[^@]+}}@kernel2
; CHECK-SAME: (ptr [[P:%.*]]) #[[ATTR1:[0-9]+]] {
; CHECK-NEXT:    store i32 1, ptr addrspace(3) @X, align 4
; CHECK-NEXT:    call void @sync()
; CHECK-NEXT:    [[V:%.*]] = load i32, ptr addrspace(3) @X, align 4
; CHECK-NEXT:    store i32 2, ptr addrspace(3) @X, align 4
; CHECK-NEXT:    store i32 [[V]], ptr [[P]], align 4
; CHECK-NEXT:    ret void
;
  store i32 1, ptr addrspace(3) @X
  call void @sync()
  %v = load i32, ptr addrspace(3) @X
  store i32 2, ptr addrspace(3) @X
  store i32 %v, ptr %p
  ret void
}

; We can't ignore the sync, hence this might store 2 into %p
define void @kernel3(ptr %p) "kernel" {
; TUNIT-LABEL: define {{[^@]+}}@kernel3
; TUNIT-SAME: (ptr [[P:%.*]]) #[[ATTR1]] {
; TUNIT-NEXT:    store i32 1, ptr addrspace(3) @X, align 4
; TUNIT-NEXT:    call void @sync_def.internalized()
; TUNIT-NEXT:    [[V:%.*]] = load i32, ptr addrspace(3) @X, align 4
; TUNIT-NEXT:    store i32 2, ptr addrspace(3) @X, align 4
; TUNIT-NEXT:    store i32 [[V]], ptr [[P]], align 4
; TUNIT-NEXT:    ret void
;
; CGSCC-LABEL: define {{[^@]+}}@kernel3
; CGSCC-SAME: (ptr [[P:%.*]]) #[[ATTR1]] {
; CGSCC-NEXT:    store i32 1, ptr addrspace(3) @X, align 4
; CGSCC-NEXT:    call void @sync_def()
; CGSCC-NEXT:    [[V:%.*]] = load i32, ptr addrspace(3) @X, align 4
; CGSCC-NEXT:    store i32 2, ptr addrspace(3) @X, align 4
; CGSCC-NEXT:    store i32 [[V]], ptr [[P]], align 4
; CGSCC-NEXT:    ret void
;
  store i32 1, ptr addrspace(3) @X
  call void @sync_def()
  %v = load i32, ptr addrspace(3) @X
  store i32 2, ptr addrspace(3) @X
  store i32 %v, ptr %p
  ret void
}

define void @sync_def() {
; CHECK-LABEL: define {{[^@]+}}@sync_def() {
; CHECK-NEXT:    call void @sync()
; CHECK-NEXT:    ret void
;
  call void @sync()
  ret void
}

define void @kernel4a1(i1 %c) "kernel" {
; TUNIT-LABEL: define {{[^@]+}}@kernel4a1
; TUNIT-SAME: (i1 [[C:%.*]]) #[[ATTR1]] {
; TUNIT-NEXT:    store i32 0, ptr addrspace(3) @QA1, align 4
; TUNIT-NEXT:    br i1 [[C]], label [[S:%.*]], label [[L:%.*]]
; TUNIT:       L:
; TUNIT-NEXT:    call void @sync()
; TUNIT-NEXT:    [[V:%.*]] = load i32, ptr addrspace(3) @QA1, align 4
; TUNIT-NEXT:    call void @use1(i32 [[V]]) #[[ATTR7]]
; TUNIT-NEXT:    ret void
; TUNIT:       S:
; TUNIT-NEXT:    store i32 2, ptr addrspace(3) @QA1, align 4
; TUNIT-NEXT:    call void @sync()
; TUNIT-NEXT:    ret void
;
; CGSCC-LABEL: define {{[^@]+}}@kernel4a1
; CGSCC-SAME: (i1 [[C:%.*]]) #[[ATTR1]] {
; CGSCC-NEXT:    store i32 0, ptr addrspace(3) @QA1, align 4
; CGSCC-NEXT:    br i1 [[C]], label [[S:%.*]], label [[L:%.*]]
; CGSCC:       L:
; CGSCC-NEXT:    call void @sync()
; CGSCC-NEXT:    [[V:%.*]] = load i32, ptr addrspace(3) @QA1, align 4
; CGSCC-NEXT:    call void @use1(i32 [[V]]) #[[ATTR6]]
; CGSCC-NEXT:    ret void
; CGSCC:       S:
; CGSCC-NEXT:    store i32 2, ptr addrspace(3) @QA1, align 4
; CGSCC-NEXT:    call void @sync()
; CGSCC-NEXT:    ret void
;
  store i32 0, ptr addrspace(3) @QA1
  br i1 %c, label %S, label %L
L:
  call void @sync();
  %v = load i32, ptr addrspace(3) @QA1
  call void @use1(i32 %v)
  ret void
S:
  store i32 2, ptr addrspace(3) @QA1
  call void @sync();
  ret void
}

; We should not replace the load or delete the second store.
define void @kernel4b1(i1 %c) "kernel" {
; TUNIT-LABEL: define {{[^@]+}}@kernel4b1
; TUNIT-SAME: (i1 [[C:%.*]]) #[[ATTR1]] {
; TUNIT-NEXT:    store i32 0, ptr addrspace(3) @QB1, align 4
; TUNIT-NEXT:    br i1 [[C]], label [[S:%.*]], label [[L:%.*]]
; TUNIT:       L:
; TUNIT-NEXT:    call void @sync()
; TUNIT-NEXT:    [[V:%.*]] = load i32, ptr addrspace(3) @QB1, align 4
; TUNIT-NEXT:    call void @use1(i32 [[V]]) #[[ATTR7]]
; TUNIT-NEXT:    ret void
; TUNIT:       S:
; TUNIT-NEXT:    store i32 2, ptr addrspace(3) @QB1, align 4
; TUNIT-NEXT:    ret void
;
; CGSCC-LABEL: define {{[^@]+}}@kernel4b1
; CGSCC-SAME: (i1 [[C:%.*]]) #[[ATTR1]] {
; CGSCC-NEXT:    store i32 0, ptr addrspace(3) @QB1, align 4
; CGSCC-NEXT:    br i1 [[C]], label [[S:%.*]], label [[L:%.*]]
; CGSCC:       L:
; CGSCC-NEXT:    call void @sync()
; CGSCC-NEXT:    [[V:%.*]] = load i32, ptr addrspace(3) @QB1, align 4
; CGSCC-NEXT:    call void @use1(i32 [[V]]) #[[ATTR6]]
; CGSCC-NEXT:    ret void
; CGSCC:       S:
; CGSCC-NEXT:    store i32 2, ptr addrspace(3) @QB1, align 4
; CGSCC-NEXT:    ret void
;
  store i32 0, ptr addrspace(3) @QB1
  br i1 %c, label %S, label %L
L:
  call void @sync();
  %v = load i32, ptr addrspace(3) @QB1
  call void @use1(i32 %v)
  ret void
S:
  store i32 2, ptr addrspace(3) @QB1
  ret void
}

define void @kernel4a2(i1 %c) "kernel" {
; TUNIT-LABEL: define {{[^@]+}}@kernel4a2
; TUNIT-SAME: (i1 [[C:%.*]]) #[[ATTR1]] {
; TUNIT-NEXT:    br i1 [[C]], label [[S:%.*]], label [[L:%.*]]
; TUNIT:       L:
; TUNIT-NEXT:    call void @sync()
; TUNIT-NEXT:    call void @use1(i32 2) #[[ATTR7]]
; TUNIT-NEXT:    ret void
; TUNIT:       S:
; TUNIT-NEXT:    call void @sync()
; TUNIT-NEXT:    ret void
;
; CGSCC-LABEL: define {{[^@]+}}@kernel4a2
; CGSCC-SAME: (i1 [[C:%.*]]) #[[ATTR1]] {
; CGSCC-NEXT:    br i1 [[C]], label [[S:%.*]], label [[L:%.*]]
; CGSCC:       L:
; CGSCC-NEXT:    call void @sync()
; CGSCC-NEXT:    call void @use1(i32 2) #[[ATTR6]]
; CGSCC-NEXT:    ret void
; CGSCC:       S:
; CGSCC-NEXT:    call void @sync()
; CGSCC-NEXT:    ret void
;
  br i1 %c, label %S, label %L
L:
  call void @sync();
  %v = load i32, ptr addrspace(3) @QA2
  call void @use1(i32 %v)
  ret void
S:
  store i32 2, ptr addrspace(3) @QA2
  call void @sync();
  ret void
}

; FIXME: We should not replace the load with undef.
define void @kernel4b2(i1 %c) "kernel" {
; TUNIT-LABEL: define {{[^@]+}}@kernel4b2
; TUNIT-SAME: (i1 [[C:%.*]]) #[[ATTR1]] {
; TUNIT-NEXT:    br i1 [[C]], label [[S:%.*]], label [[L:%.*]]
; TUNIT:       L:
; TUNIT-NEXT:    call void @sync()
; TUNIT-NEXT:    call void @use1(i32 2) #[[ATTR7]]
; TUNIT-NEXT:    ret void
; TUNIT:       S:
; TUNIT-NEXT:    ret void
;
; CGSCC-LABEL: define {{[^@]+}}@kernel4b2
; CGSCC-SAME: (i1 [[C:%.*]]) #[[ATTR1]] {
; CGSCC-NEXT:    br i1 [[C]], label [[S:%.*]], label [[L:%.*]]
; CGSCC:       L:
; CGSCC-NEXT:    call void @sync()
; CGSCC-NEXT:    call void @use1(i32 2) #[[ATTR6]]
; CGSCC-NEXT:    ret void
; CGSCC:       S:
; CGSCC-NEXT:    ret void
;
  br i1 %c, label %S, label %L
L:
  call void @sync();
  %v = load i32, ptr addrspace(3) @QB2
  call void @use1(i32 %v)
  ret void
S:
  store i32 2, ptr addrspace(3) @QB2
  ret void
}

define void @kernel4a3(i1 %c) "kernel" {
; TUNIT-LABEL: define {{[^@]+}}@kernel4a3
; TUNIT-SAME: (i1 [[C:%.*]]) #[[ATTR1]] {
; TUNIT-NEXT:    store i32 0, ptr addrspace(3) @QA3, align 4
; TUNIT-NEXT:    br i1 [[C]], label [[S:%.*]], label [[L:%.*]]
; TUNIT:       L:
; TUNIT-NEXT:    call void @sync()
; TUNIT-NEXT:    [[V:%.*]] = load i32, ptr addrspace(3) @QA3, align 4
; TUNIT-NEXT:    call void @use1(i32 [[V]]) #[[ATTR7]]
; TUNIT-NEXT:    ret void
; TUNIT:       S:
; TUNIT-NEXT:    store i32 2, ptr addrspace(3) @QA3, align 4
; TUNIT-NEXT:    call void @sync()
; TUNIT-NEXT:    call void @sync()
; TUNIT-NEXT:    call void @sync()
; TUNIT-NEXT:    call void @sync()
; TUNIT-NEXT:    ret void
;
; CGSCC-LABEL: define {{[^@]+}}@kernel4a3
; CGSCC-SAME: (i1 [[C:%.*]]) #[[ATTR1]] {
; CGSCC-NEXT:    store i32 0, ptr addrspace(3) @QA3, align 4
; CGSCC-NEXT:    br i1 [[C]], label [[S:%.*]], label [[L:%.*]]
; CGSCC:       L:
; CGSCC-NEXT:    call void @sync()
; CGSCC-NEXT:    [[V:%.*]] = load i32, ptr addrspace(3) @QA3, align 4
; CGSCC-NEXT:    call void @use1(i32 [[V]]) #[[ATTR6]]
; CGSCC-NEXT:    ret void
; CGSCC:       S:
; CGSCC-NEXT:    store i32 2, ptr addrspace(3) @QA3, align 4
; CGSCC-NEXT:    call void @sync()
; CGSCC-NEXT:    call void @sync()
; CGSCC-NEXT:    call void @sync()
; CGSCC-NEXT:    call void @sync()
; CGSCC-NEXT:    ret void
;
  store i32 0, ptr addrspace(3) @QA3
  br i1 %c, label %S, label %L
L:
  call void @sync();
  %v = load i32, ptr addrspace(3) @QA3
  call void @use1(i32 %v)
  ret void
S:
  store i32 2, ptr addrspace(3) @QA3
  call void @sync();
  call void @sync();
  call void @sync();
  call void @sync();
  ret void
}

; The load of QB3 should not be simplified to 0.
define void @kernel4b3(i1 %c) "kernel" {
; TUNIT-LABEL: define {{[^@]+}}@kernel4b3
; TUNIT-SAME: (i1 [[C:%.*]]) #[[ATTR1]] {
; TUNIT-NEXT:    store i32 0, ptr addrspace(3) @QB3, align 4
; TUNIT-NEXT:    br i1 [[C]], label [[S:%.*]], label [[L:%.*]]
; TUNIT:       L:
; TUNIT-NEXT:    call void @sync()
; TUNIT-NEXT:    [[V:%.*]] = load i32, ptr addrspace(3) @QB3, align 4
; TUNIT-NEXT:    call void @use1(i32 [[V]]) #[[ATTR7]]
; TUNIT-NEXT:    ret void
; TUNIT:       S:
; TUNIT-NEXT:    store i32 2, ptr addrspace(3) @QB3, align 4
; TUNIT-NEXT:    call void @use1(i32 0) #[[ATTR7]]
; TUNIT-NEXT:    call void @use1(i32 1) #[[ATTR7]]
; TUNIT-NEXT:    call void @use1(i32 2) #[[ATTR7]]
; TUNIT-NEXT:    call void @use1(i32 3) #[[ATTR7]]
; TUNIT-NEXT:    ret void
;
; CGSCC-LABEL: define {{[^@]+}}@kernel4b3
; CGSCC-SAME: (i1 [[C:%.*]]) #[[ATTR1]] {
; CGSCC-NEXT:    store i32 0, ptr addrspace(3) @QB3, align 4
; CGSCC-NEXT:    br i1 [[C]], label [[S:%.*]], label [[L:%.*]]
; CGSCC:       L:
; CGSCC-NEXT:    call void @sync()
; CGSCC-NEXT:    [[V:%.*]] = load i32, ptr addrspace(3) @QB3, align 4
; CGSCC-NEXT:    call void @use1(i32 [[V]]) #[[ATTR6]]
; CGSCC-NEXT:    ret void
; CGSCC:       S:
; CGSCC-NEXT:    store i32 2, ptr addrspace(3) @QB3, align 4
; CGSCC-NEXT:    call void @use1(i32 0) #[[ATTR6]]
; CGSCC-NEXT:    call void @use1(i32 1) #[[ATTR6]]
; CGSCC-NEXT:    call void @use1(i32 2) #[[ATTR6]]
; CGSCC-NEXT:    call void @use1(i32 3) #[[ATTR6]]
; CGSCC-NEXT:    ret void
;
  store i32 0, ptr addrspace(3) @QB3
  br i1 %c, label %S, label %L
L:
  call void @sync();
  %v = load i32, ptr addrspace(3) @QB3
  call void @use1(i32 %v)
  ret void
S:
  store i32 2, ptr addrspace(3) @QB3
  call void @use1(i32 0)
  call void @use1(i32 1)
  call void @use1(i32 2)
  call void @use1(i32 3)
  ret void
}


define void @kernel4c1(i1 %c) "kernel" {
; TUNIT: Function Attrs: norecurse
; TUNIT-LABEL: define {{[^@]+}}@kernel4c1
; TUNIT-SAME: (i1 [[C:%.*]]) #[[ATTR0]] {
; TUNIT-NEXT:    br i1 [[C]], label [[S:%.*]], label [[L:%.*]]
; TUNIT:       L:
; TUNIT-NEXT:    call void @use1(i32 0) #[[ATTR7]]
; TUNIT-NEXT:    ret void
; TUNIT:       S:
; TUNIT-NEXT:    ret void
;
; CGSCC: Function Attrs: norecurse
; CGSCC-LABEL: define {{[^@]+}}@kernel4c1
; CGSCC-SAME: (i1 [[C:%.*]]) #[[ATTR0]] {
; CGSCC-NEXT:    br i1 [[C]], label [[S:%.*]], label [[L:%.*]]
; CGSCC:       L:
; CGSCC-NEXT:    call void @use1(i32 0) #[[ATTR6]]
; CGSCC-NEXT:    ret void
; CGSCC:       S:
; CGSCC-NEXT:    ret void
;
  store i32 0, ptr addrspace(3) @QC1
  br i1 %c, label %S, label %L
L:
  call void @barrier();
  %v = load i32, ptr addrspace(3) @QC1
  call void @use1(i32 %v)
  ret void
S:
  store i32 2, ptr addrspace(3) @QC1
  call void @barrier();
  ret void
}

; We should not replace the load or delete the second store.
define void @kernel4d1(i1 %c) "kernel" {
; TUNIT: Function Attrs: norecurse
; TUNIT-LABEL: define {{[^@]+}}@kernel4d1
; TUNIT-SAME: (i1 [[C:%.*]]) #[[ATTR0]] {
; TUNIT-NEXT:    store i32 0, ptr addrspace(3) @QD1, align 4
; TUNIT-NEXT:    br i1 [[C]], label [[S:%.*]], label [[L:%.*]]
; TUNIT:       L:
; TUNIT-NEXT:    call void @barrier() #[[ATTR7]]
; TUNIT-NEXT:    [[V:%.*]] = load i32, ptr addrspace(3) @QD1, align 4
; TUNIT-NEXT:    call void @use1(i32 [[V]]) #[[ATTR7]]
; TUNIT-NEXT:    ret void
; TUNIT:       S:
; TUNIT-NEXT:    store i32 2, ptr addrspace(3) @QD1, align 4
; TUNIT-NEXT:    ret void
;
; CGSCC: Function Attrs: norecurse
; CGSCC-LABEL: define {{[^@]+}}@kernel4d1
; CGSCC-SAME: (i1 [[C:%.*]]) #[[ATTR0]] {
; CGSCC-NEXT:    store i32 0, ptr addrspace(3) @QD1, align 4
; CGSCC-NEXT:    br i1 [[C]], label [[S:%.*]], label [[L:%.*]]
; CGSCC:       L:
; CGSCC-NEXT:    call void @barrier() #[[ATTR6]]
; CGSCC-NEXT:    [[V:%.*]] = load i32, ptr addrspace(3) @QD1, align 4
; CGSCC-NEXT:    call void @use1(i32 [[V]]) #[[ATTR6]]
; CGSCC-NEXT:    ret void
; CGSCC:       S:
; CGSCC-NEXT:    store i32 2, ptr addrspace(3) @QD1, align 4
; CGSCC-NEXT:    ret void
;
  store i32 0, ptr addrspace(3) @QD1
  br i1 %c, label %S, label %L
L:
  call void @barrier();
  %v = load i32, ptr addrspace(3) @QD1
  call void @use1(i32 %v)
  ret void
S:
  store i32 2, ptr addrspace(3) @QD1
  ret void
}

define void @kernel4c2(i1 %c) "kernel" {
; TUNIT: Function Attrs: norecurse
; TUNIT-LABEL: define {{[^@]+}}@kernel4c2
; TUNIT-SAME: (i1 [[C:%.*]]) #[[ATTR0]] {
; TUNIT-NEXT:    br i1 [[C]], label [[S:%.*]], label [[L:%.*]]
; TUNIT:       L:
; TUNIT-NEXT:    call void @use1(i32 undef) #[[ATTR7]]
; TUNIT-NEXT:    ret void
; TUNIT:       S:
; TUNIT-NEXT:    ret void
;
; CGSCC: Function Attrs: norecurse
; CGSCC-LABEL: define {{[^@]+}}@kernel4c2
; CGSCC-SAME: (i1 [[C:%.*]]) #[[ATTR0]] {
; CGSCC-NEXT:    br i1 [[C]], label [[S:%.*]], label [[L:%.*]]
; CGSCC:       L:
; CGSCC-NEXT:    call void @use1(i32 undef) #[[ATTR6]]
; CGSCC-NEXT:    ret void
; CGSCC:       S:
; CGSCC-NEXT:    ret void
;
  br i1 %c, label %S, label %L
L:
  call void @barrier();
  %v = load i32, ptr addrspace(3) @QC2
  call void @use1(i32 %v)
  ret void
S:
  store i32 2, ptr addrspace(3) @QC2
  call void @barrier();
  ret void
}

; We should not replace the load with undef.
define void @kernel4d2(i1 %c) "kernel" {
; TUNIT: Function Attrs: norecurse
; TUNIT-LABEL: define {{[^@]+}}@kernel4d2
; TUNIT-SAME: (i1 [[C:%.*]]) #[[ATTR0]] {
; TUNIT-NEXT:    br i1 [[C]], label [[S:%.*]], label [[L:%.*]]
; TUNIT:       L:
; TUNIT-NEXT:    call void @use1(i32 2) #[[ATTR7]]
; TUNIT-NEXT:    ret void
; TUNIT:       S:
; TUNIT-NEXT:    ret void
;
; CGSCC: Function Attrs: norecurse
; CGSCC-LABEL: define {{[^@]+}}@kernel4d2
; CGSCC-SAME: (i1 [[C:%.*]]) #[[ATTR0]] {
; CGSCC-NEXT:    br i1 [[C]], label [[S:%.*]], label [[L:%.*]]
; CGSCC:       L:
; CGSCC-NEXT:    call void @use1(i32 2) #[[ATTR6]]
; CGSCC-NEXT:    ret void
; CGSCC:       S:
; CGSCC-NEXT:    ret void
;
  br i1 %c, label %S, label %L
L:
  call void @barrier();
  %v = load i32, ptr addrspace(3) @QD2
  call void @use1(i32 %v)
  ret void
S:
  store i32 2, ptr addrspace(3) @QD2
  ret void
}

define void @kernel4c3(i1 %c) "kernel" {
; TUNIT: Function Attrs: norecurse
; TUNIT-LABEL: define {{[^@]+}}@kernel4c3
; TUNIT-SAME: (i1 [[C:%.*]]) #[[ATTR0]] {
; TUNIT-NEXT:    br i1 [[C]], label [[S:%.*]], label [[L:%.*]]
; TUNIT:       L:
; TUNIT-NEXT:    call void @use1(i32 undef) #[[ATTR7]]
; TUNIT-NEXT:    ret void
; TUNIT:       S:
; TUNIT-NEXT:    ret void
;
; CGSCC: Function Attrs: norecurse
; CGSCC-LABEL: define {{[^@]+}}@kernel4c3
; CGSCC-SAME: (i1 [[C:%.*]]) #[[ATTR0]] {
; CGSCC-NEXT:    br i1 [[C]], label [[S:%.*]], label [[L:%.*]]
; CGSCC:       L:
; CGSCC-NEXT:    call void @use1(i32 undef) #[[ATTR6]]
; CGSCC-NEXT:    ret void
; CGSCC:       S:
; CGSCC-NEXT:    ret void
;
  br i1 %c, label %S, label %L
L:
  call void @barrier();
  %v = load i32, ptr addrspace(3) @QC3
  call void @use1(i32 %v)
  ret void
S:
  store i32 2, ptr addrspace(3) @QC3
  call void @barrier();
  ret void
}

; We should not replace the load with undef.
define void @kernel4d3(i1 %c) "kernel" {
; TUNIT: Function Attrs: norecurse
; TUNIT-LABEL: define {{[^@]+}}@kernel4d3
; TUNIT-SAME: (i1 [[C:%.*]]) #[[ATTR0]] {
; TUNIT-NEXT:    br i1 [[C]], label [[S:%.*]], label [[L:%.*]]
; TUNIT:       L:
; TUNIT-NEXT:    call void @use1(i32 2) #[[ATTR7]]
; TUNIT-NEXT:    ret void
; TUNIT:       S:
; TUNIT-NEXT:    ret void
;
; CGSCC: Function Attrs: norecurse
; CGSCC-LABEL: define {{[^@]+}}@kernel4d3
; CGSCC-SAME: (i1 [[C:%.*]]) #[[ATTR0]] {
; CGSCC-NEXT:    br i1 [[C]], label [[S:%.*]], label [[L:%.*]]
; CGSCC:       L:
; CGSCC-NEXT:    call void @use1(i32 2) #[[ATTR6]]
; CGSCC-NEXT:    ret void
; CGSCC:       S:
; CGSCC-NEXT:    ret void
;
  br i1 %c, label %S, label %L
L:
  call void @barrier();
  %v = load i32, ptr addrspace(3) @QD3
  call void @use1(i32 %v)
  ret void
S:
  store i32 2, ptr addrspace(3) @QD3
  ret void
}

define void @kernel_unknown_and_aligned1(i1 %c) "kernel" {
; TUNIT-LABEL: define {{[^@]+}}@kernel_unknown_and_aligned1
; TUNIT-SAME: (i1 [[C:%.*]]) #[[ATTR1]] {
; TUNIT-NEXT:    br i1 [[C]], label [[S:%.*]], label [[L:%.*]]
; TUNIT:       L:
; TUNIT-NEXT:    call void @use1(i32 2) #[[ATTR7]]
; TUNIT-NEXT:    ret void
; TUNIT:       S:
; TUNIT-NEXT:    call void @sync()
; TUNIT-NEXT:    call void @barrier() #[[ATTR7]]
; TUNIT-NEXT:    call void @sync()
; TUNIT-NEXT:    ret void
;
; CGSCC-LABEL: define {{[^@]+}}@kernel_unknown_and_aligned1
; CGSCC-SAME: (i1 [[C:%.*]]) #[[ATTR1]] {
; CGSCC-NEXT:    br i1 [[C]], label [[S:%.*]], label [[L:%.*]]
; CGSCC:       L:
; CGSCC-NEXT:    call void @use1(i32 2) #[[ATTR6]]
; CGSCC-NEXT:    ret void
; CGSCC:       S:
; CGSCC-NEXT:    call void @sync()
; CGSCC-NEXT:    call void @barrier() #[[ATTR6]]
; CGSCC-NEXT:    call void @sync()
; CGSCC-NEXT:    ret void
;
  br i1 %c, label %S, label %L
L:
  call void @barrier();
  %v = load i32, ptr addrspace(3) @UAA1
  call void @use1(i32 %v)
  ret void
S:
  call void @sync();
  store i32 2, ptr addrspace(3) @UAA1
  call void @barrier();
  call void @sync();
  ret void
}

define void @kernel_unknown_and_aligned2(i1 %c) "kernel" {
; TUNIT-LABEL: define {{[^@]+}}@kernel_unknown_and_aligned2
; TUNIT-SAME: (i1 [[C:%.*]]) #[[ATTR1]] {
; TUNIT-NEXT:    br i1 [[C]], label [[S:%.*]], label [[L:%.*]]
; TUNIT:       L:
; TUNIT-NEXT:    call void @sync()
; TUNIT-NEXT:    call void @use1(i32 2) #[[ATTR7]]
; TUNIT-NEXT:    ret void
; TUNIT:       S:
; TUNIT-NEXT:    call void @sync()
; TUNIT-NEXT:    call void @barrier() #[[ATTR7]]
; TUNIT-NEXT:    call void @sync()
; TUNIT-NEXT:    ret void
;
; CGSCC-LABEL: define {{[^@]+}}@kernel_unknown_and_aligned2
; CGSCC-SAME: (i1 [[C:%.*]]) #[[ATTR1]] {
; CGSCC-NEXT:    br i1 [[C]], label [[S:%.*]], label [[L:%.*]]
; CGSCC:       L:
; CGSCC-NEXT:    call void @sync()
; CGSCC-NEXT:    call void @use1(i32 2) #[[ATTR6]]
; CGSCC-NEXT:    ret void
; CGSCC:       S:
; CGSCC-NEXT:    call void @sync()
; CGSCC-NEXT:    call void @barrier() #[[ATTR6]]
; CGSCC-NEXT:    call void @sync()
; CGSCC-NEXT:    ret void
;
  br i1 %c, label %S, label %L
L:
  call void @sync();
  %v = load i32, ptr addrspace(3) @UAA2
  call void @use1(i32 %v)
  ret void
S:
  call void @sync();
  store i32 2, ptr addrspace(3) @UAA2
  call void @barrier();
  call void @sync();
  ret void
}

declare void @sync()
declare void @barrier() norecurse nounwind nocallback "llvm.assume"="ompx_aligned_barrier"
declare void @use1(i32) nosync norecurse nounwind nocallback
declare i32 @__kmpc_target_init(ptr, i8, i1) nocallback
declare void @__kmpc_target_deinit(ptr, i8) nocallback
declare void @llvm.assume(i1)

!llvm.module.flags = !{!0, !1}
!nvvm.annotations = !{!2, !3, !4, !5, !6, !7, !8, !9, !10, !11, !12, !13, !14, !15, !16, !17, !18}

!0 = !{i32 7, !"openmp", i32 50}
!1 = !{i32 7, !"openmp-device", i32 50}
!2 = !{ptr @kernel, !"kernel", i32 1}
!3 = !{ptr @kernel2, !"kernel", i32 1}
!4 = !{ptr @kernel3, !"kernel", i32 1}
!5 = !{ptr @kernel4a1, !"kernel", i32 1}
!6 = !{ptr @kernel4b1, !"kernel", i32 1}
!7 = !{ptr @kernel4a2, !"kernel", i32 1}
!8 = !{ptr @kernel4b2, !"kernel", i32 1}
!9 = !{ptr @kernel4a3, !"kernel", i32 1}
!10 = !{ptr @kernel4b3, !"kernel", i32 1}
!11 = !{ptr @kernel4c1, !"kernel", i32 1}
!12 = !{ptr @kernel4d1, !"kernel", i32 1}
!13 = !{ptr @kernel4c2, !"kernel", i32 1}
!14 = !{ptr @kernel4d2, !"kernel", i32 1}
!15 = !{ptr @kernel4c3, !"kernel", i32 1}
!16 = !{ptr @kernel4d3, !"kernel", i32 1}
!17 = !{ptr @kernel_unknown_and_aligned1, !"kernel", i32 1}
!18 = !{ptr @kernel_unknown_and_aligned2, !"kernel", i32 1}

;.
; TUNIT: attributes #[[ATTR0]] = { norecurse "kernel" }
; TUNIT: attributes #[[ATTR1]] = { "kernel" }
; TUNIT: attributes #[[ATTR2:[0-9]+]] = { nocallback norecurse nounwind "llvm.assume"="ompx_aligned_barrier" }
; TUNIT: attributes #[[ATTR3:[0-9]+]] = { nocallback norecurse nosync nounwind }
; TUNIT: attributes #[[ATTR4:[0-9]+]] = { nocallback }
; TUNIT: attributes #[[ATTR5:[0-9]+]] = { nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: readwrite) }
; TUNIT: attributes #[[ATTR6]] = { nounwind "llvm.assume"="ompx_aligned_barrier" }
; TUNIT: attributes #[[ATTR7]] = { nounwind }
;.
; CGSCC: attributes #[[ATTR0]] = { norecurse "kernel" }
; CGSCC: attributes #[[ATTR1]] = { "kernel" }
; CGSCC: attributes #[[ATTR2:[0-9]+]] = { nocallback norecurse nounwind "llvm.assume"="ompx_aligned_barrier" }
; CGSCC: attributes #[[ATTR3:[0-9]+]] = { nocallback norecurse nosync nounwind }
; CGSCC: attributes #[[ATTR4:[0-9]+]] = { nocallback }
; CGSCC: attributes #[[ATTR5:[0-9]+]] = { nocallback nofree nosync nounwind willreturn memory(inaccessiblemem: readwrite) }
; CGSCC: attributes #[[ATTR6]] = { nounwind }
;.
; CHECK: [[META0:![0-9]+]] = !{i32 7, !"openmp", i32 50}
; CHECK: [[META1:![0-9]+]] = !{i32 7, !"openmp-device", i32 50}
; CHECK: [[META2:![0-9]+]] = !{ptr @kernel, !"kernel", i32 1}
; CHECK: [[META3:![0-9]+]] = !{ptr @kernel2, !"kernel", i32 1}
; CHECK: [[META4:![0-9]+]] = !{ptr @kernel3, !"kernel", i32 1}
; CHECK: [[META5:![0-9]+]] = !{ptr @kernel4a1, !"kernel", i32 1}
; CHECK: [[META6:![0-9]+]] = !{ptr @kernel4b1, !"kernel", i32 1}
; CHECK: [[META7:![0-9]+]] = !{ptr @kernel4a2, !"kernel", i32 1}
; CHECK: [[META8:![0-9]+]] = !{ptr @kernel4b2, !"kernel", i32 1}
; CHECK: [[META9:![0-9]+]] = !{ptr @kernel4a3, !"kernel", i32 1}
; CHECK: [[META10:![0-9]+]] = !{ptr @kernel4b3, !"kernel", i32 1}
; CHECK: [[META11:![0-9]+]] = !{ptr @kernel4c1, !"kernel", i32 1}
; CHECK: [[META12:![0-9]+]] = !{ptr @kernel4d1, !"kernel", i32 1}
; CHECK: [[META13:![0-9]+]] = !{ptr @kernel4c2, !"kernel", i32 1}
; CHECK: [[META14:![0-9]+]] = !{ptr @kernel4d2, !"kernel", i32 1}
; CHECK: [[META15:![0-9]+]] = !{ptr @kernel4c3, !"kernel", i32 1}
; CHECK: [[META16:![0-9]+]] = !{ptr @kernel4d3, !"kernel", i32 1}
; CHECK: [[META17:![0-9]+]] = !{ptr @kernel_unknown_and_aligned1, !"kernel", i32 1}
; CHECK: [[META18:![0-9]+]] = !{ptr @kernel_unknown_and_aligned2, !"kernel", i32 1}
;.
