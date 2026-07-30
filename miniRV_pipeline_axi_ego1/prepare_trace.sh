#!/usr/bin/env bash

# Install the current pipelined I/D-Cache AXI RTL into a cdp-tests checkout.
# The course Makefile compiles a flat mySoC directory, so pipeline helpers are
# copied beside the top-level RTL files.

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
test_root="${1:-$HOME/cdp-tests}"
target_dir="$test_root/mySoC"

if [[ ! -f "$test_root/Makefile" || ! -f "$test_root/vsrc/bram_axi.v" ]]; then
    printf 'Error: %s is not an AXI cdp-tests directory.\n' "$test_root" >&2
    exit 2
fi

backup_dir="$test_root/mySoC.before-pipeline-cache.$(date '+%Y%m%d-%H%M%S')"
if [[ -e "$target_dir" ]]; then
    mv -- "$target_dir" "$backup_dir"
    printf 'Previous mySoC saved to: %s\n' "$backup_dir"
fi

mkdir -p -- "$target_dir"
find "$script_dir/src/rtl" -maxdepth 1 -type f \
    \( -name '*.v' -o -name '*.vh' \) \
    -exec cp -- {} "$target_dir/" \;
find "$script_dir/src/rtl/pipeline" -maxdepth 1 -type f -name '*.v' \
    -exec cp -- {} "$target_dir/" \;

test -f "$target_dir/ICache.v"
test -f "$target_dir/DCache.v"
test -f "$target_dir/axi_master.v"
test -f "$target_dir/pipeline_regs.v"
test -f "$target_dir/forward_unit.v"
grep -q '^`define ENABLE_ICACHE' "$target_dir/defines.vh"
grep -q '^`define ENABLE_DCACHE' "$target_dir/defines.vh"
grep -q 'ICache.*U_icache' "$target_dir/cpu_top.v"
grep -q 'DCache.*U_dcache' "$target_dir/cpu_top.v"
grep -q 'axi_master U_aximaster' "$target_dir/cpu_top.v"
grep -q 'bram_axi U_bram' "$target_dir/miniRV_SoC.v"

rtl_count="$(find "$target_dir" -maxdepth 1 -type f \
    \( -name '*.v' -o -name '*.vh' \) | wc -l)"

printf 'Installed %s Cache/pipeline AXI RTL files into %s\n' \
    "$rtl_count" "$target_dir"
printf 'Backup: %s\n' "$backup_dir"
printf 'Next:\n'
printf '  cd %q\n' "$test_root"
printf '  make clean && make\n'
printf '  python3 run_all_tests.py\n'
