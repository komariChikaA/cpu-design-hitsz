`timescale 1ns / 1ps

`include "defines.vh"

// -----------------------------------------------------------------------------
// 流水线 cpu_core 与 AXI Master 的适配层
// -----------------------------------------------------------------------------
// cpu_core 使用简单 req/valid 接口；axi_master 使用三路 CPU 请求并输出 AXI 五通道。
// 本层还解决两个流水线特有问题：
// 1. 响应脉冲当拍，core 尚未来得及撤销请求，必须屏蔽重复接受；
// 2. taken branch 可能使在途取指过期，必须按已接受地址过滤旧响应。
module cpu_top(
    input  wire         cpu_clk,
    input  wire         cpu_rst,        // high active

    // 对外五通道 AXI Master 端口，直接连接 axi_board_soc。
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
    input  wire         m_axi_rvalid,

    // 给 ILA/板级调试导出的最小取指状态。
    output wire [31:0]  board_debug_pc,
    output wire         board_debug_ifetch_req,
    output wire         board_debug_ifetch_valid
);

    // core <-> instruction adapter。
    wire        cpu2ic_rreq;
    wire [31:0] cpu2ic_addr;
    wire        ic2cpu_valid;
    wire [31:0] ic2cpu_inst;
    wire        ic_axi_valid;
    wire [31:0] ic_axi_inst;

    // core <-> data adapter。
    wire [ 3:0] cpu2dc_ren;
    wire [31:0] cpu2dc_addr;
    wire        dc2cpu_valid;
    wire [31:0] dc2cpu_rdata;
    wire [ 3:0] cpu2dc_wen;
    wire [31:0] cpu2dc_wdata;
    wire        dc2cpu_wresp;

    // Master 对三种 CPU 请求的接受能力。
    wire        ic_dev_rrdy;
    wire        dc_dev_rrdy;
    wire        dc_dev_wrdy;

    // ILA 看到的是 core 原始请求以及过滤后真正交给 core 的返回。
    assign board_debug_ifetch_req   = cpu2ic_rreq;
    assign board_debug_ifetch_valid = ic2cpu_valid;

    // -------------------------------------------------------------------------
    // 修复 1：响应拍防重复请求
    // -------------------------------------------------------------------------
    // Master 发响应的同拍已回 IDLE，但 core 要到下一个上升沿才撤销旧请求。
    // 因此响应为 1 时屏蔽对应请求，防止刚完成的访问被再次接受。
    // 真正的背靠背访问会在 core 推进后于下一拍重新出现，不会丢失。
    wire       ic_axi_req  = cpu2ic_rreq && !ic_axi_valid;
    wire       dc_axi_rreq = (|cpu2dc_ren) && !dc2cpu_valid;
    wire [3:0] dc_axi_wen  = cpu2dc_wen & {4{!dc2cpu_wresp}};

    // -------------------------------------------------------------------------
    // 修复 2：过滤分支后的过期取指响应
    // -------------------------------------------------------------------------
    // 分支重定向时，旧 PC 的读请求可能仍在 AXI 中。记录真正被 Master 接受的字地址，
    // 只有它仍等于 core 当前所需地址时才把响应 valid 转发给 core。
    reg [31:2] ic_pending_word_addr;

    // ic_axi_req && ic_dev_rrdy 表示 CPU 侧取指请求在本拍被 Master 接受。
    always @(posedge cpu_clk or posedge cpu_rst) begin
        if (cpu_rst)
            ic_pending_word_addr <= 30'h0;
        else if (ic_axi_req && ic_dev_rrdy)
            ic_pending_word_addr <= cpu2ic_addr[31:2];
    end

    // 地址不匹配的返回数据被丢弃；core 会继续保持新目标请求直到重新获得响应。
    assign ic2cpu_valid = ic_axi_valid &&
                          (ic_pending_word_addr == cpu2ic_addr[31:2]);
    assign ic2cpu_inst  = ic_axi_inst;

    // 五级 RV32IM 流水线核心，只看简单的取指/数据请求响应。
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
        .daccess_wresp  (dc2cpu_wresp),
        .board_debug_pc (board_debug_pc)
    );

    // 无 Cache AXI Master，完成仲裁、地址锁存和五通道握手。
    axi_master U_aximaster (
        .aclk           (cpu_clk),
        .areset         (cpu_rst),
        .ic_dev_rrdy    (ic_dev_rrdy),
        .ic_cpu_ren     (ic_axi_req),
        .ic_cpu_raddr   (cpu2ic_addr),
        .ic_dev_rvalid  (ic_axi_valid),
        .ic_dev_rdata   (ic_axi_inst),
        .dc_dev_wrdy    (dc_dev_wrdy),
        .dc_cpu_wen     (dc_axi_wen),
        .dc_cpu_waddr   (cpu2dc_addr),
        .dc_cpu_wdata   (cpu2dc_wdata),
        .dc_dev_wresp   (dc2cpu_wresp),
        .dc_dev_rrdy    (dc_dev_rrdy),
        .dc_cpu_ren     (dc_axi_rreq),
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

    // ready 已在请求组合逻辑中被 Master 使用，顶层不需要再消费，保留引用消除告警。
    wire _unused_ready = &{1'b0, dc_dev_rrdy, dc_dev_wrdy};

endmodule
