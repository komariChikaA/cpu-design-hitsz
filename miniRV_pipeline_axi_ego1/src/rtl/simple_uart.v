`timescale 1ns / 1ps

// Minimal one-byte UART used for the EGO1 bring-up path.  The status bits
// match the course AXI UART register contract:
//   bit 3 TX full, bit 2 TX empty, bit 1 RX full, bit 0 RX not empty.
module simple_uart #(
    parameter integer CLK_FREQ = 50_000_000,
    parameter integer BAUD     = 115_200
)(
    input  wire       clk,
    input  wire       rst,
    input  wire       rx,
    output wire       tx,

    input  wire       tx_start,
    input  wire [7:0] tx_data,
    input  wire       tx_clear,
    output wire       tx_busy,

    input  wire       rx_pop,
    input  wire       rx_clear,
    output reg  [7:0] rx_data,
    output reg        rx_valid,
    output wire [3:0] status
);

    localparam integer CLKS_PER_BIT = CLK_FREQ / BAUD;
    localparam integer HALF_BIT     = CLKS_PER_BIT / 2;

    reg [1:0] rx_sync;
    always @(posedge clk or posedge rst) begin
        if (rst)
            rx_sync <= 2'b11;
        else
            rx_sync <= {rx_sync[0], rx};
    end

    reg [9:0]  tx_shift;
    reg [3:0]  tx_bit_index;
    reg [15:0] tx_clock_count;
    reg        tx_active;

    assign tx      = tx_active ? tx_shift[tx_bit_index] : 1'b1;
    assign tx_busy = tx_active;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            tx_shift       <= 10'h3ff;
            tx_bit_index   <= 4'd0;
            tx_clock_count <= 16'd0;
            tx_active      <= 1'b0;
        end else if (tx_clear) begin
            tx_bit_index   <= 4'd0;
            tx_clock_count <= 16'd0;
            tx_active      <= 1'b0;
        end else if (tx_start && !tx_active) begin
            tx_shift       <= {1'b1, tx_data, 1'b0};
            tx_bit_index   <= 4'd0;
            tx_clock_count <= 16'd0;
            tx_active      <= 1'b1;
        end else if (tx_active) begin
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

    localparam [1:0] RX_IDLE  = 2'd0;
    localparam [1:0] RX_START = 2'd1;
    localparam [1:0] RX_DATA  = 2'd2;
    localparam [1:0] RX_STOP  = 2'd3;

    reg [1:0]  rx_state;
    reg [15:0] rx_clock_count;
    reg [2:0]  rx_bit_index;
    reg [7:0]  rx_shift;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            rx_state       <= RX_IDLE;
            rx_clock_count <= 16'd0;
            rx_bit_index   <= 3'd0;
            rx_shift       <= 8'h0;
            rx_data        <= 8'h0;
            rx_valid       <= 1'b0;
        end else begin
            if (rx_pop || rx_clear)
                rx_valid <= 1'b0;

            case (rx_state)
                RX_IDLE: begin
                    if (!rx_sync[1]) begin
                        rx_clock_count <= HALF_BIT;
                        rx_state       <= RX_START;
                    end
                end

                RX_START: begin
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

    assign status = {tx_active, !tx_active, rx_valid, rx_valid};

endmodule
