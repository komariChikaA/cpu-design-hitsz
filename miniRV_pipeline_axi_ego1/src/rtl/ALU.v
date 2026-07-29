`timescale 1ns / 1ps

// -----------------------------------------------------------------------------
// ALU 实现选择器
// -----------------------------------------------------------------------------
// 这个文件本身不计算结果，只根据编译宏选择真正的 ALU：
// 1. cdp-tests 定义 RUN_TRACE：使用组合逻辑 ALU_trace，使 Trace 测试按参考时序完成；
// 2. Vivado 下板不定义 RUN_TRACE：使用 ALU_multicycle，让乘除法按多周期执行。
// cpu_core 只连接统一的 c/br/busy 接口，因此不需要关心当前选择了哪一种实现。
module ALU (
    // 时钟和复位只被多周期实现使用，组合 Trace 实现保留它们以统一端口。
    input  wire         rst,
    input  wire         clk,
    // op 是 defines.vh 中的 ALU_* 功能码；a、b 是 EX 级选好的两个操作数。
    input  wire [ 4:0]  op,
    input  wire [31:0]  a,
    input  wire [31:0]  b,

    // c 是运算结果；br 是分支比较结果；busy=1 要求流水线冻结 EX 指令。
    output wire [31:0]  c,
    output wire         br,
    output wire         busy
);

`ifdef RUN_TRACE
    // Trace 仿真：所有 RV32IM 运算在组合逻辑中直接得到结果，busy 恒为 0。
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
    // FPGA/CoreMark：普通 ALU 仍为组合逻辑，乘除法由迭代单元多周期完成。
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
