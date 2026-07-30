`timescale 1ns / 1ps

module cpu_top_fetch_tb;
    reg clk = 1'b0;
    always #5 clk = !clk;

    reg rst = 1'b1;
    wire [31:0] awaddr;
    wire [7:0] awlen;
    wire [2:0] awsize;
    wire [1:0] awburst;
    wire awvalid;
    wire [31:0] wdata;
    wire [3:0] wstrb;
    wire wlast;
    wire wvalid;
    wire bready;
    wire [31:0] araddr;
    wire [7:0] arlen;
    wire [2:0] arsize;
    wire [1:0] arburst;
    wire arvalid;
    wire rready;

    reg arready = 1'b0;
    reg [31:0] rdata = 32'h0;
    reg rvalid = 1'b0;
    reg rlast = 1'b0;

    cpu_top dut (
        .cpu_clk(clk),
        .cpu_rst(rst),
        .m_axi_awaddr(awaddr),
        .m_axi_awlen(awlen),
        .m_axi_awsize(awsize),
        .m_axi_awburst(awburst),
        .m_axi_awvalid(awvalid),
        .m_axi_awready(1'b0),
        .m_axi_wdata(wdata),
        .m_axi_wstrb(wstrb),
        .m_axi_wlast(wlast),
        .m_axi_wvalid(wvalid),
        .m_axi_wready(1'b0),
        .m_axi_bready(bready),
        .m_axi_bresp(2'b00),
        .m_axi_bvalid(1'b0),
        .m_axi_araddr(araddr),
        .m_axi_arlen(arlen),
        .m_axi_arsize(arsize),
        .m_axi_arburst(arburst),
        .m_axi_arvalid(arvalid),
        .m_axi_arready(arready),
        .m_axi_rready(rready),
        .m_axi_rdata(rdata),
        .m_axi_rresp(2'b00),
        .m_axi_rlast(rlast),
        .m_axi_rvalid(rvalid)
    );

    task fail;
        input [8*96-1:0] message;
        begin
            $fatal(1, "FAIL: %0s", message);
        end
    endtask

    task send_rbeat;
        input [31:0] value;
        input        last;
        begin
            @(negedge clk);
            rdata  = value;
            rlast  = last;
            rvalid = 1'b1;
            @(posedge clk);
            @(negedge clk);
            rvalid = 1'b0;
            rlast  = 1'b0;
        end
    endtask

    integer timeout;
    initial begin
        force dut.cpu2ic_rreq = 1'b0;
        force dut.cpu2ic_addr = 32'h0;

        repeat (3) @(posedge clk);
        rst <= 1'b0;

        @(negedge clk);
        force dut.cpu2ic_rreq = 1'b1;
        force dut.cpu2ic_addr = 32'h0000_0000;

        timeout = 0;
        while (!arvalid) begin
            @(posedge clk);
            timeout = timeout + 1;
            if (timeout > 10)
                fail("first fetch address timed out");
        end
        if (araddr != 32'h0000_0000)
            fail("first fetch address mismatch");
        if (arlen != 8'd3)
            fail("ICache refill must request four beats");

        arready <= 1'b1;
        @(posedge clk);
        arready <= 1'b0;

        // Redirect the core before the old response returns.
        force dut.cpu2ic_addr = 32'h0000_0100;
        send_rbeat(32'h1111_0000, 1'b0);
        send_rbeat(32'h1111_0001, 1'b0);
        send_rbeat(32'h1111_0002, 1'b0);
        send_rbeat(32'h1111_0003, 1'b1);
        #1;
        if (dut.ic2cpu_valid)
            fail("stale fetch response reached the core");

        timeout = 0;
        while (!arvalid) begin
            @(posedge clk);
            timeout = timeout + 1;
            if (timeout > 10)
                fail("redirected fetch address timed out");
        end
        if (araddr != 32'h0000_0100)
            fail("redirected fetch address mismatch");

        arready <= 1'b1;
        @(posedge clk);
        arready <= 1'b0;
        send_rbeat(32'h2222_2222, 1'b0);
        send_rbeat(32'h2222_0001, 1'b0);
        send_rbeat(32'h2222_0002, 1'b0);
        send_rbeat(32'h2222_0003, 1'b1);
        // refill 安装发生在时钟沿，下一拍 ICache 才以 hit 返回 core。
        @(posedge clk);
        #1;
        if (!dut.ic2cpu_valid || dut.ic2cpu_inst != 32'h2222_2222)
            fail("redirected fetch response was not delivered");

        release dut.cpu2ic_rreq;
        release dut.cpu2ic_addr;
        $display("PASS: cpu_top_fetch_tb");
        $finish;
    end
endmodule
