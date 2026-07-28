#!/usr/bin/env bash
set -euo pipefail

if [[ -n "${CROSS_COMPILE:-}" ]]; then
    tool_prefix="$CROSS_COMPILE"
elif command -v riscv32-unknown-elf-gcc >/dev/null 2>&1; then
    tool_prefix="riscv32-unknown-elf-"
elif command -v riscv64-unknown-elf-gcc >/dev/null 2>&1; then
    tool_prefix="riscv64-unknown-elf-"
elif command -v riscv-none-elf-gcc >/dev/null 2>&1; then
    tool_prefix="riscv-none-elf-"
else
    printf 'RISC-V GCC was not found.\n' >&2
    printf 'Set CROSS_COMPILE or use the course Linux server toolchain.\n' >&2
    exit 1
fi

iterations="${COREMARK_ITERATIONS:-700}"
case "$iterations" in
    ''|*[!0-9]*)
        printf 'COREMARK_ITERATIONS must be a positive integer, got: %s\n' "$iterations" >&2
        exit 1
        ;;
esac
if [[ "$iterations" -le 0 ]]; then
    printf 'COREMARK_ITERATIONS must be greater than zero.\n' >&2
    exit 1
fi

make clean >/dev/null 2>&1 || true
make coremark \
    ARCH=im \
    ITERATIONS="$iterations" \
    CROSS_PREFIX="$tool_prefix"

if [[ ! -s main.coe ]]; then
    printf 'CoreMark compilation did not produce main.coe\n' >&2
    exit 1
fi
if [[ ! -s main.s ]]; then
    printf 'CoreMark compilation did not produce main.s\n' >&2
    exit 1
fi

printf 'CoreMark compile succeeded\n'
printf 'Student IDs: %s\n' '2024311081_2024311453'
printf 'CPU frequency: 50 MHz\n'
printf 'Iterations: %s\n' "$iterations"
