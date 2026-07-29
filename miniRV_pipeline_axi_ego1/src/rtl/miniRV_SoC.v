`timescale 1ns / 1ps

`include "defines.vh"

// -----------------------------------------------------------------------------
// 最终版流水线 AXI SoC 顶层
// -----------------------------------------------------------------------------
// RUN_TRACE 构建：直接使用测试时钟/复位，AXI 连接课程 bram_axi。
// EGO1 构建：时钟经 PLL 变为 50 MHz，AXI 连接 axi_board_soc，并导出 ILA probe。
// 两种构建共用完全相同的 cpu_top 和 AXI 五通道，差别只在存储器/外设后端。
module miniRV_SoC(
    // Trace 中 fpga_rst 高有效；EGO1 板上 S6 输入低有效，非 Trace 分支负责转换。
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

    // cpu_top 与两种 AXI Slave 后端之间的完整五通道连线。
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
    // 板级 ILA 使用的 CPU 和 UART 可观测信号。
    wire [31:0] cpu_debug_pc;
    wire        cpu_debug_ifetch_req;
    wire        cpu_debug_ifetch_valid;
    wire        uart_debug_rx_sync;
    wire [ 1:0] uart_debug_rx_state;
    wire        uart_debug_rx_valid;
    wire [ 7:0] uart_debug_rx_data;

`ifdef RUN_TRACE
    // -------------------------------------------------------------------------
    // 课程 AXI Trace 模式
    // -------------------------------------------------------------------------
    // 测试框架已经提供合适时钟/高有效复位，不需要 PLL。
    wire sys_clk = fpga_clk;
    wire sys_rst = fpga_rst;

    // Trace 没有真实外设，给板卡输出确定常量以避免悬空。
    assign led      = 16'h0;
    assign dig_en   = 8'hff;
    assign dig_seg  = 8'h00;
    assign dig_seg1 = 8'h00;
    assign tx       = 1'b1;

    // 模块名 bram_axi 和实例名 U_bram 是 cdp-tests 层级检查契约的一部分，不能改名。
    // ID/cache/prot 等未使用字段固定为 0，本设计只发单拍 32-bit 访问。
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
    // -------------------------------------------------------------------------
    // EGO1 实板模式
    // -------------------------------------------------------------------------
    // clk_wiz_0 从板载时钟生成系统 50 MHz；只有 locked 后才允许释放 CPU。
    wire pll_clk1;
    wire pll_lock;
    wire sys_clk = pll_clk1;
    reg [1:0] reset_sync;
    wire sys_rst = reset_sync[1];

    // 异步置位、同步两拍释放复位：按下 S6 或 PLL 未锁定时立即复位，
    // 条件恢复后仍等待两个 sys_clk 上升沿，避免各模块在不同时刻启动。
    always @(posedge sys_clk or negedge fpga_rst) begin
        if (!fpga_rst)
            reset_sync <= 2'b11;
        else if (!pll_lock)
            reset_sync <= 2'b11;
        else
            reset_sync <= {reset_sync[0], 1'b0};
    end

    // Vivado Clocking Wizard IP。
    clk_wiz_0 U_clkgen (
        .clk_in1  (fpga_clk),
        .locked   (pll_lock),
        .clk_out1 (pll_clk1)
    );

    // 可综合 AXI Slave：150 KiB BRAM + switch/LED/digled/UART/timer。
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

    // EGO1 约束暴露两组段选名，当前板卡两组使用相同段码。
    assign dig_seg1 = dig_seg;

    // 单一拼接 probe 总线使 ILA 插入脚本保持确定；位映射见 ILA_DEBUG_GUIDE.md。
    (* keep = "true" *) wire ila_clk = sys_clk;
    // 高位新增 UART RX 诊断；原 [173:0] 映射保持不变，旧 AXI 截图仍可对应。
    // 拼接顺序从左到右对应高位到低位：[186] rx ... [0] bready。
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

    // CPU 核心和 AXI Master 的公共实例。无论 Trace/实板都使用此同一份最终 RTL。
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
