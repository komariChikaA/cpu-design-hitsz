#!/bin/sh
set -eu

test_dir=$(pwd)
main_file=$(grep -l "main[[:space:]]*(" ./*.c 2>/dev/null | head -n 1)
if [ -z "$main_file" ]; then
    echo "Compile Failed: no C source containing main() was found" >&2
    exit 1
fi
base=$(basename "$main_file" .c)

if [ -n "${CROSS_COMPILE:-}" ]; then
    tool_prefix=$CROSS_COMPILE
elif command -v riscv32-unknown-elf-gcc >/dev/null 2>&1; then
    tool_prefix=riscv32-unknown-elf-
elif command -v riscv64-unknown-elf-gcc >/dev/null 2>&1; then
    tool_prefix=riscv64-unknown-elf-
else
    echo "Compile Failed: install a RISC-V GNU bare-metal toolchain" >&2
    exit 1
fi

cc=${tool_prefix}gcc
objdump=${tool_prefix}objdump
objcopy=${tool_prefix}objcopy
student_id=${STUDENT_ID:-20XXXXXXXX}

cleanup()
{
    rm -f startup.h temp_main.c link.ld "$base.elf"
}
trap cleanup EXIT HUP INT TERM

cat > startup.h <<'EOF'
#ifndef STARTUP_H
#define STARTUP_H

__attribute__((naked, section(".text.start"))) void _start(void)
{
    asm volatile (
        "lui sp, %hi(_stack_top)\n"
        "addi sp, sp, %lo(_stack_top)\n"
        "call main\n"
        "1: j 1b\n"
    );
}

#endif
EOF

{
    echo '#include "startup.h"'
    cat "$main_file"
} > temp_main.c

cat > link.ld <<'EOF'
MEMORY
{
    rom  : ORIGIN = 0x00000000, LENGTH = 50K
    ram1 : ORIGIN = 0x0000C800, LENGTH = 50K
    ram2 : ORIGIN = 0x00019000, LENGTH = 50K
}

SECTIONS
{
    .text : {
        KEEP(*(.text.start))
        *(.text)
        *(.text.*)
    } > rom

    .rodata : {
        *(.rodata)
        *(.rodata.*)
    } > ram1

    .data : {
        *(.data)
        *(.data.*)
        *(.sdata)
        *(.sdata.*)
    } > ram1

    .bss (NOLOAD) : {
        *(.bss)
        *(.bss.*)
        *(.sbss)
        *(.sbss.*)
        *(COMMON)
    } > ram1

    _heap_start = ORIGIN(ram2);
    _stack_top = ORIGIN(ram2) + LENGTH(ram2);
}
EOF

set -- temp_main.c
if [ -f peripheral.c ]; then
    set -- "$@" peripheral.c
fi
if [ -f runtime.c ]; then
    set -- "$@" runtime.c
fi

"$cc" -T link.ld \
    -nostdlib -nostartfiles -ffreestanding -fno-builtin \
    -ffunction-sections -fdata-sections -fno-unwind-tables \
    -fno-asynchronous-unwind-tables -msmall-data-limit=0 \
    -mabi=ilp32 -march=rv32im -O2 \
    -DSTUDENT_ID="\"$student_id\"" \
    -Wl,-e,_start -Wl,--gc-sections -Wl,--no-relax \
    -Wl,--build-id=none -Wl,-Map,"$base.map" \
    -o "$base.elf" "$@" -lgcc

"$objdump" -d -M no-aliases "$base.elf" > "$base.s"
"$objcopy" -O binary --gap-fill 0 "$base.elf" "$base.bin"

python3 - "$base.bin" "$base.coe" <<'PY'
from pathlib import Path
import sys

bin_path = Path(sys.argv[1])
coe_path = Path(sys.argv[2])
data = bin_path.read_bytes()
if len(data) % 4:
    data += bytes(4 - len(data) % 4)
words = [
    int.from_bytes(data[offset : offset + 4], "little")
    for offset in range(0, len(data), 4)
]
if len(words) > 38_400:
    raise SystemExit(
        f"program has {len(words)} words, EGO1 image holds 38400"
    )

with coe_path.open("w", encoding="ascii", newline="\n") as handle:
    handle.write("memory_initialization_radix=16;\n")
    handle.write("memory_initialization_vector=\n")
    for index, word in enumerate(words):
        suffix = ";\n" if index == len(words) - 1 else ",\n"
        handle.write(f"{word:08X}{suffix}")

print(f"generated {coe_path} with {len(words)} program words")
PY

printf 'Compile succeeded: %s\n' "$test_dir/$base.coe"
printf 'Student ID: %s\n' "$student_id"
