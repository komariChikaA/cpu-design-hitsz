`timescale 1ns / 1ps

module pipeline_hazard_tb;
    reg clk = 1'b0;
    always #5 clk = !clk;

    initial begin
        $dumpfile("06_pipeline_load_use_hazard.vcd");
        $dumpvars(0, pipeline_hazard_tb);
    end

    reg rst = 1'b1;
    wire ifetch_req;
    wire [31:0] ifetch_addr;
    wire ifetch_valid = ifetch_req;
    reg [31:0] imem [0:31];
    wire [31:0] ifetch_inst = imem[ifetch_addr[6:2]];

    wire [3:0] daccess_ren;
    wire [31:0] daccess_addr;
    reg daccess_rvalid = 1'b0;
    reg [31:0] daccess_rdata = 32'h0;
    wire [3:0] daccess_wen;
    wire [31:0] daccess_wdata;

    reg read_pending = 1'b0;
    reg read_request_seen = 1'b0;
    reg [1:0] read_delay = 2'd0;

    cpu_core dut (
        .cpu_rst(rst),
        .cpu_clk(clk),
        .ifetch_req(ifetch_req),
        .ifetch_addr(ifetch_addr),
        .ifetch_valid(ifetch_valid),
        .ifetch_inst(ifetch_inst),
        .daccess_ren(daccess_ren),
        .daccess_addr(daccess_addr),
        .daccess_rvalid(daccess_rvalid),
        .daccess_rdata(daccess_rdata),
        .daccess_wen(daccess_wen),
        .daccess_wdata(daccess_wdata),
        .daccess_wresp(1'b0)
    );

    function [31:0] enc_i;
        input [11:0] imm;
        input [4:0] rs1;
        input [2:0] funct3;
        input [4:0] rd;
        input [6:0] opcode;
        begin
            enc_i = {imm, rs1, funct3, rd, opcode};
        end
    endfunction

    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            imem[i] = 32'h0000_0013;

        // x1 = 0x10; x2 = MEM[0x10] (=42); x3 = x2+1; x4 = x3+2.
        // The ADDI immediately following LW creates a real load-use hazard.
        imem[0] = enc_i(12'd16, 5'd0, 3'b000, 5'd1, 7'b0010011);
        imem[1] = enc_i(12'd0,  5'd1, 3'b010, 5'd2, 7'b0000011);
        imem[2] = enc_i(12'd1,  5'd2, 3'b000, 5'd3, 7'b0010011);
        imem[3] = enc_i(12'd2,  5'd3, 3'b000, 5'd4, 7'b0010011);
        imem[4] = 32'h0000_006f;

        repeat (3) @(posedge clk);
        rst <= 1'b0;

        repeat (45) @(posedge clk);
        #1;
        if (dut.U_RF.regs[2] !== 32'd42)
            $fatal(1, "FAIL: x2 expected 42, actual %h", dut.U_RF.regs[2]);
        if (dut.U_RF.regs[3] !== 32'd43)
            $fatal(1, "FAIL: x3 expected 43, actual %h", dut.U_RF.regs[3]);
        if (dut.U_RF.regs[4] !== 32'd45)
            $fatal(1, "FAIL: x4 expected 45, actual %h", dut.U_RF.regs[4]);

        $display("PASS: pipeline_hazard_tb");
        $finish;
    end

    // Return the load data after two wait cycles so memory_freeze, stall and
    // the dependent-instruction bubble are all visible in the VCD.
    always @(posedge clk) begin
        daccess_rvalid <= 1'b0;
        if (rst) begin
            read_pending <= 1'b0;
            read_request_seen <= 1'b0;
            read_delay <= 2'd0;
            daccess_rdata <= 32'h0;
        end else if (!read_pending && |daccess_ren && !read_request_seen) begin
            read_pending <= 1'b1;
            read_request_seen <= 1'b1;
            read_delay <= 2'd2;
        end else if (read_pending && read_delay != 0) begin
            read_delay <= read_delay - 1'b1;
        end else if (read_pending) begin
            daccess_rdata <= 32'd42;
            daccess_rvalid <= 1'b1;
            read_pending <= 1'b0;
        end else if (!(|daccess_ren)) begin
            read_request_seen <= 1'b0;
        end
    end
endmodule
