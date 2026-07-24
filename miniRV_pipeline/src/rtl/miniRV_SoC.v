`timescale 1ns / 1ps

`include "defines.vh"

module miniRV_SoC(
    input  wire         fpga_clk,
    input  wire         fpga_rst,   // Low Active
    input  wire [15:0]  sw,
    output wire [15:0]  led,
    output wire [ 7:0]  dig_en,
    output wire [ 7:0]  dig_seg,    // {CA, CB, ..., CG, DP}
    output wire [ 7:0]  dig_seg1,
    input  wire         rx,
    output wire         tx
);

`ifdef RUN_TRACE
    wire sys_clk = fpga_clk;
    wire sys_rst = fpga_rst;
`else
    wire pll_clk1;
    wire pll_lock;
    wire sys_clk = pll_clk1;
    reg [1:0] reset_sync;
    wire sys_rst = reset_sync[1];

    // Assert reset asynchronously from the active-low board button, then
    // release it synchronously only after the generated clock is locked.
    always @(posedge sys_clk or negedge fpga_rst) begin
        if (!fpga_rst)
            reset_sync <= 2'b11;
        else if (!pll_lock)
            reset_sync <= 2'b11;
        else
            reset_sync <= {reset_sync[0], 1'b0};
    end

    clk_wiz_0 U_clkgen (
        .clk_in1    (fpga_clk),
        .locked     (pll_lock),
        .clk_out1   (pll_clk1)
    );
`endif

    // The Basic Trace harness does not consume board peripherals, and the
    // current pipeline milestone has no board-side I/O controller yet.
    assign led      = 16'h0000;
    assign dig_en   = 8'hff;
    assign dig_seg  = 8'h00;
    assign dig_seg1 = 8'h00;
    assign tx       = 1'b1;

    wire _unused_board_inputs = &{1'b0, sw, rx};

    cpu_top U_cpu (
        .cpu_clk        (sys_clk),
        .cpu_rst        (sys_rst)
    );

endmodule
