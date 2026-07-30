`timescale 1ns / 1ps

module cpu_core_mext_tb;
    reg clk = 1'b0;
    always #5 clk = !clk;

    reg rst = 1'b1;
    wire ifetch_req;
    wire [31:0] ifetch_addr;
    wire ifetch_valid = ifetch_req;
    reg [31:0] imem [0:63];
    wire [31:0] ifetch_inst = imem[ifetch_addr[7:2]];

    wire [3:0] daccess_ren;
    wire [31:0] daccess_addr;
    wire [3:0] daccess_wen;
    wire [31:0] daccess_wdata;

    cpu_core dut (
        .cpu_rst(rst),
        .cpu_clk(clk),
        .ifetch_req(ifetch_req),
        .ifetch_addr(ifetch_addr),
        .ifetch_valid(ifetch_valid),
        .ifetch_inst(ifetch_inst),
        .daccess_ren(daccess_ren),
        .daccess_addr(daccess_addr),
        .daccess_rvalid(1'b0),
        .daccess_rdata(32'h0),
        .daccess_wen(daccess_wen),
        .daccess_wdata(daccess_wdata),
        .daccess_wresp(1'b0)
    );

    function [31:0] enc_i;
        input [11:0] imm;
        input [4:0] rs1;
        input [2:0] funct3;
        input [4:0] rd;
        begin
            enc_i = {imm, rs1, funct3, rd, 7'b0010011};
        end
    endfunction

    function [31:0] enc_r;
        input [6:0] funct7;
        input [4:0] rs2;
        input [4:0] rs1;
        input [2:0] funct3;
        input [4:0] rd;
        begin
            enc_r = {funct7, rs2, rs1, funct3, rd, 7'b0110011};
        end
    endfunction

    function [31:0] enc_lui;
        input [19:0] imm;
        input [4:0] rd;
        begin
            enc_lui = {imm, rd, 7'b0110111};
        end
    endfunction

    task expect_reg;
        input [4:0] index;
        input [31:0] expected;
        begin
            if (dut.U_RF.regs[index] !== expected)
                $fatal(1, "FAIL: x%0d expected=%h actual=%h",
                       index, expected, dut.U_RF.regs[index]);
        end
    endtask

`ifdef RUN_TRACE
    // A held WB pipeline register is not a second architectural commit.
    always @(posedge clk) begin
        if (!rst && dut.effective_freeze && dut.debug_wb_rf_we)
            $fatal(1, "FAIL: Trace reported a duplicate WB commit while frozen");
    end
`endif

    integer i;
    initial begin
        for (i = 0; i < 64; i = i + 1)
            imem[i] = 32'h0000_0013;

        imem[0]  = enc_i(12'd6,     5'd0, 3'b000, 5'd1);
        imem[1]  = enc_i(12'd7,     5'd0, 3'b000, 5'd2);
        imem[2]  = enc_r(7'b0000001, 5'd2, 5'd1, 3'b000, 5'd3);
        imem[3]  = enc_i(12'd1,     5'd3, 3'b000, 5'd4);
        imem[4]  = enc_r(7'b0000001, 5'd1, 5'd3, 3'b100, 5'd5);
        imem[5]  = enc_r(7'b0000001, 5'd2, 5'd3, 3'b110, 5'd6);
        imem[6]  = enc_r(7'b0000001, 5'd0, 5'd1, 3'b100, 5'd7);
        imem[7]  = enc_r(7'b0000001, 5'd0, 5'd2, 3'b110, 5'd8);
        imem[8]  = enc_r(7'b0000001, 5'd2, 5'd1, 3'b000, 5'd9);
        imem[9]  = enc_r(7'b0000001, 5'd2, 5'd1, 3'b000, 5'd10);
        imem[10] = enc_i(12'hffe,   5'd0, 3'b000, 5'd11);
        imem[11] = enc_i(12'd3,     5'd0, 3'b000, 5'd12);
        imem[12] = enc_r(7'b0000001, 5'd12, 5'd11, 3'b001, 5'd13);
        imem[13] = enc_lui(20'h80000, 5'd14);
        imem[14] = enc_i(12'd2,     5'd0, 3'b000, 5'd15);
        imem[15] = enc_r(7'b0000001, 5'd15, 5'd14, 3'b011, 5'd16);
        imem[16] = enc_i(12'hfff,   5'd0, 3'b000, 5'd17);
        imem[17] = enc_r(7'b0000001, 5'd17, 5'd14, 3'b100, 5'd18);
        imem[18] = enc_r(7'b0000001, 5'd17, 5'd14, 3'b110, 5'd19);
        imem[19] = 32'h0000_006f;

        repeat (3) @(posedge clk);
        rst <= 1'b0;

        repeat (900) @(posedge clk);
        #1;

        expect_reg(5'd3,  32'd42);
        expect_reg(5'd4,  32'd43);
        expect_reg(5'd5,  32'd7);
        expect_reg(5'd6,  32'd0);
        expect_reg(5'd7,  32'hffff_ffff);
        expect_reg(5'd8,  32'd7);
        expect_reg(5'd9,  32'd42);
        expect_reg(5'd10, 32'd42);
        expect_reg(5'd11, 32'hffff_fffe);
        expect_reg(5'd12, 32'd3);
        expect_reg(5'd13, 32'hffff_ffff);
        expect_reg(5'd16, 32'd1);
        expect_reg(5'd18, 32'h8000_0000);
        expect_reg(5'd19, 32'd0);

        if (daccess_ren != 4'h0 || daccess_wen != 4'h0)
            $display("NOTE: data interface is active after the test program");

        $display("PASS: cpu_core_mext_tb");
        $finish;
    end
endmodule
