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

    // core <-> instruction side。
    wire        cpu2ic_rreq;
    wire [31:0] cpu2ic_addr;
    wire        ic2cpu_valid;
    wire [31:0] ic2cpu_inst;

    // core <-> data side。
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

    // Cache/device <-> AXI Master。即使关闭 Cache，也通过这一组统一信号接线。
    wire        master_ic_ren;
    wire [31:0] master_ic_raddr;
    wire        master_ic_rvalid;
    wire [`IC_BLK_SIZE-1:0] master_ic_rdata;

    wire [ 3:0] master_dc_wen;
    wire [31:0] master_dc_waddr;
    wire [31:0] master_dc_wdata;
    wire        master_dc_wresp;
    wire        master_dc_ren;
    wire [31:0] master_dc_raddr;
    wire        master_dc_uncached;
    wire        master_dc_rvalid;
    wire [`DC_BLK_SIZE-1:0] master_dc_rdata;

    // ILA 看到的是 core 原始请求以及过滤后真正交给 core 的返回。
    assign board_debug_ifetch_req   = cpu2ic_rreq;
    assign board_debug_ifetch_valid = ic2cpu_valid;

`ifdef ENABLE_ICACHE
    // ICache 命中时直接在 core 侧返回；未命中时按 16-byte line 请求 AXI。
    // 分支改变 PC 时，旧 refill 可以写入 Cache，但 ICache 会重新检查当前地址，
    // 不会把旧地址数据误当成新 PC 的指令。
    ICache #(.LINE_COUNT(`IC_LINE_COUNT)) U_icache (
        .clk        (cpu_clk),
        .rst        (cpu_rst),
        .cpu_ren    (cpu2ic_rreq),
        .cpu_raddr  (cpu2ic_addr),
        .cpu_rvalid (ic2cpu_valid),
        .cpu_rdata  (ic2cpu_inst),
        .dev_rrdy   (ic_dev_rrdy),
        .dev_ren    (master_ic_ren),
        .dev_raddr  (master_ic_raddr),
        .dev_rvalid (master_ic_rvalid),
        .dev_rdata  (master_ic_rdata)
    );
`else
    // 无 Cache 调试路径：屏蔽响应拍的重复请求，并过滤分支后的旧取指响应。
    wire ic_direct_req = cpu2ic_rreq && !master_ic_rvalid;
    reg [31:2] ic_pending_word_addr;
    always @(posedge cpu_clk or posedge cpu_rst) begin
        if (cpu_rst)
            ic_pending_word_addr <= 30'h0;
        else if (ic_direct_req && ic_dev_rrdy)
            ic_pending_word_addr <= cpu2ic_addr[31:2];
    end
    assign master_ic_ren   = ic_direct_req;
    assign master_ic_raddr = cpu2ic_addr;
    assign ic2cpu_valid    = master_ic_rvalid &&
                             (ic_pending_word_addr == cpu2ic_addr[31:2]);
    assign ic2cpu_inst     = master_ic_rdata[31:0];
`endif

`ifdef ENABLE_DCACHE
    // DCache 为 write-through/no-write-allocate；MMIO 自动走 Uncached 单拍访问。
    DCache #(.LINE_COUNT(`DC_LINE_COUNT)) U_dcache (
        .clk          (cpu_clk),
        .rst          (cpu_rst),
        .cpu_ren      (cpu2dc_ren),
        .cpu_addr     (cpu2dc_addr),
        .cpu_rvalid   (dc2cpu_valid),
        .cpu_rdata    (dc2cpu_rdata),
        .cpu_wen      (cpu2dc_wen),
        .cpu_wdata    (cpu2dc_wdata),
        .cpu_wresp    (dc2cpu_wresp),
        .dev_rrdy     (dc_dev_rrdy),
        .dev_ren      (master_dc_ren),
        .dev_raddr    (master_dc_raddr),
        .dev_uncached (master_dc_uncached),
        .dev_rvalid   (master_dc_rvalid),
        .dev_rdata    (master_dc_rdata),
        .dev_wrdy     (dc_dev_wrdy),
        .dev_wen      (master_dc_wen),
        .dev_waddr    (master_dc_waddr),
        .dev_wdata    (master_dc_wdata),
        .dev_wresp    (master_dc_wresp)
    );
`else
    assign master_dc_wen      = cpu2dc_wen & {4{!master_dc_wresp}};
    assign master_dc_waddr    = cpu2dc_addr;
    assign master_dc_wdata    = cpu2dc_wdata;
    assign master_dc_ren      = (|cpu2dc_ren) && !master_dc_rvalid;
    assign master_dc_raddr    = cpu2dc_addr;
    assign master_dc_uncached = 1'b1;
    assign dc2cpu_valid       = master_dc_rvalid;
    assign dc2cpu_rdata       = master_dc_rdata[31:0];
    assign dc2cpu_wresp       = master_dc_wresp;
`endif

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

    // AXI Master 仲裁：D 写 > D 读 > I 读；Cache refill 使用四拍 burst。
    axi_master U_aximaster (
        .aclk           (cpu_clk),
        .areset         (cpu_rst),
        .ic_dev_rrdy    (ic_dev_rrdy),
        .ic_cpu_ren     (master_ic_ren),
        .ic_cpu_raddr   (master_ic_raddr),
        .ic_dev_rvalid  (master_ic_rvalid),
        .ic_dev_rdata   (master_ic_rdata),
        .dc_dev_wrdy    (dc_dev_wrdy),
        .dc_cpu_wen     (master_dc_wen),
        .dc_cpu_waddr   (master_dc_waddr),
        .dc_cpu_wdata   (master_dc_wdata),
        .dc_dev_wresp   (master_dc_wresp),
        .dc_dev_rrdy    (dc_dev_rrdy),
        .dc_cpu_ren     (master_dc_ren),
        .dc_cpu_raddr   (master_dc_raddr),
        .dc_cpu_uncached(master_dc_uncached),
        .dc_dev_rvalid  (master_dc_rvalid),
        .dc_dev_rdata   (master_dc_rdata),
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
