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

# 1. load-use + AXI 数据读等待：展示 bubble、memory freeze 和 WB 前递。
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

# 2. 普通五级流动 + MEM/WB 前递 + taken branch 冲刷。
iverilog -g2012 -Wall -I "$rtl_dir" \
    -s pipeline_flow_tb \
    -o "$build_dir/pipeline_flow_tb.vvp" \
    "$script_dir/pipeline_flow_tb.v" \
    "${common_core_rtl[@]}"
(
    cd -- "$build_dir"
    vvp "$build_dir/pipeline_flow_tb.vvp"
)
cp -- "$build_dir/07_pipeline_five_stage_forward_branch.vcd" \
    "$output_dir/07_pipeline_five_stage_forward_branch.vcd"

# 3. Master 定向 AXI 读写：展示 AR/R、AW/W/B 独立握手和 backpressure。
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

# 4. 最终板级 Slave 外设：LED、数码管、switch、timer、UART TX/RX。
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
cp -- "$build_dir/09_board_peripheral_mmio_uart.vcd" \
    "$output_dir/09_board_peripheral_mmio_uart.vcd"

printf 'Generated report VCD files:\n'
printf '  %s\n' "$output_dir/06_pipeline_load_use_hazard.vcd"
printf '  %s\n' "$output_dir/07_pipeline_five_stage_forward_branch.vcd"
printf '  %s\n' "$output_dir/06_no_cache_axi_transaction.vcd"
printf '  %s\n' "$output_dir/09_board_peripheral_mmio_uart.vcd"
