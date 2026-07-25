#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
test_name="${1:-0_uart_test}"
test_dir="$script_dir/software/c_test/$test_name"

if [[ ! -d "$test_dir" ]]; then
    printf 'Unknown test program: %s\n' "$test_name" >&2
    printf 'Available programs:\n' >&2
    find "$script_dir/software/c_test" -mindepth 1 -maxdepth 1 -type d -printf '  %f\n' >&2
    exit 1
fi

(
    cd -- "$test_dir"
    sh ./compile.sh
)

coe_path="$test_dir/main.coe"
if [[ ! -f "$coe_path" ]]; then
    printf 'Expected compiler output was not produced: %s\n' "$coe_path" >&2
    exit 1
fi

python3 "$script_dir/tools/bin2mem.py" \
    "$coe_path" \
    "$script_dir/src/coe/main.mem"

word_count="$(wc -l < "$script_dir/src/coe/main.mem")"
if [[ "$word_count" -ne 38400 ]]; then
    printf 'Expected 38400 words in main.mem, found %s\n' "$word_count" >&2
    exit 1
fi

printf 'Prepared EGO1 image from %s\n' "$test_name"
printf 'Updated %s (%s words)\n' "$script_dir/src/coe/main.mem" "$word_count"
printf 'Next step in Vivado: source rebuild_ego1.tcl\n'
