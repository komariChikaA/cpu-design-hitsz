`timescale 1ns / 1ps

// Icarus-only signatures for elaborating the board hierarchy without Xilinx
// generated simulation products. Vivado uses the XCI files instead.
module clk_wiz_0 (
    input  wire clk_in1,
    output wire locked,
    output wire clk_out1
);
    assign clk_out1 = clk_in1;
    assign locked = 1'b1;
endmodule

module IROM (
    input  wire        clka,
    input  wire [13:0] addra,
    output reg  [31:0] douta
);
    always @(posedge clka)
        douta <= {18'h0, addra};
endmodule

module DRAM (
    input  wire        clka,
    input  wire [ 3:0] wea,
    input  wire [14:0] addra,
    input  wire [31:0] dina,
    output reg  [31:0] douta
);
    wire _unused = &{1'b0, wea, dina};
    always @(posedge clka)
        douta <= {17'h0, addra};
endmodule
