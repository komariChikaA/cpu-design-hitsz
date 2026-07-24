`timescale 1ns / 1ps

`include "defines.vh"

module cpu_top(
    input  wire         cpu_clk,
    input  wire         cpu_rst,        // high active

    // AXI4 master write address channel
    output wire [31:0]  m_axi_awaddr,
    output wire [ 7:0]  m_axi_awlen,
    output wire [ 2:0]  m_axi_awsize,
    output wire [ 1:0]  m_axi_awburst,
    output wire         m_axi_awvalid,
    input  wire         m_axi_awready,

    // AXI4 master write data channel
    output wire [31:0]  m_axi_wdata,
    output wire [ 3:0]  m_axi_wstrb,
    output wire         m_axi_wlast,
    output wire         m_axi_wvalid,
    input  wire         m_axi_wready,

    // AXI4 master write response channel
    output wire         m_axi_bready,
    input  wire [ 1:0]  m_axi_bresp,
    input  wire         m_axi_bvalid,

    // AXI4 master read address channel
    output wire [31:0]  m_axi_araddr,
    output wire [ 7:0]  m_axi_arlen,
    output wire [ 2:0]  m_axi_arsize,
    output wire [ 1:0]  m_axi_arburst,
    output wire         m_axi_arvalid,
    input  wire         m_axi_arready,

    // AXI4 master read data channel
    output wire         m_axi_rready,
    input  wire [31:0]  m_axi_rdata,
    input  wire [ 1:0]  m_axi_rresp,
    input  wire         m_axi_rlast,
    input  wire         m_axi_rvalid
);

    wire        cpu2ic_rreq;
    wire [31:0] cpu2ic_addr;
    wire        ic2cpu_valid;
    wire [31:0] ic2cpu_inst;

    wire [ 3:0] cpu2dc_ren;
    wire [31:0] cpu2dc_addr;
    wire        dc2cpu_valid;
    wire [31:0] dc2cpu_rdata;
    wire [ 3:0] cpu2dc_wen;
    wire [31:0] cpu2dc_wdata;
    wire        dc2cpu_wresp;

    wire        ic_dev_rrdy;
    wire        dc_dev_rrdy;
    wire        dc_dev_wrdy;

    cpu_core U_core (
        .cpu_clk        (cpu_clk),
        .cpu_rst        (cpu_rst),
        .ifetch_req     (cpu2ic_rreq),
        .ifetch_addr    (cpu2ic_addr),
        .ifetch_valid   (ic2cpu_valid),
        .ifetch_inst    (ic2cpu_inst),
        .daccess_ren    (cpu2dc_ren),
        .daccess_addr   (cpu2dc_addr),
        .daccess_rvalid (dc2cpu_valid),
        .daccess_rdata  (dc2cpu_rdata),
        .daccess_wen    (cpu2dc_wen),
        .daccess_wdata  (cpu2dc_wdata),
        .daccess_wresp  (dc2cpu_wresp)
    );

    axi_master U_aximaster (
        .aclk           (cpu_clk),
        .areset         (cpu_rst),
        .ic_dev_rrdy    (ic_dev_rrdy),
        .ic_cpu_ren     (cpu2ic_rreq),
        .ic_cpu_raddr   (cpu2ic_addr),
        .ic_dev_rvalid  (ic2cpu_valid),
        .ic_dev_rdata   (ic2cpu_inst),
        .dc_dev_wrdy    (dc_dev_wrdy),
        .dc_cpu_wen     (cpu2dc_wen),
        .dc_cpu_waddr   (cpu2dc_addr),
        .dc_cpu_wdata   (cpu2dc_wdata),
        .dc_dev_wresp   (dc2cpu_wresp),
        .dc_dev_rrdy    (dc_dev_rrdy),
        .dc_cpu_ren     (|cpu2dc_ren),
        .dc_cpu_raddr   (cpu2dc_addr),
        .dc_dev_rvalid  (dc2cpu_valid),
        .dc_dev_rdata   (dc2cpu_rdata),
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
        .m_axi_rvalid   (m_axi_rvalid)
    );

    wire _unused_ready = &{1'b0, ic_dev_rrdy, dc_dev_rrdy, dc_dev_wrdy};

endmodule
