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

# Five-stage movement, forwarding and branch-flush directed test.
iverilog -g2012 -Wall -I "$rtl_dir" \
    -s pipeline_flow_tb \
    -o "$build_dir/pipeline_flow_tb.vvp" \
    "$script_dir/pipeline_flow_tb.v" \
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
(
    cd -- "$build_dir"
    vvp "$build_dir/pipeline_flow_tb.vvp"
)

iverilog -g2012 -Wall -I "$rtl_dir" \
    -s axi_master_tb \
    -o "$build_dir/axi_master_tb.vvp" \
    "$script_dir/axi_master_tb.v" \
    "$rtl_dir/axi_master.v"
vvp "$build_dir/axi_master_tb.vvp"

iverilog -g2012 -Wall -I "$rtl_dir" \
    -s cache_tb \
    -o "$build_dir/cache_tb.vvp" \
    "$script_dir/cache_tb.v" \
    "$rtl_dir/ICache.v" \
    "$rtl_dir/DCache.v"
vvp "$build_dir/cache_tb.vvp"

common_rtl=(
    "$rtl_dir/cpu_top.v"
    "$rtl_dir/cpu_core.v"
    "$rtl_dir/ICache.v"
    "$rtl_dir/DCache.v"
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

board_rtl=(
    "${common_rtl[@]}"
    "$rtl_dir/miniRV_SoC.v"
    "$rtl_dir/axi_board_soc.v"
    "$rtl_dir/board_bram.v"
    "$rtl_dir/simple_uart.v"
    "$rtl_dir/sevenseg_display.v"
    "$script_dir/board_ip_stubs.v"
)

iverilog -g2012 -Wall -I "$rtl_dir" \
    -s miniRV_SoC \
    -o "$build_dir/miniRV_SoC_board.vvp" \
    "${board_rtl[@]}"

printf 'PASS: EGO1 board hierarchy elaboration\n'

# Exercise the BRAM read burst required by ICache/DCache refill.
iverilog -g2012 -Wall -I "$rtl_dir" \
    -s board_burst_tb \
    -o "$build_dir/board_burst_tb.vvp" \
    "$script_dir/board_burst_tb.v" \
    "$rtl_dir/axi_board_soc.v" \
    "$rtl_dir/board_bram.v" \
    "$rtl_dir/simple_uart.v" \
    "$rtl_dir/sevenseg_display.v" \
    "$script_dir/board_ip_stubs.v"
(
    cd -- "$build_dir"
    vvp "$build_dir/board_burst_tb.vvp"
)

# Exercise the final AXI board Slave and all course-visible peripherals.
iverilog -g2012 -Wall -I "$rtl_dir" \
    -s board_peripheral_tb \
    -o "$build_dir/board_peripheral_tb.vvp" \
    "$script_dir/board_peripheral_tb.v" \
    "$rtl_dir/axi_board_soc.v" \
    "$rtl_dir/board_bram.v" \
    "$rtl_dir/simple_uart.v" \
    "$rtl_dir/sevenseg_display.v" \
    "$script_dir/board_ip_stubs.v"
(
    cd -- "$build_dir"
    vvp "$build_dir/board_peripheral_tb.vvp"
)

iverilog -g2012 -Wall -I "$rtl_dir" \
    -s soc_simple_tb \
    -o "$build_dir/soc_simple_tb.vvp" \
    "$project_dir/src/sim/soc_simple_tb.v" \
    "${board_rtl[@]}"

printf 'PASS: Vivado simulation hierarchy elaboration\n'
