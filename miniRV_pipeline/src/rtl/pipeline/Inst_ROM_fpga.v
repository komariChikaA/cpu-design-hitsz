// Inst_ROM — FPGA 综合版本
// 使用 Xilinx BRAM IP (IROM)，组合读，硬件为 0 周期延迟。
// Trace 版本见 Inst_ROM_trace.v（简单数组 + $fgetc 加载 meminit.bin）。
// 由 src/rtl/Inst_ROM.v 在非 RUN_TRACE 构建中自动选择。

`timescale 1ns / 1ps
`include "defines.vh"

module Inst_ROM_fpga (
    input  wire         cpu_clk,
    input  wire         cpu_rst,
    input  wire         inst_rreq,
    input  wire [31:0]  inst_addr,
    output wire         inst_valid,
    output wire [31:0]  inst_out
);

    // BRAM 无输出寄存器 (C_HAS_MEM_OUTPUT_REGS_A=0)，硬件为组合读。
    assign inst_valid = inst_rreq && !cpu_rst;

    IROM U_irom (
        .clka   (cpu_clk),
        .addra  (inst_addr[15:2]),
        .douta  (inst_out)
    );

endmodule
