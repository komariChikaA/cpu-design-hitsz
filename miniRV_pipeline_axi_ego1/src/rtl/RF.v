`timescale 1ns / 1ps

module RF (
    // ID 级异步读、WB 级上升沿同步写的 32×32 寄存器堆。
    input  wire         clk,
    input  wire         rst,

    // 两个读地址来自当前 ID 指令的 rs1/rs2。
    input  wire [ 4:0]  rR1,
    input  wire [ 4:0]  rR2,
    // 写端口来自 WB：we=1 且 wR!=0 时在上升沿提交。
    input  wire         we,
    input  wire [ 4:0]  wR,
    input  wire [31:0]  wD,

    output wire [31:0]  rD1,
    output wire [31:0]  rD2
);

    // x0 不需要真实存储，所以只实现 x1~x31。
    reg [31:0] regs [1:31];

    // 组合读；读取 x0 时强制返回 0，满足 RISC-V 规范。
    assign rD1 = (rR1 == 0) ? 0 : regs[rR1];
    assign rD2 = (rR2 == 0) ? 0 : regs[rR2];

    integer i;
    // 复位清空 x1~x31；正常周期只允许 WB 写一个寄存器，写 x0 被丢弃。
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 1; i < 32; i = i + 1)
                regs[i] <= 32'h0;
        end else if (we && (wR != 5'h0)) begin
            regs[wR] <= wD;
        end
    end

endmodule
