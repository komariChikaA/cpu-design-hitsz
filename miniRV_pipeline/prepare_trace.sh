#!/usr/bin/env bash

# Install the complete pipelined RTL into a cdp-tests checkout.
# Pipeline helper modules are flattened because the course Makefile compiles
# mySoC/*.v rather than searching subdirectories recursively.

set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
test_root="${1:-$HOME/cdp-tests}"
target_dir="$test_root/mySoC"

if [[ ! -f "$test_root/Makefile" ]]; then
    printf 'Error: %s is not a cdp-tests directory.\n' "$test_root" >&2
    exit 2
fi

backup_dir="$test_root/mySoC.before-pipeline.$(date '+%Y%m%d-%H%M%S')"
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

rtl_count="$(find "$target_dir" -maxdepth 1 -type f \
    \( -name '*.v' -o -name '*.vh' \) | wc -l)"

test -f "$target_dir/pipeline_regs.v"
test -f "$target_dir/forward_unit.v"
test -f "$target_dir/ALU_trace.v"
test -f "$target_dir/ALU_multicycle.v"

printf 'Installed %s RTL files into %s\n' "$rtl_count" "$target_dir"
printf 'Next:\n'
printf '  cd %q\n' "$test_root"
printf '  make clean && make\n'
printf '  python3 run_all_tests.py\n'
