#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
project_dir="$(cd -- "$script_dir/.." && pwd)"
rtl_dir="$project_dir/src/rtl"
build_dir="${TMPDIR:-/tmp}/miniRV_pipeline_axi_iverilog"

rm -rf -- "$build_dir"
mkdir -p -- "$build_dir"

iverilog -g2012 -Wall -I "$rtl_dir" \
    -s alu_multicycle_tb \
    -o "$build_dir/alu_multicycle_tb.vvp" \
    "$script_dir/alu_multicycle_tb.v" \
    "$rtl_dir/pipeline/ALU_multicycle.v" \
    "$rtl_dir/multiplier.v" \
    "$rtl_dir/divider.v"
vvp "$build_dir/alu_multicycle_tb.vvp"

iverilog -g2012 -Wall -I "$rtl_dir" \
    -s cpu_core_mext_tb \
    -o "$build_dir/cpu_core_mext_fpga_tb.vvp" \
    "$script_dir/cpu_core_mext_tb.v" \
    "$rtl_dir/cpu_core.v" \
    "$rtl_dir/ALU.v" \
    "$rtl_dir/Controller.v" \
    "$rtl_dir/MEXT.v" \
    "$rtl_dir/MREQ.v" \
    "$rtl_dir/RF.v" \
    "$rtl_dir/SEXT.v" \
    "$rtl_dir/multiplier.v" \
    "$rtl_dir/divider.v" \
    "$rtl_dir/pipeline/ALU_multicycle.v" \
    "$rtl_dir/pipeline/ALU_trace.v" \
    "$rtl_dir/pipeline/forward_unit.v" \
    "$rtl_dir/pipeline/pipeline_regs.v"
vvp "$build_dir/cpu_core_mext_fpga_tb.vvp"

iverilog -g2012 -Wall -DRUN_TRACE -I "$rtl_dir" \
    -s cpu_core_mext_tb \
    -o "$build_dir/cpu_core_mext_trace_tb.vvp" \
    "$script_dir/cpu_core_mext_tb.v" \
    "$rtl_dir/cpu_core.v" \
    "$rtl_dir/ALU.v" \
    "$rtl_dir/Controller.v" \
    "$rtl_dir/MEXT.v" \
    "$rtl_dir/MREQ.v" \
    "$rtl_dir/RF.v" \
    "$rtl_dir/SEXT.v" \
    "$rtl_dir/multiplier.v" \
    "$rtl_dir/divider.v" \
    "$rtl_dir/pipeline/ALU_multicycle.v" \
    "$rtl_dir/pipeline/ALU_trace.v" \
    "$rtl_dir/pipeline/forward_unit.v" \
    "$rtl_dir/pipeline/pipeline_regs.v"
vvp "$build_dir/cpu_core_mext_trace_tb.vvp"

iverilog -g2012 -Wall -I "$rtl_dir" \
    -s axi_master_tb \
    -o "$build_dir/axi_master_tb.vvp" \
    "$script_dir/axi_master_tb.v" \
    "$rtl_dir/axi_master.v"
vvp "$build_dir/axi_master_tb.vvp"

common_rtl=(
    "$rtl_dir/cpu_top.v"
    "$rtl_dir/cpu_core.v"
    "$rtl_dir/axi_master.v"
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
    -s cpu_top_fetch_tb \
    -o "$build_dir/cpu_top_fetch_tb.vvp" \
    "$script_dir/cpu_top_fetch_tb.v" \
    "${common_rtl[@]}"
vvp "$build_dir/cpu_top_fetch_tb.vvp"

# Elaborate both implementation selections so interface drift is caught even
# when a behavioral test only exercises one of them.
iverilog -g2012 -Wall -I "$rtl_dir" \
    -s cpu_top \
    -o "$build_dir/cpu_top_fpga.vvp" \
    "${common_rtl[@]}"
iverilog -g2012 -Wall -DRUN_TRACE -I "$rtl_dir" \
    -s cpu_top \
    -o "$build_dir/cpu_top_trace.vvp" \
    "${common_rtl[@]}"

printf 'PASS: cpu_top FPGA and RUN_TRACE elaboration\n'
