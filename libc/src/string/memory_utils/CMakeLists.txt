# TODO(michaelrj): split out the implementations from memory_utils
add_header_library(
  memory_utils
  HDRS
    aarch64/bcmp_implementations.h
    aarch64/memcmp_implementations.h
    aarch64/memcpy_implementations.h
    bcmp_implementations.h
    bzero_implementations.h
    generic/aligned_access.h
    generic/byte_per_byte.h
    memcmp_implementations.h
    memcpy_implementations.h
    memmove_implementations.h
    memset_implementations.h
    op_aarch64.h
    op_builtin.h
    op_generic.h
    op_x86.h
    riscv/bcmp_implementations.h
    riscv/memcpy_implementations.h
    utils.h
    x86_64/bcmp_implementations.h
    x86_64/memcmp_implementations.h
    x86_64/memcpy_implementations.h
  DEPS
    libc.src.__support.common
    libc.src.__support.CPP.bit
    libc.src.__support.CPP.cstddef
    libc.src.__support.CPP.type_traits
    libc.src.__support.macros.config
    libc.src.__support.macros.optimization
    libc.src.__support.macros.properties.architectures
)

add_header_library(
  memcpy_implementation
  HDRS
    memcpy_implementations.h
  DEPS
    .memory_utils
)

add_header_library(
  memmove_implementation
  HDRS
    memmove_implementations.h
  DEPS
    .memory_utils
)

add_header_library(
  memcmp_implementation
  HDRS
    memcmp_implementations.h
  DEPS
    .memory_utils
)

add_header_library(
  memset_implementation
  HDRS
    memset_implementations.h
  DEPS
    .memory_utils
)

add_header_library(
  bzero_implementation
  HDRS
    bzero_implementations.h
  DEPS
    .memset_implementation
)

add_header_library(
  strcmp_implementation
  HDRS
    strcmp_implementations.h
)

add_header_library(
 strstr_implementation
  HDRS
    strstr_implementations.h
)

add_header_library(
  memmem_implementation
  HDRS
    memmem_implementations.h
)
