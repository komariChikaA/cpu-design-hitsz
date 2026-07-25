`timescale 1ns / 1ps

`include "defines.vh"

module ALU_trace (
    input  wire         rst,
    input  wire         clk,
    input  wire [ 4:0]  op,
    input  wire [31:0]  a,
    input  wire [31:0]  b,

    output reg  [31:0]  c,
    output reg          br,
    output wire         busy
);

    wire [63:0] fast_mul     = a * b;
    wire [63:0] fast_mul_s   = $signed(a) * $signed(b);
    wire [31:0] a_abs_d = a[31] ? (~a + 1'b1) : a;
    wire [31:0] b_abs_d = b[31] ? (~b + 1'b1) : b;
    wire        sign_ab = a[31] ^ b[31];
    wire [31:0] fast_div_s = (b_abs_d != 0) ? a_abs_d / b_abs_d : 32'hFFFFFFFF;
    wire [31:0] fast_div   = (b != 32'd0) ? a / b : 32'hFFFFFFFF;
    wire [31:0] fast_rem_s = (b_abs_d != 0) ? a_abs_d % b_abs_d : a;
    wire [31:0] fast_rem   = (b != 32'd0) ? a % b : a;
    wire [31:0] fast_div_signed = sign_ab ? (~fast_div_s + 1'b1) : fast_div_s;
    wire [31:0] fast_rem_signed = a[31] ? (~fast_rem_s + 1'b1) : fast_rem_s;

    always @(*) begin
        br = 1'b0;
        case (op)
            `ALU_MUL   : c = fast_mul_s[31:0];
            `ALU_MULH  : c = fast_mul_s[63:32];
            `ALU_MULHU : c = fast_mul[63:32];
            `ALU_DIV   : c = fast_div_signed;
            `ALU_DIVU  : c = fast_div;
            `ALU_REM   : c = fast_rem_signed;
            `ALU_REMU  : c = fast_rem;

            `ALU_ADD   : c = a + b;
            `ALU_SUB   : c = a - b;
            `ALU_EQ    : begin c = 32'h0; br = (a == b); end
            `ALU_NE    : begin c = 32'h0; br = (a != b); end
            `ALU_LT    : begin c = 32'h0; br = $signed(a) < $signed(b); end
            `ALU_GE    : begin c = 32'h0; br = $signed(a) >= $signed(b); end
            `ALU_LTU   : begin c = 32'h0; br = (a < b); end
            `ALU_GEU   : begin c = 32'h0; br = (a >= b); end
            `ALU_OR    : c = a | b;
            `ALU_XOR   : c = a ^ b;
            `ALU_SLL   : c = a << b[4:0];
            `ALU_SRL   : c = a >> b[4:0];
            `ALU_SRA   : c = $signed(a) >>> b[4:0];
            `ALU_AND   : c = a & b;
            `ALU_SLT   : c = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            `ALU_SLTU  : c = (a < b) ? 32'd1 : 32'd0;

            default    : c = 32'h0;
        endcase
    end

    assign busy = 1'b0;

endmodule
