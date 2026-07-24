`timescale 1ns / 1ps

// Trace loads meminit.bin directly; the FPGA build uses the DRAM XCI.
module Data_RAM (
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

`ifdef RUN_TRACE
    Data_RAM_trace U_impl (
        .cpu_clk    (cpu_clk),
        .cpu_rst    (cpu_rst),
        .data_ren   (data_ren),
        .data_addr  (data_addr),
        .data_valid (data_valid),
        .data_rdata (data_rdata),
        .data_wen   (data_wen),
        .data_wdata (data_wdata),
        .data_wresp (data_wresp)
    );
`else
    Data_RAM_fpga U_impl (
        .cpu_clk    (cpu_clk),
        .cpu_rst    (cpu_rst),
        .data_ren   (data_ren),
        .data_addr  (data_addr),
        .data_valid (data_valid),
        .data_rdata (data_rdata),
        .data_wen   (data_wen),
        .data_wdata (data_wdata),
        .data_wresp (data_wresp)
    );
`endif

endmodule
