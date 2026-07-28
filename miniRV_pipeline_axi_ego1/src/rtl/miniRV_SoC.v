`timescale 1ns / 1ps

`include "defines.vh"

module miniRV_SoC(
    input  wire         fpga_clk,
    input  wire         fpga_rst,   // Trace: high active; EGO1: low active
    input  wire [15:0]  sw,
    output wire [15:0]  led,
    output wire [ 7:0]  dig_en,
    output wire [ 7:0]  dig_seg,    // {CA, CB, ..., CG, DP}
    output wire [ 7:0]  dig_seg1,
    input  wire         rx,
    output wire         tx
);

    wire [31:0] m_axi_awaddr;
    wire [ 7:0] m_axi_awlen;
    wire [ 2:0] m_axi_awsize;
    wire [ 1:0] m_axi_awburst;
    wire        m_axi_awvalid;
    wire        m_axi_awready;
    wire [31:0] m_axi_wdata;
    wire [ 3:0] m_axi_wstrb;
    wire        m_axi_wlast;
    wire        m_axi_wvalid;
    wire        m_axi_wready;
    wire        m_axi_bready;
    wire [ 1:0] m_axi_bresp;
    wire        m_axi_bvalid;
    wire [31:0] m_axi_araddr;
    wire [ 7:0] m_axi_arlen;
    wire [ 2:0] m_axi_arsize;
    wire [ 1:0] m_axi_arburst;
    wire        m_axi_arvalid;
    wire        m_axi_arready;
    wire        m_axi_rready;
    wire [31:0] m_axi_rdata;
    wire [ 1:0] m_axi_rresp;
    wire        m_axi_rlast;
    wire        m_axi_rvalid;
    wire [31:0] cpu_debug_pc;
    wire        cpu_debug_ifetch_req;
    wire        cpu_debug_ifetch_valid;
    wire        uart_debug_rx_sync;
    wire [ 1:0] uart_debug_rx_state;
    wire        uart_debug_rx_valid;
    wire [ 7:0] uart_debug_rx_data;

`ifdef RUN_TRACE
    wire sys_clk = fpga_clk;
    wire sys_rst = fpga_rst;

    assign led      = 16'h0;
    assign dig_en   = 8'hff;
    assign dig_seg  = 8'h00;
    assign dig_seg1 = 8'h00;
    assign tx       = 1'b1;

    // The module and instance names are part of the AXI Trace contract.
    bram_axi U_bram (
        .s_aclk          (sys_clk),
        .s_aresetn       (!sys_rst),
        .s_axi_awid      (4'h0),
        .s_axi_awaddr    (m_axi_awaddr),
        .s_axi_awlen     (m_axi_awlen),
        .s_axi_awsize    (m_axi_awsize),
        .s_axi_awburst   (m_axi_awburst),
        .s_axi_awlock    (1'b0),
        .s_axi_awcache   (4'h0),
        .s_axi_awprot    (3'h0),
        .s_axi_awready   (m_axi_awready),
        .s_axi_awvalid   (m_axi_awvalid),
        .s_axi_wdata     (m_axi_wdata),
        .s_axi_wstrb     (m_axi_wstrb),
        .s_axi_wvalid    (m_axi_wvalid),
        .s_axi_wlast     (m_axi_wlast),
        .s_axi_wready    (m_axi_wready),
        .s_axi_bready    (m_axi_bready),
        .s_axi_bid       (),
        .s_axi_bresp     (m_axi_bresp),
        .s_axi_bvalid    (m_axi_bvalid),
        .s_axi_arid      (4'h0),
        .s_axi_araddr    (m_axi_araddr),
        .s_axi_arlen     (m_axi_arlen),
        .s_axi_arsize    (m_axi_arsize),
        .s_axi_arburst   (m_axi_arburst),
        .s_axi_arlock    (1'b0),
        .s_axi_arcache   (4'h0),
        .s_axi_arprot    (3'h0),
        .s_axi_arready   (m_axi_arready),
        .s_axi_arvalid   (m_axi_arvalid),
        .s_axi_rdata     (m_axi_rdata),
        .s_axi_rid       (),
        .s_axi_rvalid    (m_axi_rvalid),
        .s_axi_rlast     (m_axi_rlast),
        .s_axi_rready    (m_axi_rready),
        .s_axi_rresp     (m_axi_rresp)
    );
`else
    wire pll_clk1;
    wire pll_lock;
    wire sys_clk = pll_clk1;
    reg [1:0] reset_sync;
    wire sys_rst = reset_sync[1];

    always @(posedge sys_clk or negedge fpga_rst) begin
        if (!fpga_rst)
            reset_sync <= 2'b11;
        else if (!pll_lock)
            reset_sync <= 2'b11;
        else
            reset_sync <= {reset_sync[0], 1'b0};
    end

    clk_wiz_0 U_clkgen (
        .clk_in1  (fpga_clk),
        .locked   (pll_lock),
        .clk_out1 (pll_clk1)
    );

    axi_board_soc U_board_soc (
        .aclk          (sys_clk),
        .areset        (sys_rst),
        .s_axi_awaddr  (m_axi_awaddr),
        .s_axi_awlen   (m_axi_awlen),
        .s_axi_awsize  (m_axi_awsize),
        .s_axi_awburst (m_axi_awburst),
        .s_axi_awvalid (m_axi_awvalid),
        .s_axi_awready (m_axi_awready),
        .s_axi_wdata   (m_axi_wdata),
        .s_axi_wstrb   (m_axi_wstrb),
        .s_axi_wlast   (m_axi_wlast),
        .s_axi_wvalid  (m_axi_wvalid),
        .s_axi_wready  (m_axi_wready),
        .s_axi_bresp   (m_axi_bresp),
        .s_axi_bvalid  (m_axi_bvalid),
        .s_axi_bready  (m_axi_bready),
        .s_axi_araddr  (m_axi_araddr),
        .s_axi_arlen   (m_axi_arlen),
        .s_axi_arsize  (m_axi_arsize),
        .s_axi_arburst (m_axi_arburst),
        .s_axi_arvalid (m_axi_arvalid),
        .s_axi_arready (m_axi_arready),
        .s_axi_rdata   (m_axi_rdata),
        .s_axi_rresp   (m_axi_rresp),
        .s_axi_rlast   (m_axi_rlast),
        .s_axi_rvalid  (m_axi_rvalid),
        .s_axi_rready  (m_axi_rready),
        .sw            (sw),
        .led           (led),
        .dig_en        (dig_en),
        .dig_seg       (dig_seg),
        .rx            (rx),
        .tx            (tx),
        .uart_debug_rx_sync  (uart_debug_rx_sync),
        .uart_debug_rx_state (uart_debug_rx_state),
        .uart_debug_rx_valid (uart_debug_rx_valid),
        .uart_debug_rx_data  (uart_debug_rx_data)
    );

    assign dig_seg1 = dig_seg;

    // One consolidated probe bus keeps the ILA insertion flow deterministic.
    // Bit mapping is documented in ILA_DEBUG_GUIDE.md.
    (* keep = "true" *) wire ila_clk = sys_clk;
    // RX diagnostics occupy new high bits; the existing [173:0] mapping is
    // intentionally unchanged so previously documented AXI views still work.
    (* mark_debug = "true", keep = "true" *) wire [186:0] ila_probe = {
        rx,
        uart_debug_rx_sync,
        uart_debug_rx_state,
        uart_debug_rx_valid,
        uart_debug_rx_data,
        pll_lock,
        sys_rst,
        cpu_debug_pc,
        cpu_debug_ifetch_req,
        cpu_debug_ifetch_valid,
        m_axi_araddr,
        m_axi_rdata,
        m_axi_arvalid,
        m_axi_arready,
        m_axi_rvalid,
        m_axi_rready,
        m_axi_awaddr,
        m_axi_wdata,
        m_axi_awvalid,
        m_axi_awready,
        m_axi_wvalid,
        m_axi_wready,
        m_axi_bvalid,
        m_axi_bready
    };
`endif

    cpu_top U_cpu (
        .cpu_clk        (sys_clk),
        .cpu_rst        (sys_rst),
        .m_axi_awaddr   (m_axi_awaddr),
        .m_axi_awlen    (m_axi_awlen),
        .m_axi_awsize   (m_axi_awsize),
        .m_axi_awburst  (m_axi_awburst),
        .m_axi_awvalid  (m_axi_awvalid),
        .m_axi_awready  (m_axi_awready),
        .m_axi_wdata    (m_axi_wdata),
        .m_axi_wstrb    (m_axi_wstrb),
        .m_axi_wlast    (m_axi_wlast),
        .m_axi_wvalid   (m_axi_wvalid),
        .m_axi_wready   (m_axi_wready),
        .m_axi_bready   (m_axi_bready),
        .m_axi_bresp    (m_axi_bresp),
        .m_axi_bvalid   (m_axi_bvalid),
        .m_axi_araddr   (m_axi_araddr),
        .m_axi_arlen    (m_axi_arlen),
        .m_axi_arsize   (m_axi_arsize),
        .m_axi_arburst  (m_axi_arburst),
        .m_axi_arvalid  (m_axi_arvalid),
        .m_axi_arready  (m_axi_arready),
        .m_axi_rready   (m_axi_rready),
        .m_axi_rdata    (m_axi_rdata),
        .m_axi_rresp    (m_axi_rresp),
        .m_axi_rlast    (m_axi_rlast),
        .m_axi_rvalid   (m_axi_rvalid),
        .board_debug_pc (cpu_debug_pc),
        .board_debug_ifetch_req   (cpu_debug_ifetch_req),
        .board_debug_ifetch_valid (cpu_debug_ifetch_valid)
    );

endmodule
