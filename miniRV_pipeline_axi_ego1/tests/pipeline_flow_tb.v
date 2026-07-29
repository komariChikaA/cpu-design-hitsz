`timescale 1ns / 1ps

// -----------------------------------------------------------------------------
// 五级流动、EX/MEM/WB 前递和 taken branch 冲刷的定向波形
// -----------------------------------------------------------------------------
// 指令序列：
//   PC 0x00  addi x1,x0,5
//   PC 0x04  addi x2,x1,3       - x1 由前一条前递
//   PC 0x08  add  x3,x2,x1      - 同时观察 MEM/WB 两路相关
//   PC 0x0c  beq  x3,x3,+8      - taken，在 EX 产生 flush
//   PC 0x10  addi x5,x0,99      - 错误路径，必须被冲刷
//   PC 0x14  addi x4,x0,7       - 分支目标
// 波形中应按 valid+PC 追踪 IF/ID/EX/MEM/WB，不要只看数据总线残值。
module pipeline_flow_tb;
    reg clk = 1'b0;
    always #5 clk = !clk;

    initial begin
        $dumpfile("07_pipeline_five_stage_forward_branch.vcd");
        $dumpvars(0, pipeline_flow_tb);
    end

    reg rst = 1'b1;

    wire        ifetch_req;
    wire [31:0] ifetch_addr;
    wire        ifetch_valid = ifetch_req;
    reg  [31:0] imem [0:31];
    wire [31:0] ifetch_inst = imem[ifetch_addr[6:2]];

    wire [3:0]  daccess_ren;
    wire [31:0] daccess_addr;
    wire [3:0]  daccess_wen;
    wire [31:0] daccess_wdata;

    cpu_core dut (
        .cpu_rst        (rst),
        .cpu_clk        (clk),
        .ifetch_req     (ifetch_req),
        .ifetch_addr    (ifetch_addr),
        .ifetch_valid   (ifetch_valid),
        .ifetch_inst    (ifetch_inst),
        .daccess_ren    (daccess_ren),
        .daccess_addr   (daccess_addr),
        .daccess_rvalid (1'b0),
        .daccess_rdata  (32'h0),
        .daccess_wen    (daccess_wen),
        .daccess_wdata  (daccess_wdata),
        .daccess_wresp  (1'b0),
        .board_debug_pc ()
    );

    integer i;
    initial begin
        // 未显式填写的位置全部是无副作用 NOP。
        for (i = 0; i < 32; i = i + 1)
            imem[i] = 32'h0000_0013;

        imem[0] = 32'h0050_0093; // addi x1,x0,5
        imem[1] = 32'h0030_8113; // addi x2,x1,3
        imem[2] = 32'h0011_01b3; // add  x3,x2,x1
        imem[3] = 32'h0031_8463; // beq  x3,x3,+8
        imem[4] = 32'h0630_0293; // addi x5,x0,99（错误路径）
        imem[5] = 32'h0070_0213; // addi x4,x0,7（分支目标）
        imem[6] = 32'h0000_006f; // jal x0,0

        repeat (3) @(posedge clk);
        rst <= 1'b0;

        repeat (35) @(posedge clk);
        #1;

        if (dut.U_RF.regs[1] !== 32'd5)
            $fatal(1, "FAIL: x1 expected 5, actual %h", dut.U_RF.regs[1]);
        if (dut.U_RF.regs[2] !== 32'd8)
            $fatal(1, "FAIL: x2 expected 8, actual %h", dut.U_RF.regs[2]);
        if (dut.U_RF.regs[3] !== 32'd13)
            $fatal(1, "FAIL: x3 expected 13, actual %h", dut.U_RF.regs[3]);
        if (dut.U_RF.regs[4] !== 32'd7)
            $fatal(1, "FAIL: x4 expected 7, actual %h", dut.U_RF.regs[4]);
        if (dut.U_RF.regs[5] !== 32'd0)
            $fatal(1, "FAIL: wrong-path x5 was not flushed, actual %h", dut.U_RF.regs[5]);
        if ((|daccess_ren) || (|daccess_wen))
            $fatal(1, "FAIL: flow test unexpectedly accessed data memory");

        $display("PASS: pipeline_flow_tb");
        $finish;
    end

    // 防止 RTL 问题造成无限仿真。
    initial begin
        repeat (100) @(posedge clk);
        $fatal(1, "FAIL: pipeline_flow_tb timeout");
    end
endmodule
