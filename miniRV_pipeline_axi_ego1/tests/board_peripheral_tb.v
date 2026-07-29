`timescale 1ns / 1ps

`include "defines.vh"

// -----------------------------------------------------------------------------
// AXI 板级外设定向波形
// -----------------------------------------------------------------------------
// 不运行 CPU 软件，直接用 AXI task 访问最终 axi_board_soc，便于在短 VCD 中看到：
// LED/数码管 MMIO 写、switch/timer/UART 状态读、UART TX 帧和 UART RX 字节提交。
module board_peripheral_tb;
    reg clk = 1'b0;
    always #10 clk = !clk; // 50 MHz

    initial begin
        $dumpfile("09_board_peripheral_mmio_uart.vcd");
        $dumpvars(0, board_peripheral_tb);
    end

    reg rst = 1'b1;

    reg  [31:0] awaddr = 32'h0;
    reg  [ 7:0] awlen = 8'h0;
    reg  [ 2:0] awsize = 3'b010;
    reg  [ 1:0] awburst = 2'b01;
    reg         awvalid = 1'b0;
    wire        awready;

    reg  [31:0] wdata = 32'h0;
    reg  [ 3:0] wstrb = 4'h0;
    reg         wlast = 1'b1;
    reg         wvalid = 1'b0;
    wire        wready;

    wire [1:0]  bresp;
    wire        bvalid;
    reg         bready = 1'b0;

    reg  [31:0] araddr = 32'h0;
    reg  [ 7:0] arlen = 8'h0;
    reg  [ 2:0] arsize = 3'b010;
    reg  [ 1:0] arburst = 2'b01;
    reg         arvalid = 1'b0;
    wire        arready;

    wire [31:0] rdata;
    wire [ 1:0] rresp;
    wire        rlast;
    wire        rvalid;
    reg         rready = 1'b0;

    reg  [15:0] sw = 16'h1234;
    wire [15:0] led;
    wire [ 7:0] dig_en;
    wire [ 7:0] dig_seg;
    reg         rx = 1'b1;
    wire        tx;
    wire        rx_sync;
    wire [ 1:0] rx_state;
    wire        rx_valid;
    wire [ 7:0] rx_data;

    axi_board_soc dut (
        .aclk          (clk),
        .areset        (rst),
        .s_axi_awaddr  (awaddr),
        .s_axi_awlen   (awlen),
        .s_axi_awsize  (awsize),
        .s_axi_awburst (awburst),
        .s_axi_awvalid (awvalid),
        .s_axi_awready (awready),
        .s_axi_wdata   (wdata),
        .s_axi_wstrb   (wstrb),
        .s_axi_wlast   (wlast),
        .s_axi_wvalid  (wvalid),
        .s_axi_wready  (wready),
        .s_axi_bresp   (bresp),
        .s_axi_bvalid  (bvalid),
        .s_axi_bready  (bready),
        .s_axi_araddr  (araddr),
        .s_axi_arlen   (arlen),
        .s_axi_arsize  (arsize),
        .s_axi_arburst (arburst),
        .s_axi_arvalid (arvalid),
        .s_axi_arready (arready),
        .s_axi_rdata   (rdata),
        .s_axi_rresp   (rresp),
        .s_axi_rlast   (rlast),
        .s_axi_rvalid  (rvalid),
        .s_axi_rready  (rready),
        .sw            (sw),
        .led           (led),
        .dig_en        (dig_en),
        .dig_seg       (dig_seg),
        .rx            (rx),
        .tx            (tx),
        .uart_debug_rx_sync  (rx_sync),
        .uart_debug_rx_state (rx_state),
        .uart_debug_rx_valid (rx_valid),
        .uart_debug_rx_data  (rx_data)
    );

    // 完成一次 AW+W 同拍发起、B 响应结束的单拍写事务。
    task axi_write;
        input [31:0] addr;
        input [31:0] data;
        input [ 3:0] strb;
        begin
            // 所有主机驱动都在 negedge 改变，所有握手都在 posedge 判定，
            // 避免 testbench 与 Slave 的时序 always 块在同一仿真区竞争。
            @(negedge clk);
            awaddr  = addr;
            wdata   = data;
            wstrb   = strb;
            awvalid = 1'b1;
            wvalid  = 1'b1;

            // 保持 AWVALID/WVALID，直到某个上升沿两个 READY 同时有效。
            @(posedge clk);
            while (!(awready && wready))
                @(posedge clk);

            // 地址和数据已经被接收，撤销请求并准备接收 B 响应。
            @(negedge clk);
            awvalid = 1'b0;
            wvalid  = 1'b0;
            bready = 1'b1;

            // bvalid 可能已经在 AW/W 握手沿置位；在后续上升沿采样响应。
            @(posedge clk);
            while (!bvalid)
                @(posedge clk);
            if (bresp != 2'b00)
                $fatal(1, "FAIL: AXI write DECERR at %h", addr);

            @(negedge clk);
            bready = 1'b0;
        end
    endtask

    // 完成一次 AR/R 读事务，并把返回数据写入 task output。
    task axi_read;
        input  [31:0] addr;
        output [31:0] data;
        begin
            @(negedge clk);
            araddr  = addr;
            arvalid = 1'b1;

            // 在上升沿确认 AR 握手，随后撤销 ARVALID 并拉高 RREADY。
            @(posedge clk);
            while (!arready)
                @(posedge clk);
            @(negedge clk);
            arvalid = 1'b0;
            rready  = 1'b1;

            // MMIO 可快速返回，BRAM 则可能多等待一拍；统一等 RVALID。
            @(posedge clk);
            while (!rvalid)
                @(posedge clk);
            data = rdata;
            if (rresp != 2'b00 || !rlast)
                $fatal(1, "FAIL: AXI read response at %h", addr);

            @(negedge clk);
            rready = 1'b0;
        end
    endtask

    localparam integer CLKS_PER_BIT = 50_000_000 / 115_200;

    // 从上位机方向向 DUT.rx 发送一个 8N1、LSB-first 字节。
    task send_uart_byte;
        input [7:0] value;
        integer bit_index;
        begin
            @(negedge clk);
            rx = 1'b0; // start
            repeat (CLKS_PER_BIT) @(posedge clk);
            for (bit_index = 0; bit_index < 8; bit_index = bit_index + 1) begin
                @(negedge clk);
                rx = value[bit_index];
                repeat (CLKS_PER_BIT) @(posedge clk);
            end
            @(negedge clk);
            rx = 1'b1; // stop
            repeat (CLKS_PER_BIT) @(posedge clk);
        end
    endtask

    reg [31:0] read_value;
    reg [31:0] timer_low_0;
    reg [31:0] timer_low_1;
    integer test_stage = 0;

    initial begin
        repeat (5) @(posedge clk);
        rst <= 1'b0;
        repeat (3) @(posedge clk);

        // LED 和数码管写：波形中观察 write_accept、WSTRB、寄存器和物理输出。
        test_stage = 1;
        $display("INFO: board_peripheral_tb stage 1 LED/digled");
        axi_write(`PERI_ADDR_LED,    32'h0000_00a5, 4'b0011);
        axi_write(`PERI_ADDR_DIGLED, 32'h600d_600d, 4'b1111);
        if (led !== 16'h00a5 || dut.digled_reg !== 32'h600d_600d)
            $fatal(1, "FAIL: LED/digled MMIO write");

        // switch 和 timer 读：观察 AR 握手后同拍准备 MMIO R 数据。
        test_stage = 2;
        $display("INFO: board_peripheral_tb stage 2 switch/timer");
        axi_read(`PERI_ADDR_SWITCH, read_value);
        if (read_value !== 32'h0000_1234)
            $fatal(1, "FAIL: switch read %h", read_value);
        axi_read(`PERI_ADDR_TIMER, timer_low_0);
        repeat (8) @(posedge clk);
        axi_read(`PERI_ADDR_TIMER, timer_low_1);
        if (timer_low_1 <= timer_low_0)
            $fatal(1, "FAIL: timer did not advance");

        // TX：向 UART+4 写 0x55，观察 tx_active、bit_index 和串行 tx。
        test_stage = 3;
        $display("INFO: board_peripheral_tb stage 3 UART TX");
        axi_write(`PERI_ADDR_UART + 32'h4, 32'h0000_0055, 4'b0001);
        wait (dut.uart_tx_busy);
        wait (!dut.uart_tx_busy);

        // RX：串行发送 'A'，先读状态确认 valid，再读 FIFO 并触发 rx_pop。
        test_stage = 4;
        $display("INFO: board_peripheral_tb stage 4 UART RX serial frame");
        send_uart_byte(8'h41);
        wait (rx_valid);
        test_stage = 5;
        $display("INFO: board_peripheral_tb stage 5 UART status/data MMIO");
        axi_read(`PERI_ADDR_UART + 32'h8, read_value);
        if (!read_value[0])
            $fatal(1, "FAIL: UART status did not report RX data");
        axi_read(`PERI_ADDR_UART + 32'h0, read_value);
        if (read_value[7:0] !== 8'h41)
            $fatal(1, "FAIL: UART RX expected 41, actual %h", read_value[7:0]);

        repeat (4) @(posedge clk);
        test_stage = 6;
        $display("PASS: board_peripheral_tb");
        $finish;
    end

    initial begin
        repeat (20_000) @(posedge clk);
        $display(
            "DEBUG: stage=%0d bvalid=%b rvalid=%b tx_busy=%b rx_state=%0d rx_valid=%b rx_data=%h",
            test_stage, bvalid, rvalid, dut.uart_tx_busy, rx_state, rx_valid, rx_data
        );
        $fatal(1, "FAIL: board_peripheral_tb timeout");
    end

    wire _unused = &{1'b0, tx, dig_en, dig_seg, rx_sync, rx_state, rx_data};
endmodule
