`timescale 1ns / 1ps

// Select the implementation automatically:
// - cdp-tests defines RUN_TRACE and uses the combinational reference-timed ALU;
// - Vivado leaves RUN_TRACE undefined and uses the multi-cycle FPGA ALU.
module ALU (
    input  wire         rst,
    input  wire         clk,
    input  wire [ 4:0]  op,
    input  wire [31:0]  a,
    input  wire [31:0]  b,

    output wire [31:0]  c,
    output wire         br,
    output wire         busy
);

`ifdef RUN_TRACE
    ALU_trace U_impl (
        .rst  (rst),
        .clk  (clk),
        .op   (op),
        .a    (a),
        .b    (b),
        .c    (c),
        .br   (br),
        .busy (busy)
    );
`else
    ALU_multicycle U_impl (
        .rst  (rst),
        .clk  (clk),
        .op   (op),
        .a    (a),
        .b    (b),
        .c    (c),
        .br   (br),
        .busy (busy)
    );
`endif

endmodule
