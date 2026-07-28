#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd -- "$script_dir/.." && pwd)"
repo_dir="$(cd -- "$project_dir/.." && pwd)"
rtl_dir="$project_dir/src/rtl"
output_dir="${REPORT_VCD_DIR:-$repo_dir/docs/course-report/vcd}"
build_dir="${TMPDIR:-/tmp}/miniRV_pipeline_report_vcd"

command -v iverilog >/dev/null 2>&1 || {
    printf 'ERROR: iverilog is required. On Ubuntu: sudo apt install iverilog\n' >&2
    exit 1
}
command -v vvp >/dev/null 2>&1 || {
    printf 'ERROR: vvp is required. On Ubuntu: sudo apt install iverilog\n' >&2
    exit 1
}

rm -rf -- "$build_dir"
mkdir -p -- "$build_dir" "$output_dir"

common_core_rtl=(
    "$rtl_dir/cpu_core.v"
    "$rtl_dir/ALU.v"
    "$rtl_dir/Controller.v"
    "$rtl_dir/MEXT.v"
    "$rtl_dir/MREQ.v"
    "$rtl_dir/RF.v"
    "$rtl_dir/SEXT.v"
    "$rtl_dir/multiplier.v"
    "$rtl_dir/divider.v"
    "$rtl_dir/pipeline/ALU_multicycle.v"
    "$rtl_dir/pipeline/ALU_trace.v"
    "$rtl_dir/pipeline/forward_unit.v"
    "$rtl_dir/pipeline/pipeline_regs.v"
)

iverilog -g2012 -Wall -I "$rtl_dir" \
    -s pipeline_hazard_tb \
    -o "$build_dir/pipeline_hazard_tb.vvp" \
    "$script_dir/pipeline_hazard_tb.v" \
    "${common_core_rtl[@]}"
(
    cd -- "$build_dir"
    vvp "$build_dir/pipeline_hazard_tb.vvp"
)
cp -- "$build_dir/06_pipeline_load_use_hazard.vcd" \
    "$output_dir/06_pipeline_load_use_hazard.vcd"

iverilog -g2012 -Wall -DDUMP_VCD -I "$rtl_dir" \
    -s axi_master_tb \
    -o "$build_dir/axi_master_tb.vvp" \
    "$script_dir/axi_master_tb.v" \
    "$rtl_dir/axi_master.v"
(
    cd -- "$build_dir"
    vvp "$build_dir/axi_master_tb.vvp"
)
cp -- "$build_dir/06_no_cache_axi_transaction.vcd" \
    "$output_dir/06_no_cache_axi_transaction.vcd"

printf 'Generated report VCD files:\n'
printf '  %s\n' "$output_dir/06_pipeline_load_use_hazard.vcd"
printf '  %s\n' "$output_dir/06_no_cache_axi_transaction.vcd"
