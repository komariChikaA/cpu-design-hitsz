`timescale 1ns / 1ps

`include "defines.vh"

`ifndef BOARD_MEMORY_WORDS
// 50 KiB IROM + 100 KiB DRAM，共 38,400 个 32-bit word。
`define BOARD_MEMORY_WORDS 38_400
`endif

// -----------------------------------------------------------------------------
// EGO1 板级 AXI4 Slave：BRAM + MMIO 外设
// -----------------------------------------------------------------------------
// 把 150 KiB 片上存储器、拨码开关、LED、数码管、UART 和 64-bit timer
// 映射到同一个 AXI 地址空间。写事务和 MMIO 读为单拍；BRAM 读支持
// ARLEN 描述的 INCR burst，供 ICache/DCache 一次 refill 一条 cache line。
// Trace 构建不实例化它，而使用 cdp-tests 提供的 bram_axi 模型。
module axi_board_soc #(
    parameter integer MEMORY_WORDS = `BOARD_MEMORY_WORDS
)(
    // AXI Slave 时钟/同步高有效复位。
    input  wire         aclk,
    input  wire         areset,

    // 写地址 AW、写数据 W、写响应 B 三通道。
    input  wire [31:0]  s_axi_awaddr,
    input  wire [ 7:0]  s_axi_awlen,
    input  wire [ 2:0]  s_axi_awsize,
    input  wire [ 1:0]  s_axi_awburst,
    input  wire         s_axi_awvalid,
    output wire         s_axi_awready,
    input  wire [31:0]  s_axi_wdata,
    input  wire [ 3:0]  s_axi_wstrb,
    input  wire         s_axi_wlast,
    input  wire         s_axi_wvalid,
    output wire         s_axi_wready,
    output reg  [ 1:0]  s_axi_bresp,
    output reg          s_axi_bvalid,
    input  wire         s_axi_bready,

    // 读地址 AR、读数据 R 两通道。
    input  wire [31:0]  s_axi_araddr,
    input  wire [ 7:0]  s_axi_arlen,
    input  wire [ 2:0]  s_axi_arsize,
    input  wire [ 1:0]  s_axi_arburst,
    input  wire         s_axi_arvalid,
    output wire         s_axi_arready,
    output reg  [31:0]  s_axi_rdata,
    output reg  [ 1:0]  s_axi_rresp,
    output wire         s_axi_rlast,
    output reg          s_axi_rvalid,
    input  wire         s_axi_rready,

    // EGO1 物理外设引脚。
    input  wire [15:0]  sw,
    output wire [15:0]  led,
    output wire [ 7:0]  dig_en,
    output wire [ 7:0]  dig_seg,
    input  wire         rx,
    output wire         tx,

    // UART 接收链路的 ILA 可观测点。
    output wire         uart_debug_rx_sync,
    output wire [ 1:0]  uart_debug_rx_state,
    output wire         uart_debug_rx_valid,
    output wire [ 7:0]  uart_debug_rx_data
);

    // MMIO 可写寄存器和自由运行计时器。
    reg [15:0] led_reg;
    reg [31:0] digled_reg;
    reg [63:0] timer;
    // BRAM 同步读有 1 拍延迟。read_active/beat/len 保存当前 burst，
    // pending 表示已向 BRAM 发出读命令、下一拍需要锁存 read_data。
    reg        memory_read_pending;
    reg        read_active;
    reg [31:0] read_addr_reg;
    reg [ 7:0] read_len_reg;
    reg [ 7:0] read_beat_reg;
    wire [31:0] memory_read_data;

    // UART MMIO 与串行模块之间的单拍控制脉冲/数据。
    reg        uart_tx_start;
    reg [7:0]  uart_tx_data;
    reg        uart_tx_clear;
    reg        uart_rx_pop;
    reg        uart_rx_clear;
    wire       uart_tx_busy;
    wire [7:0] uart_rx_data;
    wire       uart_rx_valid;
    wire [3:0] uart_status;

    // LED 直接反映 MMIO 寄存器。
    assign led = led_reg;

    // 数码管驱动持续扫描 digled_reg 的 8 个十六进制数字。
    sevenseg_display U_display (
        .clk     (aclk),
        .rst     (areset),
        .value   (digled_reg),
        .dig_en  (dig_en),
        .dig_seg (dig_seg)
    );

    // 固定板级频率和波特率；上位机必须使用 115200 8N1、无流控。
    simple_uart #(
        .CLK_FREQ (50_000_000),
        .BAUD     (115_200)
    ) U_uart (
        .clk      (aclk),
        .rst      (areset),
        .rx       (rx),
        .tx       (tx),
        .tx_start (uart_tx_start),
        .tx_data  (uart_tx_data),
        .tx_clear (uart_tx_clear),
        .tx_busy  (uart_tx_busy),
        .rx_pop   (uart_rx_pop),
        .rx_clear (uart_rx_clear),
        .rx_data  (uart_rx_data),
        .rx_valid (uart_rx_valid),
        .status   (uart_status),
        .debug_rx_sync  (uart_debug_rx_sync),
        .debug_rx_state (uart_debug_rx_state),
        .debug_rx_valid (uart_debug_rx_valid),
        .debug_rx_data  (uart_debug_rx_data)
    );

    // -------------------------------------------------------------------------
    // AXI 通道握手与地址分类
    // -------------------------------------------------------------------------
    // 这个简化 Slave 只在 AWVALID 和 WVALID 同时出现时接收写事务。
    wire write_accept = s_axi_awvalid && s_axi_wvalid &&
                        s_axi_awready && s_axi_wready;
    // 上一个 B 响应未被 Master 接收前，不允许覆盖新的写事务。
    assign s_axi_awready = !s_axi_bvalid && s_axi_wvalid;
    assign s_axi_wready  = !s_axi_bvalid && s_axi_awvalid;

    // 同一时刻只维护一个读事务。当前 burst 完成前不能接受新 AR。
    assign s_axi_arready = !read_active && !s_axi_rvalid &&
                           !memory_read_pending;
    assign s_axi_rlast   = s_axi_rvalid &&
                           (read_beat_reg == read_len_reg);

    // 低于 MEMORY_WORDS*4 的字节地址属于 BRAM，其余按 MMIO 精确地址译码。
    wire write_is_memory = s_axi_awaddr < (MEMORY_WORDS * 4);
    wire read_is_memory  = s_axi_araddr < (MEMORY_WORDS * 4);
    wire memory_read_accept = s_axi_arvalid && s_axi_arready && read_is_memory;
    // 前一拍 R 数据被接收且还没到最后一拍时，立即对 BRAM 发下一地址。
    wire memory_read_continue = s_axi_rvalid && s_axi_rready &&
                                read_active &&
                                (read_beat_reg < read_len_reg);
    wire memory_read_issue = memory_read_accept || memory_read_continue;
    wire [31:0] memory_read_issue_addr =
        memory_read_accept ? s_axi_araddr : (read_addr_reg + 32'd4);
    // 只有真正完成写握手且目标为 BRAM 时，才把 WSTRB 送到存储器。
    wire [3:0] memory_write_en =
        (write_accept && write_is_memory) ? s_axi_wstrb : 4'h0;

    // AXI 字节地址 [17:2] 转换为 BRAM 32-bit word 地址。
    board_bram U_memory (
        .clk        (aclk),
        .read_en    (memory_read_issue),
        .read_addr  (memory_read_issue_addr[17:2]),
        .read_data  (memory_read_data),
        .write_en   (memory_write_en),
        .write_addr (s_axi_awaddr[17:2]),
        .write_data (s_axi_wdata)
    );

    // 顶层复位同步器在 PLL lock 后仍保持 areset 若干拍。使用同步复位使 BRAM
    // 控制寄存器满足 Block Memory Generator 映射要求，避免 REQP-1839。
    always @(posedge aclk) begin
        if (areset) begin
            led_reg       <= 16'h0;
            digled_reg    <= 32'h0;
            timer         <= 64'h0;
            memory_read_pending <= 1'b0;
            read_active    <= 1'b0;
            read_addr_reg  <= 32'h0;
            read_len_reg   <= 8'h0;
            read_beat_reg  <= 8'h0;
            uart_tx_start <= 1'b0;
            uart_tx_data  <= 8'h0;
            uart_tx_clear <= 1'b0;
            uart_rx_pop   <= 1'b0;
            uart_rx_clear <= 1'b0;
            s_axi_bresp   <= 2'b00;
            s_axi_bvalid  <= 1'b0;
            s_axi_rdata   <= 32'h0;
            s_axi_rresp   <= 2'b00;
            s_axi_rvalid  <= 1'b0;
        end else begin
            // timer 每个 50 MHz 时钟加 1；CoreMark 通过读高/低 32 位计算运行时间。
            timer         <= timer + 64'd1;
            // UART 控制均为单拍脉冲，默认清零，仅在对应 MMIO 访问时置 1。
            uart_tx_start <= 1'b0;
            uart_tx_clear <= 1'b0;
            uart_rx_pop   <= 1'b0;
            uart_rx_clear <= 1'b0;

            // Master 接受 B 响应后释放写响应寄存器。
            if (s_axi_bvalid && s_axi_bready)
                s_axi_bvalid <= 1'b0;

            // -----------------------------------------------------------------
            // 写事务：BRAM 写使能已在组合逻辑产生；这里只处理响应和 MMIO。
            // -----------------------------------------------------------------
            if (write_accept) begin
                s_axi_bvalid <= 1'b1;
                s_axi_bresp  <= 2'b00;

                if (!write_is_memory) begin
                    case (s_axi_awaddr)
                        // 0xFFFF1000：16-bit LED，WSTRB 支持按字节更新。
                        `PERI_ADDR_LED: begin
                            if (s_axi_wstrb[0]) led_reg[ 7:0] <= s_axi_wdata[ 7:0];
                            if (s_axi_wstrb[1]) led_reg[15:8] <= s_axi_wdata[15:8];
                        end
                        // 0xFFFF2000：八位十六进制数码管显示寄存器。
                        `PERI_ADDR_DIGLED: begin
                            if (s_axi_wstrb[0]) digled_reg[ 7: 0] <= s_axi_wdata[ 7: 0];
                            if (s_axi_wstrb[1]) digled_reg[15: 8] <= s_axi_wdata[15: 8];
                            if (s_axi_wstrb[2]) digled_reg[23:16] <= s_axi_wdata[23:16];
                            if (s_axi_wstrb[3]) digled_reg[31:24] <= s_axi_wdata[31:24];
                        end
                        // 0xFFFF3004：UART TX FIFO。busy 时忽略写入，软件应先轮询状态。
                        (`PERI_ADDR_UART + 32'h4): begin
                            if (s_axi_wstrb[0] && !uart_tx_busy) begin
                                uart_tx_data  <= s_axi_wdata[7:0];
                                uart_tx_start <= 1'b1;
                            end
                        end
                        // 0xFFFF300C：UART 控制，bit0 清 TX、bit1 清 RX。
                        (`PERI_ADDR_UART + 32'hc): begin
                            if (s_axi_wstrb[0]) begin
                                uart_tx_clear <= s_axi_wdata[0];
                                uart_rx_clear <= s_axi_wdata[1];
                            end
                        end
                        // 未映射外设地址仍完成事务，但用 DECERR 标记。
                        default: s_axi_bresp <= 2'b11; // DECERR
                    endcase
                end
            end

            // Master 接受一个 R beat。若 burst 未结束，同时发起下一次 BRAM 读；
            // 最后一拍则释放整个读事务。
            if (s_axi_rvalid && s_axi_rready) begin
                s_axi_rvalid <= 1'b0;
                if (read_active) begin
                    if (read_beat_reg == read_len_reg) begin
                        read_active <= 1'b0;
                    end else begin
                        read_addr_reg         <= read_addr_reg + 32'd4;
                        read_beat_reg         <= read_beat_reg + 8'd1;
                        memory_read_pending   <= 1'b1;
                    end
                end
            end

            // BRAM 在发出读命令后一拍给数据。pending 拍把数据锁存到 R 通道。
            if (memory_read_pending) begin
                s_axi_rdata         <= memory_read_data;
                s_axi_rresp         <= 2'b00;
                s_axi_rvalid        <= 1'b1;
                memory_read_pending <= 1'b0;
            end

            // -----------------------------------------------------------------
            // 读事务：BRAM 路径先置 pending；MMIO 路径可在本拍准备返回寄存器。
            // -----------------------------------------------------------------
            if (s_axi_arvalid && s_axi_arready) begin
                read_active   <= 1'b1;
                read_addr_reg <= s_axi_araddr;
                read_beat_reg <= 8'd0;
                if (read_is_memory) begin
                    read_len_reg         <= s_axi_arlen;
                    memory_read_pending <= 1'b1;
                end else begin
                    // 外设只能单拍读。误发 burst 时仍只回一拍，并用 DECERR 报错。
                    read_len_reg <= 8'd0;
                    s_axi_rvalid <= 1'b1;
                    s_axi_rresp  <= (s_axi_arlen == 8'd0) ? 2'b00 : 2'b11;
                    case (s_axi_araddr)
                        // 0xFFFF0000：16 个拨码开关，零扩展到 32 位。
                        `PERI_ADDR_SWITCH: s_axi_rdata <= {16'h0, sw};
                        // 0xFFFF3000：读 RX 字节，并在确有数据时产生 pop。
                        (`PERI_ADDR_UART + 32'h0): begin
                            s_axi_rdata <= {24'h0, uart_rx_data};
                            uart_rx_pop <= uart_rx_valid;
                        end
                        // 0xFFFF3008：UART busy/empty/full/not-empty 状态。
                        (`PERI_ADDR_UART + 32'h8): s_axi_rdata <= {28'h0, uart_status};
                        // 0xFFFF4000/4008：64-bit 周期计数器低/高 32 位。
                        (`PERI_ADDR_TIMER + 32'h0): s_axi_rdata <= timer[31:0];
                        (`PERI_ADDR_TIMER + 32'h8): s_axi_rdata <= timer[63:32];
                        default: begin
                            s_axi_rdata <= 32'h0;
                            s_axi_rresp <= 2'b11; // DECERR
                        end
                    endcase
                end
            end
        end
    end

    // 当前只实现 32-bit INCR burst；其余描述字段由集成测试约束为合法值。
    wire _unused_axi = &{1'b0, s_axi_awlen, s_axi_awsize, s_axi_awburst,
                         s_axi_wlast, s_axi_arsize, s_axi_arburst};

endmodule
