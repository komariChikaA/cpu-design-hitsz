`timescale 1ns / 1ps

`include "defines.vh"

module ALU (
    input  wire         rst,
    input  wire         clk,
    input  wire [ 4:0]  op,
    input  wire [31:0]  a,
    input  wire [31:0]  b,

    output reg  [31:0]  c,
    output reg          br,
    output wire         busy
);

    wire        mul_flag, mulu_flag;
    wire [63:0] mul_res , mulu_res ;
    wire        mul_busy, mulu_busy;
    wire        div_flag, divu_flag;
    wire [31:0] div_quo , divu_quo ;
    wire [31:0] div_rem , divu_rem ;
    wire        div_busy, divu_busy;
    reg  [ 4:0] op_r;
    reg         busy_d;
    reg sign_ab_r;
    reg a_sign_r;
    reg [31:0]  b_r;
    reg [31:0]  a_r;

    wire [31:0] a_abs = a[31] ? (~a + 1'b1) : a;
    wire [31:0] b_abs = b[31] ? (~b + 1'b1) : b;
    wire        sign_ab = a[31] ^ b[31];
    wire [63:0] mul_res_signed = sign_ab_r ? (~mul_res + 1'b1) : mul_res;

    always @(*) begin
        case (op_r)
            `ALU_MUL   : c = mul_res_signed[31:0];
            `ALU_MULH  : c = mul_res_signed[63:32];
            `ALU_MULHU : c = mulu_res[63:32];

            `ALU_DIV   : c = (b_r == 32'd0) ? 32'hFFFFFFFF
                            : (sign_ab_r ? (~div_quo + 1'b1) : div_quo);
            `ALU_DIVU  : c = (b_r == 32'd0) ? 32'hFFFFFFFF : divu_quo;
            `ALU_REM   : c = (b_r == 32'd0) ? a_r
                            : (a_sign_r ? (~div_rem + 1'b1) : div_rem);
            `ALU_REMU  : c = (b_r == 32'd0) ? a_r : divu_rem;

            default    : begin
                case (op)
                    `ALU_ADD  : c = a + b;
                    `ALU_SUB  : c = a - b;
                    `ALU_OR   : c = a | b;
                    `ALU_XOR  : c = a ^ b;
                    `ALU_SLL  : c = a << b[4:0];
                    `ALU_SRL  : c = a >> b[4:0];
                    `ALU_SRA  : c = $signed(a) >>> b[4:0];
                    `ALU_AND  : c = a & b;
                    `ALU_SLT  : c = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
                    `ALU_SLTU : c = (a < b) ? 32'd1 : 32'd0;
                    default   : c = 32'h0;
                endcase
            end
        endcase
    end

    always @(*) begin
        case (op)
            `ALU_EQ  : br = (a == b);
            `ALU_NE  : br = (a != b);
            `ALU_LT  : br = $signed(a) < $signed(b);
            `ALU_GE  : br = $signed(a) >= $signed(b);
            `ALU_LTU : br = (a < b);
            `ALU_GEU : br = (a >= b);
            default  : br = 1'b0;
        endcase
    end

    assign mul_flag  = (op == `ALU_MUL  || op == `ALU_MULH)  && ~busy;
    assign mulu_flag = (op == `ALU_MULHU)                    && ~busy;
    // Keep division-by-zero operations in the normal multi-cycle handshake.
    // The divider and the result mux below already implement the RISC-V
    // quotient/remainder values for a zero divisor.  Suppressing start here
    // would also suppress operand/opcode latching and incorrectly write zero.
    assign div_flag  = (op == `ALU_DIV  || op == `ALU_REM)  && ~busy;
    assign divu_flag = (op == `ALU_DIVU || op == `ALU_REMU) && ~busy;

    assign busy = mul_busy | mulu_busy | div_busy | divu_busy;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sign_ab_r <= 1'b0;
            a_sign_r  <= 1'b0;
            b_r       <= 32'h0;
            a_r       <= 32'h0;
        end else if (mul_flag | mulu_flag | div_flag | divu_flag) begin
            sign_ab_r <= sign_ab;
            a_sign_r  <= a[31];
            b_r       <= b;
            a_r       <= a;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            busy_d <= 1'b0;
        end else begin
            busy_d <= busy;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            op_r <= 5'h0;
        end else if (mul_flag | mulu_flag | div_flag | divu_flag) begin
            op_r <= op;
        end else if (busy_d && !busy) begin
            op_r <= op_r;
        end else if (!busy) begin
            op_r <= 5'h0;
        end
    end


    multiplier #(32) U_mul (
        .clk    (clk),
        .rst    (rst),
        .x      (a_abs),
        .y      (b_abs),
        .start  (mul_flag),
        .z      (mul_res),
        .busy   (mul_busy)
    );

    multiplier #(32) U_mulu (
        .clk    (clk),
        .rst    (rst),
        .x      (a),
        .y      (b),
        .start  (mulu_flag),
        .z      (mulu_res),
        .busy   (mulu_busy)
    );

    divider #(32) U_div (
        .clk    (clk),
        .rst    (rst),
        .x      (a_abs),
        .y      (b_abs),
        .start  (div_flag),
        .z      (div_quo),
        .r      (div_rem),
        .busy   (div_busy)
    );

    divider #(32) U_divu (
        .clk    (clk),
        .rst    (rst),
        .x      (a),
        .y      (b),
        .start  (divu_flag),
        .z      (divu_quo),
        .r      (divu_rem),
        .busy   (divu_busy)
    );

endmodule
