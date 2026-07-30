`timescale 1ns / 1ps

`include "defines.vh"

// -----------------------------------------------------------------------------
// I/D Cache 共用、单未决事务 AXI4 Master
// -----------------------------------------------------------------------------
// CPU 侧有取指读、数据读、数据写三个简单请求口，本模块把它们转换为 AXI 五通道。
// 仲裁优先级：data write > data read > instruction read。
// read line refill 为 4 个 32-bit beat；Uncached read 和 write 为单拍。
// SB/SH 通过 WSTRB 选择有效 byte lane。
// “请求有效”不等于“事务完成”：只有 VALID && READY 的上升沿才完成对应通道握手。
module axi_master(
    // 与 CPU/板级 Slave 同一个 50 MHz 时钟域；areset 高有效同步复位。
    input  wire         aclk,
    input  wire         areset,     // high active

    // CPU 取指侧：rrdy 表示 Master 此刻愿意接收请求，rvalid 是返回脉冲。
    output reg          ic_dev_rrdy,
    input  wire         ic_cpu_ren,
    input  wire [31:0]  ic_cpu_raddr,
    output reg          ic_dev_rvalid,
    output reg  [`IC_BLK_SIZE-1:0] ic_dev_rdata,

    // CPU 数据写侧：wen 同时是请求存在标志和 4-bit 字节写使能。
    output reg          dc_dev_wrdy,
    input  wire [ 3:0]  dc_cpu_wen,
    input  wire [31:0]  dc_cpu_waddr,
    input  wire [31:0]  dc_cpu_wdata,
    output reg          dc_dev_wresp,

    // CPU 数据读侧。
    output reg          dc_dev_rrdy,
    input  wire         dc_cpu_ren,
    input  wire [31:0]  dc_cpu_raddr,
    input  wire         dc_cpu_uncached,
    output reg          dc_dev_rvalid,
    output reg  [`DC_BLK_SIZE-1:0] dc_dev_rdata,

    // AXI 写地址通道 AW。
    output reg  [31:0]  m_axi_awaddr,
    output wire [ 7:0]  m_axi_awlen,
    output wire [ 2:0]  m_axi_awsize,
    output wire [ 1:0]  m_axi_awburst,
    output reg          m_axi_awvalid,
    input  wire         m_axi_awready,

    // AXI 写数据通道 W；地址和数据通道互相独立，可在不同拍握手。
    output reg  [31:0]  m_axi_wdata,
    output reg  [ 3:0]  m_axi_wstrb,
    output wire         m_axi_wlast,
    output reg          m_axi_wvalid,
    input  wire         m_axi_wready,

    // AXI 写响应通道 B；收到响应后才向 CPU 发 dc_dev_wresp。
    output reg          m_axi_bready,
    input  wire [ 1:0]  m_axi_bresp,
    input  wire         m_axi_bvalid,

    // AXI 读地址通道 AR。
    output reg  [31:0]  m_axi_araddr,
    output wire [ 7:0]  m_axi_arlen,
    output wire [ 2:0]  m_axi_arsize,
    output wire [ 1:0]  m_axi_arburst,
    output reg          m_axi_arvalid,
    input  wire         m_axi_arready,

    // AXI 读数据通道 R；read_is_data 决定返回给取指口还是数据口。
    output reg          m_axi_rready,
    input  wire [31:0]  m_axi_rdata,
    input  wire [ 1:0]  m_axi_rresp,
    input  wire         m_axi_rlast,
    input  wire         m_axi_rvalid
);

    // 五态 FSM：
    // IDLE 等 CPU 请求；RADDR 等 AR 握手；RDATA 等 R 握手；
    // WSEND 独立等待 AW/W 都完成；WRESP 等 B 响应。
    localparam [2:0] ST_IDLE   = 3'd0;
    localparam [2:0] ST_RADDR  = 3'd1;
    localparam [2:0] ST_RDATA  = 3'd2;
    localparam [2:0] ST_WSEND  = 3'd3;
    localparam [2:0] ST_WRESP  = 3'd4;

    reg [2:0] state;
    // 锁存当前读事务来源，因为到 RDATA 时原始 CPU 请求可能已变化。
    reg       read_is_data;
    reg [7:0] read_len;
    reg [7:0] read_beat;
    reg [127:0] read_buffer;
    reg [127:0] read_buffer_next;

    localparam [7:0] IC_AXI_LEN = `IC_BLK_LEN - 1;
    localparam [7:0] DC_AXI_LEN = `DC_BLK_LEN - 1;

    // 写仍是单拍 write-through；Cache line refill 使用 4-beat INCR burst。
    assign m_axi_awlen   = 8'd0;
    assign m_axi_awsize  = 3'b010; // four bytes per beat
    assign m_axi_awburst = 2'b01;  // INCR
    assign m_axi_wlast   = 1'b1;
    assign m_axi_arlen   = read_len;
    assign m_axi_arsize  = 3'b010;
    assign m_axi_arburst = 2'b01;

    // 构造“包含本拍”的 line。最后一拍握手时要立即返回完整 line，
    // 因此不能只依赖在同一沿更新、下一拍才可见的 read_buffer。
    always @(*) begin
        read_buffer_next = read_buffer;
        case (read_beat[1:0])
            2'd0: read_buffer_next[31:0]   = m_axi_rdata;
            2'd1: read_buffer_next[63:32]  = m_axi_rdata;
            2'd2: read_buffer_next[95:64]  = m_axi_rdata;
            2'd3: read_buffer_next[127:96] = m_axi_rdata;
        endcase
    end

    // CPU 侧组合 ready 仲裁。只有 IDLE 才接收新事务；重叠请求时只有最高优先级
    // 接口看到 ready=1，避免同拍接受两个请求。
    always @(*) begin
        ic_dev_rrdy = 1'b0;
        dc_dev_rrdy = 1'b0;
        dc_dev_wrdy = 1'b0;

        if (state == ST_IDLE) begin
            // 写口默认最高优先；无写时才开放数据读；两者都无请求才开放取指。
            dc_dev_wrdy = 1'b1;
            dc_dev_rrdy = !(|dc_cpu_wen);
            ic_dev_rrdy = !(|dc_cpu_wen) && !dc_cpu_ren;
        end
    end

    // sys_rst 在 PLL lock 后仍保持若干拍。这里使用同步复位，避免驱动 BRAM 的
    // AXI 地址/控制寄存器触发 Vivado REQP-1839。
    always @(posedge aclk) begin
        if (areset) begin
            state           <= ST_IDLE;
            read_is_data    <= 1'b0;
            read_len        <= 8'd0;
            read_beat       <= 8'd0;
            read_buffer     <= 128'h0;
            ic_dev_rvalid   <= 1'b0;
            ic_dev_rdata    <= {`IC_BLK_SIZE{1'b0}};
            dc_dev_rvalid   <= 1'b0;
            dc_dev_rdata    <= {`DC_BLK_SIZE{1'b0}};
            dc_dev_wresp    <= 1'b0;
            m_axi_awaddr    <= 32'h0;
            m_axi_awvalid   <= 1'b0;
            m_axi_wdata     <= 32'h0;
            m_axi_wstrb     <= 4'h0;
            m_axi_wvalid    <= 1'b0;
            m_axi_bready    <= 1'b0;
            m_axi_araddr    <= 32'h0;
            m_axi_arvalid   <= 1'b0;
            m_axi_rready    <= 1'b0;
        end else begin
            // CPU 侧响应默认每拍清零，因此都是单周期 pulse，防止 core 把同一响应
            // 当成两次完成事件。
            ic_dev_rvalid <= 1'b0;
            dc_dev_rvalid <= 1'b0;
            dc_dev_wresp  <= 1'b0;

            case (state)
                ST_IDLE: begin
                    // 接受数据写：锁存对齐地址、数据和 WSTRB，同时拉高 AWVALID/WVALID。
                    if ((|dc_cpu_wen) && dc_dev_wrdy) begin
                        m_axi_awaddr  <= {dc_cpu_waddr[31:2], 2'b00};
                        m_axi_awvalid <= 1'b1;
                        m_axi_wdata   <= dc_cpu_wdata;
                        m_axi_wstrb   <= dc_cpu_wen;
                        m_axi_wvalid  <= 1'b1;
                        state         <= ST_WSEND;
                    end else if (dc_cpu_ren && dc_dev_rrdy) begin
                        // 接受数据读并记住返回目标。
                        read_is_data  <= 1'b1;
                        m_axi_araddr  <= {dc_cpu_raddr[31:2], 2'b00};
                        read_len      <= dc_cpu_uncached ? 8'd0 : DC_AXI_LEN;
                        read_beat     <= 8'd0;
                        read_buffer   <= 128'h0;
                        m_axi_arvalid <= 1'b1;
                        state         <= ST_RADDR;
                    end else if (ic_cpu_ren && ic_dev_rrdy) begin
                        // 接受取指读；与数据读共用 AR/R 通道。
                        read_is_data  <= 1'b0;
                        m_axi_araddr  <= {ic_cpu_raddr[31:2], 2'b00};
                        read_len      <= IC_AXI_LEN;
                        read_beat     <= 8'd0;
                        read_buffer   <= 128'h0;
                        m_axi_arvalid <= 1'b1;
                        state         <= ST_RADDR;
                    end
                end

                ST_RADDR: begin
                    // ARVALID 必须保持，直到 Slave 用 ARREADY 接受地址。
                    if (m_axi_arvalid && m_axi_arready) begin
                        m_axi_arvalid <= 1'b0;
                        m_axi_rready  <= 1'b1;
                        state         <= ST_RDATA;
                    end
                end

                ST_RDATA: begin
                    // RVALID && RREADY 才消费一拍。RREADY 在 burst 中保持为 1；
                    // 收到 RLAST（或达到已锁存的 ARLEN）后才返回完整 line。
                    if (m_axi_rvalid && m_axi_rready) begin
                        read_buffer <= read_buffer_next;
                        if (m_axi_rlast || (read_beat == read_len)) begin
                            m_axi_rready <= 1'b0;
                            if (read_is_data) begin
                                dc_dev_rdata  <= read_buffer_next[`DC_BLK_SIZE-1:0];
                                dc_dev_rvalid <= 1'b1;
                            end else begin
                                ic_dev_rdata  <= read_buffer_next[`IC_BLK_SIZE-1:0];
                                ic_dev_rvalid <= 1'b1;
                            end
                            state <= ST_IDLE;
                        end else begin
                            read_beat <= read_beat + 8'd1;
                        end
                    end
                end

                ST_WSEND: begin
                    // AW 和 W 可独立完成，各自握手后只清自己的 VALID。
                    if (m_axi_awvalid && m_axi_awready)
                        m_axi_awvalid <= 1'b0;
                    if (m_axi_wvalid && m_axi_wready)
                        m_axi_wvalid <= 1'b0;

                    // 当前拍之后两通道都已完成时，开始等待写响应。
                    if ((!m_axi_awvalid || m_axi_awready) &&
                        (!m_axi_wvalid  || m_axi_wready)) begin
                        m_axi_bready <= 1'b1;
                        state        <= ST_WRESP;
                    end
                end

                ST_WRESP: begin
                    // B 通道确认整个写事务完成，再向 CPU 发单拍 wresp。
                    if (m_axi_bvalid && m_axi_bready) begin
                        m_axi_bready <= 1'b0;
                        dc_dev_wresp <= 1'b1;
                        state        <= ST_IDLE;
                    end
                end

                default: state <= ST_IDLE;
            endcase
        end
    end

    // 当前 CPU 简单接口没有异常返回通道，因此 BRESP/RRESP 仅供 testbench 检查；
    // 保留引用以消除综合未使用告警，AXI testbench 仍会检查它们。
    wire _unused_ok = &{1'b0, m_axi_bresp, m_axi_rresp};

endmodule
