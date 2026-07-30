`timescale 1ns / 1ps

// 板端 BRAM burst 定向测试：一个 ARLEN=3 请求必须返回四个递增地址的
// 32-bit beat，并且只在第四拍产生 RLAST。
module board_burst_tb;
    reg clk = 1'b0;
    always #10 clk = !clk; // 50 MHz
    reg rst = 1'b1;

    initial begin
        $dumpfile("11_board_bram_burst.vcd");
        $dumpvars(0, board_burst_tb);
    end

    reg  [31:0] araddr = 32'h0;
    reg  [ 7:0] arlen = 8'h0;
    reg         arvalid = 1'b0;
    wire        arready;
    wire [31:0] rdata;
    wire [ 1:0] rresp;
    wire        rlast;
    wire        rvalid;
    reg         rready = 1'b0;

    wire [15:0] led;
    wire [7:0] dig_en;
    wire [7:0] dig_seg;
    wire tx;

    axi_board_soc U_dut (
        .aclk(clk), .areset(rst),
        .s_axi_awaddr(32'h0), .s_axi_awlen(8'h0),
        .s_axi_awsize(3'b010), .s_axi_awburst(2'b01),
        .s_axi_awvalid(1'b0), .s_axi_awready(),
        .s_axi_wdata(32'h0), .s_axi_wstrb(4'h0),
        .s_axi_wlast(1'b1), .s_axi_wvalid(1'b0), .s_axi_wready(),
        .s_axi_bresp(), .s_axi_bvalid(), .s_axi_bready(1'b0),
        .s_axi_araddr(araddr), .s_axi_arlen(arlen),
        .s_axi_arsize(3'b010), .s_axi_arburst(2'b01),
        .s_axi_arvalid(arvalid), .s_axi_arready(arready),
        .s_axi_rdata(rdata), .s_axi_rresp(rresp),
        .s_axi_rlast(rlast), .s_axi_rvalid(rvalid),
        .s_axi_rready(rready),
        .sw(16'h0), .led(led), .dig_en(dig_en), .dig_seg(dig_seg),
        .rx(1'b1), .tx(tx),
        .uart_debug_rx_sync(), .uart_debug_rx_state(),
        .uart_debug_rx_valid(), .uart_debug_rx_data()
    );

    task fail;
        input [8*96-1:0] message;
        begin
            $fatal(1, "FAIL: %0s", message);
        end
    endtask

    integer beat;
    reg [31:0] expected;
    initial begin
        repeat (4) @(posedge clk);
        rst = 1'b0;
        repeat (2) @(posedge clk);

        @(negedge clk);
        araddr  = 32'h0000_0040;
        arlen   = 8'd3;
        arvalid = 1'b1;
        @(posedge clk);
        while (!arready)
            @(posedge clk);

        @(negedge clk);
        arvalid = 1'b0;
        rready  = 1'b1;

        for (beat = 0; beat < 4; beat = beat + 1) begin
            @(posedge clk);
            while (!rvalid)
                @(posedge clk);
            // IROM 仿真 stub 返回 word address：0x40/4 = 0x10。
            expected = 32'h10 + beat;
            if (rresp != 2'b00 || rdata !== expected)
                fail("board BRAM burst data/response");
            if ((beat < 3 && rlast) || (beat == 3 && !rlast))
                fail("board BRAM burst RLAST position");
        end

        @(negedge clk);
        rready = 1'b0;
        $display("PASS: board_burst_tb");
        $finish;
    end

    initial begin
        repeat (100) @(posedge clk);
        fail("board_burst_tb timeout");
    end

    wire _unused = &{1'b0, led, dig_en, dig_seg, tx};
endmodule
