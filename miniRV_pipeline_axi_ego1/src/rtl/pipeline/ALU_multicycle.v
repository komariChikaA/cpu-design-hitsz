// -----------------------------------------------------------------------------
// ALU - FPGA/CoreMark 综合版本
// -----------------------------------------------------------------------------
// 普通整数/比较操作为组合逻辑；RV32M 乘除法交给迭代单元，约 32 拍完成。
// busy 会让 cpu_core 保持 EX 指令及前级状态，直到结果可进入 EX/MEM。
// Trace 版本见 ALU_trace.v，由 ALU.v 根据 RUN_TRACE 自动选择。

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

    // 有符号乘除法先取绝对值，复用无符号迭代单元，结束后再按符号修正。
    wire [31:0] a_abs = a[31] ? (~a + 1'b1) : a;
    wire [31:0] b_abs = b[31] ? (~b + 1'b1) : b;
    wire        sign_ab = a[31] ^ b[31];

    // 四个 worker：signed magnitude 乘法、无符号乘法、signed magnitude 除法、无符号除法。
    wire        mul_flag, mulu_flag;
    wire [63:0] mul_res , mulu_res ;
    wire        mul_busy, mulu_busy;
    wire        div_flag, divu_flag;
    wire [31:0] div_quo , divu_quo ;
    wire [31:0] div_rem , divu_rem ;
    wire        div_busy, divu_busy;
    // 多周期期间 EX 级会被冻结；这些寄存器仍显式保存指令类型、符号和原始操作数，
    // 防止相同连续 M 指令或输入组合变化造成结果解释错误。
    reg  [ 4:0] op_r;
    reg         operation_issued;
    reg sign_ab_r;
    reg a_sign_r;
    reg [31:0]  b_r;
    reg [31:0]  a_r;

    // signed magnitude 乘积按两个输入符号异或恢复二进制补码。
    wire [63:0] mul_res_signed = sign_ab_r ? (~mul_res + 1'b1) : mul_res;

    // 结果选择分两条路径：
    // - operation_issued=0：当前是普通组合 ALU 指令；
    // - operation_issued=1：当前 M 指令仍拥有 EX，使用锁存类型解释 worker 结果。
    // 单独的 issued 位不能用 ALU_ADD(0) 代替，因为 ADD 本身是合法指令。
    always @(*) begin
        if (operation_issued) begin
            case (op_r)
                // MUL 返回低 32 位；MULH/MULHU 返回高 32 位。
                `ALU_MUL   : c = mul_res_signed[31:0];
                `ALU_MULH  : c = mul_res_signed[63:32];
                `ALU_MULHU : c = mulu_res[63:32];

                // RISC-V 除零规则：DIV/DIVU 商为全 1，REM/REMU 余数为原被除数。
                `ALU_DIV   : c = (b_r == 32'd0) ? 32'hFFFFFFFF
                                : (sign_ab_r ? (~div_quo + 1'b1) : div_quo);
                `ALU_DIVU  : c = (b_r == 32'd0) ? 32'hFFFFFFFF : divu_quo;
                `ALU_REM   : c = (b_r == 32'd0) ? a_r
                                : (a_sign_r ? (~div_rem + 1'b1) : div_rem);
                `ALU_REMU  : c = (b_r == 32'd0) ? a_r : divu_rem;
                default    : c = 32'h0;
            endcase
        end else begin
            // 单周期组合整数运算。移位量只取 b[4:0]，符合 RV32。
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

    // 条件分支比较与 c 独立。signed/unsigned 关系比较显式区分。
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

    // 任一 worker 正在迭代时 unit_busy=1；operation_start 是启动当拍脉冲。
    wire unit_busy = mul_busy | mulu_busy | div_busy | divu_busy;
    wire operation_start = mul_flag | mulu_flag | div_flag | divu_flag;

    // 每条 M 指令只允许启动一次。!operation_issued 防止冻结期间重复 start，
    // !unit_busy 防止多个 worker 同时占用。
    assign mul_flag  = (op == `ALU_MUL  || op == `ALU_MULH) &&
                       !operation_issued && !unit_busy;
    assign mulu_flag = (op == `ALU_MULHU) &&
                       !operation_issued && !unit_busy;
    assign div_flag  = (op == `ALU_DIV  || op == `ALU_REM) &&
                       !operation_issued && !unit_busy;
    assign divu_flag = (op == `ALU_DIVU || op == `ALU_REMU) &&
                       !operation_issued && !unit_busy;

    // 启动当拍也必须 busy；否则 EX/MEM 会在启动 worker 的同一上升沿吃到旧结果。
    assign busy = operation_start | unit_busy;

    // 启动时锁存符号和原始操作数，供结束时做补码修正与除零处理。
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

    // operation_issued 表示“当前 EX 中的 M 指令已经发给 worker”。
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            op_r             <= `ALU_ADD;
            operation_issued <= 1'b0;
        end else if (operation_start) begin
            op_r <= op;
            operation_issued <= 1'b1;
        end else if (operation_issued && !unit_busy) begin
            // worker 已结束，此上升沿 EX/MEM 锁存结果，同时清 issued。
            // 清除后下一条即使是完全相同的 M 指令也能在下一拍重新启动。
            operation_issued <= 1'b0;
        end
    end

    // 有符号 MUL/MULH：对绝对值做无符号乘，再由 mul_res_signed 恢复符号。
    multiplier #(32) U_mul (
        .clk    (clk),   .rst    (rst),
        .x      (a_abs), .y      (b_abs),
        .start  (mul_flag),
        .z      (mul_res), .busy (mul_busy)
    );

    // 无符号 MULHU。
    multiplier #(32) U_mulu (
        .clk    (clk),   .rst    (rst),
        .x      (a),     .y      (b),
        .start  (mulu_flag),
        .z      (mulu_res), .busy (mulu_busy)
    );

    // 有符号 DIV/REM：绝对值迭代，商/余数符号在结果选择逻辑中恢复。
    divider #(32) U_div (
        .clk    (clk),   .rst    (rst),
        .x      (a_abs), .y      (b_abs),
        .start  (div_flag),
        .z      (div_quo), .r    (div_rem),
        .busy   (div_busy)
    );

    // 无符号 DIVU/REMU。
    divider #(32) U_divu (
        .clk    (clk),   .rst    (rst),
        .x      (a),     .y      (b),
        .start  (divu_flag),
        .z      (divu_quo), .r   (divu_rem),
        .busy   (divu_busy)
    );

endmodule
