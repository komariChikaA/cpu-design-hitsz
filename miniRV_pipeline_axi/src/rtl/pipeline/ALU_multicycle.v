// ALU — FPGA 综合版本
// 使用多周期 multiplier / divider 模块，乘除法约 32 拍完成。
// Trace 版本见 ALU_trace.v（组合逻辑，匹配 C 参考模型时序）。
// 由 src/rtl/ALU.v 在非 RUN_TRACE 构建中自动选择。

`timescale 1ns / 1ps
`include "defines.vh"

module ALU_multicycle (
    input  wire         rst,
    input  wire         clk,
    input  wire [ 4:0]  op,
    input  wire [31:0]  a,
    input  wire [31:0]  b,

    output reg  [31:0]  c,
    output reg          br,
    output wire         busy
);

    wire [31:0] a_abs = a[31] ? (~a + 1'b1) : a;
    wire [31:0] b_abs = b[31] ? (~b + 1'b1) : b;
    wire        sign_ab = a[31] ^ b[31];

    wire        mul_flag, mulu_flag;
    wire [63:0] mul_res , mulu_res ;
    wire        mul_busy, mulu_busy;
    wire        div_flag, divu_flag;
    wire [31:0] div_quo , divu_quo ;
    wire [31:0] div_rem , divu_rem ;
    wire        div_busy, divu_busy;
    reg  [ 4:0] op_r;
    reg         operation_issued;
    reg sign_ab_r;
    reg a_sign_r;
    reg [31:0]  b_r;
    reg [31:0]  a_r;

    wire [63:0] mul_res_signed = sign_ab_r ? (~mul_res + 1'b1) : mul_res;

    // Select the latched multi-cycle result only while that instruction owns
    // the EX stage. A separate valid bit avoids overloading ALU_ADD (5'h00)
    // as an "empty" sentinel.
    always @(*) begin
        if (operation_issued) begin
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
                default    : c = 32'h0;
            endcase
        end else begin
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

    wire unit_busy = mul_busy | mulu_busy | div_busy | divu_busy;
    wire operation_start = mul_flag | mulu_flag | div_flag | divu_flag;

    // Assert busy in the launch cycle as well as while a worker is active.
    // Without the launch term the EX/MEM register can consume the old result
    // on the same edge that starts the multiplier or divider.
    assign mul_flag  = (op == `ALU_MUL  || op == `ALU_MULH) &&
                       !operation_issued && !unit_busy;
    assign mulu_flag = (op == `ALU_MULHU) &&
                       !operation_issued && !unit_busy;
    assign div_flag  = (op == `ALU_DIV  || op == `ALU_REM) &&
                       !operation_issued && !unit_busy;
    assign divu_flag = (op == `ALU_DIVU || op == `ALU_REMU) &&
                       !operation_issued && !unit_busy;

    assign busy = operation_start | unit_busy;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sign_ab_r <= 1'b0;
            a_sign_r  <= 1'b0;
            b_r       <= 32'h0;
            a_r       <= 32'h0;
        end else if (operation_start) begin
            sign_ab_r <= sign_ab;
            a_sign_r  <= a[31];
            b_r       <= b;
            a_r       <= a;
        end
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            op_r             <= `ALU_ADD;
            operation_issued <= 1'b0;
        end else if (operation_start) begin
            op_r <= op;
            operation_issued <= 1'b1;
        end else if (operation_issued && !unit_busy) begin
            // The result is consumed by EX/MEM on this edge. Clearing the
            // issued bit here also permits an identical back-to-back M
            // instruction to launch immediately after the edge.
            operation_issued <= 1'b0;
        end
    end

    multiplier #(32) U_mul (
        .clk    (clk),   .rst    (rst),
        .x      (a_abs), .y      (b_abs),
        .start  (mul_flag),
        .z      (mul_res), .busy (mul_busy)
    );

    multiplier #(32) U_mulu (
        .clk    (clk),   .rst    (rst),
        .x      (a),     .y      (b),
        .start  (mulu_flag),
        .z      (mulu_res), .busy (mulu_busy)
    );

    divider #(32) U_div (
        .clk    (clk),   .rst    (rst),
        .x      (a_abs), .y      (b_abs),
        .start  (div_flag),
        .z      (div_quo), .r    (div_rem),
        .busy   (div_busy)
    );

    divider #(32) U_divu (
        .clk    (clk),   .rst    (rst),
        .x      (a),     .y      (b),
        .start  (divu_flag),
        .z      (divu_quo), .r   (divu_rem),
        .busy   (divu_busy)
    );

endmodule
