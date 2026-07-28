#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
test_name="${1:-}"
test_dir="$script_dir/software/c_test/$test_name"

if [[ -z "$test_name" || ! -d "$test_dir" ]]; then
    printf 'Usage: STUDENT_ID=20XXXXXXXX bash prepare_program.sh <test-name>\n' >&2
    printf 'Available programs:\n' >&2
    find "$script_dir/software/c_test" -mindepth 1 -maxdepth 1 -type d -printf '  %f\n' >&2
    exit 1
fi

(
    cd -- "$test_dir"
    STUDENT_ID="${STUDENT_ID:-20XXXXXXXX}" sh ./compile.sh
)

coe_path="$test_dir/main.coe"
if [[ ! -f "$coe_path" ]]; then
    printf 'Expected compiler output was not produced: %s\n' "$coe_path" >&2
    exit 1
fi

output_dir="$script_dir/outputs/programs/$test_name"
mkdir -p -- "$output_dir"

python3 "$script_dir/tools/bin2mem.py" \
    "$coe_path" \
    "$output_dir/main.mem"

word_count="$(wc -l < "$output_dir/main.mem")"
if [[ "$word_count" -ne 38400 ]]; then
    printf 'Expected 38400 words in main.mem, found %s\n' "$word_count" >&2
    exit 1
fi

cp -- "$coe_path" "$output_dir/main.coe"
for artifact in main.s main.map main.bin; do
    if [[ -f "$test_dir/$artifact" ]]; then
        cp -- "$test_dir/$artifact" "$output_dir/$artifact"
    fi
done
mkdir -p -- "$script_dir/src/coe"
cp -- "$output_dir/main.mem" "$script_dir/src/coe/main.mem"

printf 'Prepared %s for miniRV single-cycle EGO1\n' "$test_name"
printf 'Student ID: %s\n' "${STUDENT_ID:-20XXXXXXXX}"
printf 'Saved artifacts under %s\n' "$output_dir"
printf 'Updated %s (%s words)\n' "$script_dir/src/coe/main.mem" "$word_count"
printf 'Next step in Vivado: source rebuild_ego1.tcl\n'
