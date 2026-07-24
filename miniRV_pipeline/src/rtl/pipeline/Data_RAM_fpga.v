// Data_RAM — FPGA 综合版本
// 使用 Xilinx BRAM IP (DRAM)，组合读，硬件为 0 周期延迟。
// Trace 版本见 Data_RAM_trace.v（简单数组 + $fgetc 加载 meminit.bin）。
// 由 src/rtl/Data_RAM.v 在非 RUN_TRACE 构建中自动选择。

`timescale 1ns / 1ps
`include "defines.vh"

module Data_RAM_fpga (
    input  wire         cpu_clk,
    input  wire         cpu_rst,
    input  wire [ 3:0]  data_ren,
    input  wire [31:0]  data_addr,
    output wire         data_valid,
    output wire [31:0]  data_rdata,
    input  wire [ 3:0]  data_wen,
    input  wire [31:0]  data_wdata,
    output wire         data_wresp
);

    // BRAM 无输出寄存器 (C_HAS_MEM_OUTPUT_REGS_A=0)，硬件为组合读。
    assign data_valid = (|data_ren) && !cpu_rst;
    assign data_wresp = (|data_wen) && !cpu_rst;

    DRAM U_dram (
        .clka   (cpu_clk),
        .addra  (data_addr[16:2]),
        .douta  (data_rdata),
        .wea    (data_wen),
        .dina   (data_wdata)
    );

endmodule
