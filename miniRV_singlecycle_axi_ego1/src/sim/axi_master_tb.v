`timescale 1ns / 1ps

`include "defines.vh"

module axi_master_tb;
    reg clk = 1'b0;
    always #5 clk = !clk;

    reg rst = 1'b1;
    reg ic_req = 1'b0;
    reg [31:0] ic_addr = 32'h0;
    wire ic_ready;
    wire ic_valid;
    wire [31:0] ic_data;
    reg dc_read = 1'b0;
    reg [31:0] dc_addr = 32'h0;
    wire dc_read_ready;
    wire dc_valid;
    wire [31:0] dc_data;
    reg [3:0] dc_wen = 4'h0;
    reg [31:0] dc_waddr = 32'h0;
    reg [31:0] dc_wdata = 32'h0;
    wire dc_write_ready;
    wire dc_write_resp;

    wire [31:0] awaddr;
    wire [7:0] awlen;
    wire [2:0] awsize;
    wire [1:0] awburst;
    wire awvalid;
    reg awready = 1'b0;
    wire [31:0] wdata;
    wire [3:0] wstrb;
    wire wlast;
    wire wvalid;
    reg wready = 1'b0;
    wire bready;
    reg [1:0] bresp = 2'b00;
    reg bvalid = 1'b0;
    wire [31:0] araddr;
    wire [7:0] arlen;
    wire [2:0] arsize;
    wire [1:0] arburst;
    wire arvalid;
    reg arready = 1'b0;
    wire rready;
    reg [31:0] rdata = 32'h0;
    reg [1:0] rresp = 2'b00;
    reg rlast = 1'b1;
    reg rvalid = 1'b0;

    axi_master dut (
        .aclk(clk), .areset(rst),
        .ic_dev_rrdy(ic_ready), .ic_cpu_ren(ic_req), .ic_cpu_raddr(ic_addr),
        .ic_dev_rvalid(ic_valid), .ic_dev_rdata(ic_data),
        .dc_dev_wrdy(dc_write_ready), .dc_cpu_wen(dc_wen),
        .dc_cpu_waddr(dc_waddr), .dc_cpu_wdata(dc_wdata), .dc_dev_wresp(dc_write_resp),
        .dc_dev_rrdy(dc_read_ready), .dc_cpu_ren(dc_read), .dc_cpu_raddr(dc_addr),
        .dc_dev_rvalid(dc_valid), .dc_dev_rdata(dc_data),
        .m_axi_awaddr(awaddr), .m_axi_awlen(awlen), .m_axi_awsize(awsize),
        .m_axi_awburst(awburst), .m_axi_awvalid(awvalid), .m_axi_awready(awready),
        .m_axi_wdata(wdata), .m_axi_wstrb(wstrb), .m_axi_wlast(wlast),
        .m_axi_wvalid(wvalid), .m_axi_wready(wready),
        .m_axi_bready(bready), .m_axi_bresp(bresp), .m_axi_bvalid(bvalid),
        .m_axi_araddr(araddr), .m_axi_arlen(arlen), .m_axi_arsize(arsize),
        .m_axi_arburst(arburst), .m_axi_arvalid(arvalid), .m_axi_arready(arready),
        .m_axi_rready(rready), .m_axi_rdata(rdata), .m_axi_rresp(rresp),
        .m_axi_rlast(rlast), .m_axi_rvalid(rvalid)
    );

    task fail;
        input [8*80-1:0] message;
        begin
            $display("FAIL: %0s", message);
            $finish;
        end
    endtask

    initial begin
        repeat (3) @(posedge clk);
        rst <= 1'b0;

        // Instruction read: address must align and remain valid under backpressure.
        @(posedge clk); ic_addr <= 32'h0000_0003; ic_req <= 1'b1;
        @(posedge clk); ic_req <= 1'b0;
        repeat (2) @(posedge clk);
        if (!arvalid || araddr != 32'h0000_0000 || arlen != 0 || arsize != 3'b010)
            fail("instruction AR channel");
        arready <= 1'b1;
        @(posedge clk); arready <= 1'b0;
        @(posedge clk); rdata <= 32'h1234_5678; rvalid <= 1'b1;
        @(posedge clk); rvalid <= 1'b0;
        #1 if (!ic_valid || ic_data != 32'h1234_5678) fail("instruction R response");

        // Data read has priority over an instruction request.
        @(posedge clk); dc_addr <= 32'h0000_0012; dc_read <= 1'b1;
                        ic_addr <= 32'h0000_0040; ic_req <= 1'b1;
        @(posedge clk); dc_read <= 1'b0; ic_req <= 1'b0;
        #1 if (araddr != 32'h0000_0010) fail("data-read priority/alignment");
        arready <= 1'b1;
        @(posedge clk); arready <= 1'b0;
        rdata <= 32'ha5a5_5a5a; rvalid <= 1'b1;
        @(posedge clk); rvalid <= 1'b0;
        #1 if (!dc_valid || dc_data != 32'ha5a5_5a5a) fail("data R response");

        // AW and W may complete in different cycles; WSTRB must be preserved.
        @(posedge clk); dc_waddr <= 32'h0000_0023; dc_wdata <= 32'hdead_beef; dc_wen <= 4'b1000;
        @(posedge clk); dc_wen <= 4'h0;
        #1 if (!awvalid || !wvalid || awaddr != 32'h20 || wstrb != 4'b1000) fail("write launch");
        awready <= 1'b1;
        @(posedge clk); awready <= 1'b0;
        #1 if (awvalid || !wvalid) fail("independent AW handshake");
        wready <= 1'b1;
        @(posedge clk); wready <= 1'b0;
        @(posedge clk); bvalid <= 1'b1;
        @(posedge clk); bvalid <= 1'b0;
        #1 if (!dc_write_resp) fail("write response");

        $display("PASS: axi_master_tb");
        $finish;
    end
endmodule
