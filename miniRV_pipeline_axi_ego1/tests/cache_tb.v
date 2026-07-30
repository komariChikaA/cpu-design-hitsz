`timescale 1ns / 1ps

`include "defines.vh"

// Cache 定向测试：验证 refill、命中、write-through 和 MMIO Uncached。
module cache_tb;
    reg clk = 1'b0;
    always #5 clk = !clk;
    reg rst = 1'b1;

`ifdef DUMP_VCD
    initial begin
        $dumpfile("10_cache_refill_hit_uncached.vcd");
        $dumpvars(0, cache_tb);
    end
`endif

    reg         ic_cpu_ren = 1'b0;
    reg [31:0]  ic_cpu_addr = 32'h0;
    wire        ic_cpu_valid;
    wire [31:0] ic_cpu_data;
    wire        ic_dev_ren;
    wire [31:0] ic_dev_addr;
    reg         ic_dev_valid = 1'b0;
    reg [127:0] ic_dev_data = 128'h0;

    ICache U_icache (
        .clk(clk), .rst(rst),
        .cpu_ren(ic_cpu_ren), .cpu_raddr(ic_cpu_addr),
        .cpu_rvalid(ic_cpu_valid), .cpu_rdata(ic_cpu_data),
        .dev_rrdy(1'b1), .dev_ren(ic_dev_ren),
        .dev_raddr(ic_dev_addr), .dev_rvalid(ic_dev_valid),
        .dev_rdata(ic_dev_data)
    );

    reg  [3:0]  dc_cpu_ren = 4'h0;
    reg  [31:0] dc_cpu_addr = 32'h0;
    wire        dc_cpu_valid;
    wire [31:0] dc_cpu_data;
    reg  [3:0]  dc_cpu_wen = 4'h0;
    reg  [31:0] dc_cpu_wdata = 32'h0;
    wire        dc_cpu_wresp;

    wire        dc_dev_ren;
    wire [31:0] dc_dev_raddr;
    wire        dc_dev_uncached;
    reg         dc_dev_rvalid = 1'b0;
    reg [127:0] dc_dev_rdata = 128'h0;
    wire [3:0]  dc_dev_wen;
    wire [31:0] dc_dev_waddr;
    wire [31:0] dc_dev_wdata;
    reg         dc_dev_wresp = 1'b0;

    DCache U_dcache (
        .clk(clk), .rst(rst),
        .cpu_ren(dc_cpu_ren), .cpu_addr(dc_cpu_addr),
        .cpu_rvalid(dc_cpu_valid), .cpu_rdata(dc_cpu_data),
        .cpu_wen(dc_cpu_wen), .cpu_wdata(dc_cpu_wdata),
        .cpu_wresp(dc_cpu_wresp),
        .dev_rrdy(1'b1), .dev_ren(dc_dev_ren),
        .dev_raddr(dc_dev_raddr), .dev_uncached(dc_dev_uncached),
        .dev_rvalid(dc_dev_rvalid), .dev_rdata(dc_dev_rdata),
        .dev_wrdy(1'b1), .dev_wen(dc_dev_wen),
        .dev_waddr(dc_dev_waddr), .dev_wdata(dc_dev_wdata),
        .dev_wresp(dc_dev_wresp)
    );

    task fail;
        input [8*96-1:0] message;
        begin
            $fatal(1, "FAIL: %0s", message);
        end
    endtask

    task ic_refill;
        input [127:0] line;
        begin
            wait (ic_dev_ren);
            // 先让 dev_ren/dev_rrdy 在上升沿握手，使 Cache 进入 WAIT。
            @(posedge clk);
            @(negedge clk);
            ic_dev_data  = line;
            ic_dev_valid = 1'b1;
            @(posedge clk);
            @(negedge clk);
            ic_dev_valid = 1'b0;
        end
    endtask

    task dc_refill;
        input [127:0] line;
        begin
            wait (dc_dev_ren);
            @(posedge clk);
            @(negedge clk);
            dc_dev_rdata  = line;
            dc_dev_rvalid = 1'b1;
            @(posedge clk);
            @(negedge clk);
            dc_dev_rvalid = 1'b0;
        end
    endtask

    integer ic_request_count = 0;
    integer dc_read_request_count = 0;
    always @(posedge clk) begin
        if (ic_dev_ren)
            ic_request_count <= ic_request_count + 1;
        if (dc_dev_ren)
            dc_read_request_count <= dc_read_request_count + 1;
    end

    initial begin
        repeat (3) @(posedge clk);
        rst = 1'b0;

        // ICache 第一次访问 miss：设备侧地址必须按 16-byte line 对齐。
        @(negedge clk);
        ic_cpu_addr = 32'h0000_0024;
        ic_cpu_ren  = 1'b1;
        wait (ic_dev_ren);
        if (ic_dev_addr != 32'h0000_0020)
            fail("ICache refill address");
        ic_refill(128'h4444000c_33330008_22220004_11110000);
        #1;
        if (!ic_cpu_valid || ic_cpu_data != 32'h2222_0004)
            fail("ICache refill result");

        // 同一 line 另一个 word 必须直接命中，不能再次发设备请求。
        @(negedge clk);
        ic_cpu_addr = 32'h0000_002c;
        #1;
        if (!ic_cpu_valid || ic_cpu_data != 32'h4444_000c)
            fail("ICache word select/hit");
        if (ic_request_count != 1)
            fail("ICache hit generated another refill");
        ic_cpu_ren = 1'b0;

        // DCache cached read miss/refill，再读取同一 line 的 word1。
        @(negedge clk);
        dc_cpu_addr = 32'h0000_0044;
        dc_cpu_ren  = 4'hf;
        wait (dc_dev_ren);
        if (dc_dev_uncached || dc_dev_raddr != 32'h0000_0040)
            fail("DCache cached refill request");
        dc_refill(128'hdddd0003_cccc0002_bbbb0001_aaaa0000);
        #1;
        if (!dc_cpu_valid || dc_cpu_data != 32'hbbbb_0001)
            fail("DCache refill result");
        dc_cpu_ren = 4'h0;

        // Write-through 命中：更新 byte lane 1，同时必须向设备发单拍写。
        @(negedge clk);
        dc_cpu_addr  = 32'h0000_0044;
        dc_cpu_wdata = 32'h0000_aa00;
        dc_cpu_wen   = 4'b0010;
        wait (|dc_dev_wen);
        if (dc_dev_waddr != 32'h0000_0044 ||
            dc_dev_wdata != 32'h0000_aa00 || dc_dev_wen != 4'b0010)
            fail("DCache write-through request");
        @(posedge clk);
        @(negedge clk);
        dc_dev_wresp = 1'b1;
        #1;
        if (!dc_cpu_wresp)
            fail("DCache write response");
        @(posedge clk);
        @(negedge clk);
        dc_dev_wresp = 1'b0;
        dc_cpu_wen   = 4'h0;

        // 写命中后的缓存副本必须完成 byte merge，且读取不再 refill。
        dc_cpu_ren = 4'hf;
        #1;
        if (!dc_cpu_valid || dc_cpu_data != 32'hbbbb_aa01)
            fail("DCache write-hit byte merge");
        if (dc_read_request_count != 1)
            fail("DCache hit generated another refill");
        dc_cpu_ren = 4'h0;

        // MMIO 不得进入 Cache：地址按 word 对齐、uncached=1、只取返回低 32 位。
        @(negedge clk);
        dc_cpu_addr = 32'hffff_0002;
        dc_cpu_ren  = 4'hf;
        wait (dc_dev_ren);
        if (!dc_dev_uncached || dc_dev_raddr != 32'hffff_0000)
            fail("DCache MMIO uncached request");
        @(posedge clk);
        @(negedge clk);
        dc_dev_rdata  = 128'h0000_0000_0000_0000_0000_0000_0000_1234;
        dc_dev_rvalid = 1'b1;
        #1;
        if (!dc_cpu_valid || dc_cpu_data != 32'h0000_1234)
            fail("DCache MMIO response");
        @(posedge clk);
        @(negedge clk);
        dc_dev_rvalid = 1'b0;

        $display("PASS: cache_tb");
        $finish;
    end

    initial begin
        repeat (300) @(posedge clk);
        fail("cache_tb timeout");
    end
endmodule
