`timescale 1ns / 1ps

// Synthesizable full CPU + AXI board-peripheral harness for Yosys `sim`.
// It boots the exact board image and sends one UART byte (0x41) after the
// firmware has reached its polling loop.
module uart_system_tb (
    input  wire        clk,
    input  wire        rst,
    output wire [15:0] observed_led,
    output wire        observed_tx,
    output wire        observed_rx_valid,
    output wire [ 7:0] observed_rx_data,
    output wire [31:0] observed_pc,
    output wire [31:0] observed_araddr,
    output wire [31:0] observed_rdata,
    output wire        observed_arvalid,
    output wire        observed_rvalid
);
    wire [31:0] awaddr;
    wire [ 7:0] awlen;
    wire [ 2:0] awsize;
    wire [ 1:0] awburst;
    wire        awvalid;
    wire        awready;
    wire [31:0] wdata;
    wire [ 3:0] wstrb;
    wire        wlast;
    wire        wvalid;
    wire        wready;
    wire [ 1:0] bresp;
    wire        bvalid;
    wire        bready;
    wire [31:0] araddr;
    wire [ 7:0] arlen;
    wire [ 2:0] arsize;
    wire [ 1:0] arburst;
    wire        arvalid;
    wire        arready;
    wire [31:0] rdata;
    wire [ 1:0] rresp;
    wire        rlast;
    wire        rvalid;
    wire        rready;
    wire [ 7:0] dig_en;
    wire [ 7:0] dig_seg;
    wire        rx_sync;
    wire [ 1:0] rx_state;
    wire        rx_valid;
    wire [ 7:0] rx_data;
    wire        ifetch_req;
    wire        ifetch_valid;

    localparam integer CLKS_PER_BIT = 50_000_000 / 115_200;
    localparam integer SEND_AT_CYCLE = 10_000;
    localparam [9:0] UART_A_FRAME = {1'b1, 8'h41, 1'b0};

    reg [31:0] cycle_count;
    reg [15:0] uart_count;
    reg [ 3:0] uart_bit;
    reg        uart_sending;
    reg        rx;

    always @(posedge clk) begin
        if (rst) begin
            cycle_count  <= 32'h0;
            uart_count   <= 16'h0;
            uart_bit     <= 4'h0;
            uart_sending <= 1'b0;
            rx           <= 1'b1;
        end else begin
            cycle_count <= cycle_count + 32'd1;

            if (!uart_sending && cycle_count == SEND_AT_CYCLE) begin
                uart_sending <= 1'b1;
                uart_count   <= 16'h0;
                uart_bit     <= 4'h0;
                rx           <= UART_A_FRAME[0];
            end else if (uart_sending) begin
                if (uart_count == CLKS_PER_BIT - 1) begin
                    uart_count <= 16'h0;
                    if (uart_bit == 4'd9) begin
                        uart_sending <= 1'b0;
                        rx           <= 1'b1;
                    end else begin
                        uart_bit <= uart_bit + 4'd1;
                        rx       <= UART_A_FRAME[uart_bit + 4'd1];
                    end
                end else begin
                    uart_count <= uart_count + 16'd1;
                end
            end
        end
    end

    cpu_top U_cpu (
        .cpu_clk(clk),
        .cpu_rst(rst),
        .m_axi_awaddr(awaddr),
        .m_axi_awlen(awlen),
        .m_axi_awsize(awsize),
        .m_axi_awburst(awburst),
        .m_axi_awvalid(awvalid),
        .m_axi_awready(awready),
        .m_axi_wdata(wdata),
        .m_axi_wstrb(wstrb),
        .m_axi_wlast(wlast),
        .m_axi_wvalid(wvalid),
        .m_axi_wready(wready),
        .m_axi_bready(bready),
        .m_axi_bresp(bresp),
        .m_axi_bvalid(bvalid),
        .m_axi_araddr(araddr),
        .m_axi_arlen(arlen),
        .m_axi_arsize(arsize),
        .m_axi_arburst(arburst),
        .m_axi_arvalid(arvalid),
        .m_axi_arready(arready),
        .m_axi_rready(rready),
        .m_axi_rdata(rdata),
        .m_axi_rresp(rresp),
        .m_axi_rlast(rlast),
        .m_axi_rvalid(rvalid),
        .board_debug_pc(observed_pc),
        .board_debug_ifetch_req(ifetch_req),
        .board_debug_ifetch_valid(ifetch_valid)
    );

    axi_board_soc U_board (
        .aclk(clk),
        .areset(rst),
        .s_axi_awaddr(awaddr),
        .s_axi_awlen(awlen),
        .s_axi_awsize(awsize),
        .s_axi_awburst(awburst),
        .s_axi_awvalid(awvalid),
        .s_axi_awready(awready),
        .s_axi_wdata(wdata),
        .s_axi_wstrb(wstrb),
        .s_axi_wlast(wlast),
        .s_axi_wvalid(wvalid),
        .s_axi_wready(wready),
        .s_axi_bresp(bresp),
        .s_axi_bvalid(bvalid),
        .s_axi_bready(bready),
        .s_axi_araddr(araddr),
        .s_axi_arlen(arlen),
        .s_axi_arsize(arsize),
        .s_axi_arburst(arburst),
        .s_axi_arvalid(arvalid),
        .s_axi_arready(arready),
        .s_axi_rdata(rdata),
        .s_axi_rresp(rresp),
        .s_axi_rlast(rlast),
        .s_axi_rvalid(rvalid),
        .s_axi_rready(rready),
        .sw(16'h0),
        .led(observed_led),
        .dig_en(dig_en),
        .dig_seg(dig_seg),
        .rx(rx),
        .tx(observed_tx),
        .uart_debug_rx_sync(rx_sync),
        .uart_debug_rx_state(rx_state),
        .uart_debug_rx_valid(rx_valid),
        .uart_debug_rx_data(rx_data)
    );

    assign observed_rx_valid = rx_valid;
    assign observed_rx_data  = rx_data;
    assign observed_araddr   = araddr;
    assign observed_rdata    = rdata;
    assign observed_arvalid  = arvalid;
    assign observed_rvalid   = rvalid;

    wire _unused = &{1'b0, dig_en, dig_seg, rx_sync, rx_state,
                     ifetch_req, ifetch_valid};
endmodule

// Behavioral signatures for board_bram.  The system test image contains the
// first 256 words of the real board image; this diagnostic executes entirely
// inside that range.
module IROM (
    input  wire        clka,
    input  wire [13:0] addra,
    output reg  [31:0] douta
);
    reg [31:0] memory [0:16383];
    initial
        $readmemh("outputs/uart_system_irom.mem",
                  memory);
    always @(posedge clka)
        douta <= memory[addra];
endmodule

module DRAM (
    input  wire        clka,
    input  wire [ 3:0] wea,
    input  wire [14:0] addra,
    input  wire [31:0] dina,
    output reg  [31:0] douta
);
    // The physical BMG has a 15-bit address port.  IROM accesses can underflow
    // the subtractor feeding this unused DRAM port, so model the complete port
    // range even though only 25,600 entries are architecturally addressable.
    reg [31:0] memory [0:32767];
    initial
        $readmemh("outputs/uart_system_dram.mem",
                  memory);
    always @(posedge clka) begin
        if (wea[0]) memory[addra][ 7: 0] <= dina[ 7: 0];
        if (wea[1]) memory[addra][15: 8] <= dina[15: 8];
        if (wea[2]) memory[addra][23:16] <= dina[23:16];
        if (wea[3]) memory[addra][31:24] <= dina[31:24];
        douta <= memory[addra];
    end
endmodule
