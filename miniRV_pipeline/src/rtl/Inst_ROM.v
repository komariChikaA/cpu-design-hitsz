`timescale 1ns / 1ps

// Trace loads meminit.bin directly; the FPGA build uses the IROM XCI.
module Inst_ROM (
    input  wire         cpu_clk,
    input  wire         cpu_rst,
    input  wire         inst_rreq,
    input  wire [31:0]  inst_addr,
    output wire         inst_valid,
    output wire [31:0]  inst_out
);

`ifdef RUN_TRACE
    Inst_ROM_trace U_impl (
        .cpu_clk    (cpu_clk),
        .cpu_rst    (cpu_rst),
        .inst_rreq  (inst_rreq),
        .inst_addr  (inst_addr),
        .inst_valid (inst_valid),
        .inst_out   (inst_out)
    );
`else
    Inst_ROM_fpga U_impl (
        .cpu_clk    (cpu_clk),
        .cpu_rst    (cpu_rst),
        .inst_rreq  (inst_rreq),
        .inst_addr  (inst_addr),
        .inst_valid (inst_valid),
        .inst_out   (inst_out)
    );
`endif

endmodule
