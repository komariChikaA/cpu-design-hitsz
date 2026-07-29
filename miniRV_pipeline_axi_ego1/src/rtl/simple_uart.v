`timescale 1ns / 1ps

// -----------------------------------------------------------------------------
// EGO1 单字节缓冲 UART
// -----------------------------------------------------------------------------
// 8 data bits、无校验、1 stop bit（8N1），默认 50 MHz / 115200 baud。
// 状态位与课程 AXI UART 寄存器约定一致：
//   bit3 TX full/busy，bit2 TX empty，bit1 RX full，bit0 RX not empty。
module simple_uart #(
    parameter integer CLK_FREQ = 50_000_000,
    parameter integer BAUD     = 115_200
)(
    // 串行引脚。rx 来自 USB-UART，tx 返回上位机。
    input  wire       clk,
    input  wire       rst,
    input  wire       rx,
    output wire       tx,

    // TX 软件接口：板级 MMIO 写 UART+4 时产生一个 tx_start 脉冲。
    input  wire       tx_start,
    input  wire [7:0] tx_data,
    input  wire       tx_clear,
    output wire       tx_busy,

    // RX 软件接口：读 UART+0 后 rx_pop 清 valid；控制寄存器也可 rx_clear。
    input  wire       rx_pop,
    input  wire       rx_clear,
    output reg  [7:0] rx_data,
    output reg        rx_valid,
    output wire [3:0] status,

    // ILA/仿真专用可观测信号，不参与功能。
    output wire       debug_rx_sync,
    output wire [1:0] debug_rx_state,
    output wire       debug_rx_valid,
    output wire [7:0] debug_rx_data
);

    // 每个 UART bit 保持的系统时钟数；HALF_BIT 用于在起始位中央再次确认。
    localparam integer CLKS_PER_BIT = CLK_FREQ / BAUD;
    localparam integer HALF_BIT     = CLKS_PER_BIT / 2;

    // 异步 rx 先经过两级同步器，降低亚稳态传播风险。
    reg [1:0] rx_sync;
    always @(posedge clk or posedge rst) begin
        if (rst)
            rx_sync <= 2'b11;
        else
            rx_sync <= {rx_sync[0], rx};
    end

    // -------------------------------------------------------------------------
    // 发送器
    // -------------------------------------------------------------------------
    // tx_shift = {stop, data[7:0], start}，tx_bit_index 从 0 到 9 依次发送。
    reg [9:0]  tx_shift;
    reg [3:0]  tx_bit_index;
    reg [15:0] tx_clock_count;
    reg        tx_active;

    // UART 空闲电平为 1；发送期间直接选择当前帧位。
    assign tx      = tx_active ? tx_shift[tx_bit_index] : 1'b1;
    assign tx_busy = tx_active;

    // tx_start 只在空闲时接受。每经过 CLKS_PER_BIT 个 clk 切到下一位。
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx_shift       <= 10'h3ff;
            tx_bit_index   <= 4'd0;
            tx_clock_count <= 16'd0;
            tx_active      <= 1'b0;
        end else if (tx_clear) begin
            // 软件复位发送器，立即放弃当前字节并回到空闲高电平。
            tx_bit_index   <= 4'd0;
            tx_clock_count <= 16'd0;
            tx_active      <= 1'b0;
        end else if (tx_start && !tx_active) begin
            // 锁存 1 个起始位、8 个 LSB-first 数据位和 1 个停止位。
            tx_shift       <= {1'b1, tx_data, 1'b0};
            tx_bit_index   <= 4'd0;
            tx_clock_count <= 16'd0;
            tx_active      <= 1'b1;
        end else if (tx_active) begin
            // 位计时器到达末尾后推进 bit index；stop 位完成后释放 busy。
            if (tx_clock_count == CLKS_PER_BIT - 1) begin
                tx_clock_count <= 16'd0;
                if (tx_bit_index == 4'd9) begin
                    tx_bit_index <= 4'd0;
                    tx_active    <= 1'b0;
                end else begin
                    tx_bit_index <= tx_bit_index + 4'd1;
                end
            end else begin
                tx_clock_count <= tx_clock_count + 16'd1;
            end
        end
    end

    // -------------------------------------------------------------------------
    // 接收器
    // -------------------------------------------------------------------------
    // 四态 FSM：等待下降沿、确认起始位、采 8 位数据、确认停止位。
    localparam [1:0] RX_IDLE  = 2'd0;
    localparam [1:0] RX_START = 2'd1;
    localparam [1:0] RX_DATA  = 2'd2;
    localparam [1:0] RX_STOP  = 2'd3;

    reg [1:0]  rx_state;
    reg [15:0] rx_clock_count;
    reg [2:0]  rx_bit_index;
    reg [7:0]  rx_shift;

    // 在每个 bit 中心采样。接收完成后 rx_valid 保持，直到软件 pop/clear。
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rx_state       <= RX_IDLE;
            rx_clock_count <= 16'd0;
            rx_bit_index   <= 3'd0;
            rx_shift       <= 8'h0;
            rx_data        <= 8'h0;
            rx_valid       <= 1'b0;
        end else begin
            // 软件读 FIFO 或写控制寄存器后，允许下一字节覆盖缓冲。
            if (rx_pop || rx_clear)
                rx_valid <= 1'b0;

            case (rx_state)
                RX_IDLE: begin
                    // 发现同步后 rx 的下降沿，等待半个 bit 到起始位中心。
                    if (!rx_sync[1]) begin
                        rx_clock_count <= HALF_BIT;
                        rx_state       <= RX_START;
                    end
                end

                RX_START: begin
                    // 中心仍为 0 才是真起始位；否则视为毛刺回 IDLE。
                    if (rx_clock_count == 0) begin
                        if (!rx_sync[1]) begin
                            rx_clock_count <= CLKS_PER_BIT - 1;
                            rx_bit_index   <= 3'd0;
                            rx_state       <= RX_DATA;
                        end else begin
                            rx_state <= RX_IDLE;
                        end
                    end else begin
                        rx_clock_count <= rx_clock_count - 16'd1;
                    end
                end

                RX_DATA: begin
                    // UART 数据 LSB first，共采样 bit0..bit7。
                    if (rx_clock_count == 0) begin
                        rx_shift[rx_bit_index] <= rx_sync[1];
                        rx_clock_count         <= CLKS_PER_BIT - 1;
                        if (rx_bit_index == 3'd7)
                            rx_state <= RX_STOP;
                        else
                            rx_bit_index <= rx_bit_index + 3'd1;
                    end else begin
                        rx_clock_count <= rx_clock_count - 16'd1;
                    end
                end

                RX_STOP: begin
                    // 停止位必须为 1；有效时把 shift 提交到单字节缓冲。
                    if (rx_clock_count == 0) begin
                        if (rx_sync[1]) begin
                            rx_data  <= rx_shift;
                            rx_valid <= 1'b1;
                        end
                        rx_state <= RX_IDLE;
                    end else begin
                        rx_clock_count <= rx_clock_count - 16'd1;
                    end
                end

                default: rx_state <= RX_IDLE;
            endcase
        end
    end

    // bit3/2 是互补的 busy/empty；单字节 RX 缓冲使 bit1/0 都等于 rx_valid。
    assign status = {tx_active, !tx_active, rx_valid, rx_valid};
    // 把接收器关键内部状态导出给 ILA，现场可定位“引脚没到/没识别起始位/未提交”。
    assign debug_rx_sync  = rx_sync[1];
    assign debug_rx_state = rx_state;
    assign debug_rx_valid = rx_valid;
    assign debug_rx_data  = rx_data;

endmodule
