`timescale 1ns / 1ps

`include "defines.vh"

`ifndef BOARD_MEMORY_WORDS
`define BOARD_MEMORY_WORDS 38_400
`endif

// Synthesizable single-beat AXI4 slave used when running on EGO1.  It combines
// a 150 KiB unified block memory with the five course-required peripherals.
// The Trace build does not instantiate this module; it uses cdp-tests'
// bram_axi model instead.
module axi_board_soc #(
    parameter integer MEMORY_WORDS = `BOARD_MEMORY_WORDS
)(
    input  wire         aclk,
    input  wire         areset,

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

    input  wire [15:0]  sw,
    output wire [15:0]  led,
    output wire [ 7:0]  dig_en,
    output wire [ 7:0]  dig_seg,
    input  wire         rx,
    output wire         tx
);

    reg [15:0] led_reg;
    reg [31:0] digled_reg;
    reg [63:0] timer;
    reg        memory_read_pending;
    wire [31:0] memory_read_data;

    reg        uart_tx_start;
    reg [7:0]  uart_tx_data;
    reg        uart_tx_clear;
    reg        uart_rx_pop;
    reg        uart_rx_clear;
    wire       uart_tx_busy;
    wire [7:0] uart_rx_data;
    wire       uart_rx_valid;
    wire [3:0] uart_status;

    assign led = led_reg;

    sevenseg_display U_display (
        .clk     (aclk),
        .rst     (areset),
        .value   (digled_reg),
        .dig_en  (dig_en),
        .dig_seg (dig_seg)
    );

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
        .status   (uart_status)
    );

    wire write_accept = s_axi_awvalid && s_axi_wvalid &&
                        s_axi_awready && s_axi_wready;
    assign s_axi_awready = !s_axi_bvalid && s_axi_wvalid;
    assign s_axi_wready  = !s_axi_bvalid && s_axi_awvalid;

    assign s_axi_arready = !s_axi_rvalid && !memory_read_pending;
    assign s_axi_rlast   = 1'b1;

    wire write_is_memory = s_axi_awaddr < (MEMORY_WORDS * 4);
    wire read_is_memory  = s_axi_araddr < (MEMORY_WORDS * 4);
    wire memory_read_accept = s_axi_arvalid && s_axi_arready && read_is_memory;
    wire [3:0] memory_write_en =
        (write_accept && write_is_memory) ? s_axi_wstrb : 4'h0;

    board_bram U_memory (
        .clk        (aclk),
        .read_en    (memory_read_accept),
        .read_addr  (s_axi_araddr[17:2]),
        .read_data  (memory_read_data),
        .write_en   (memory_write_en),
        .write_addr (s_axi_awaddr[17:2]),
        .write_data (s_axi_wdata)
    );

    always @(posedge aclk or posedge areset) begin
        if (areset) begin
            led_reg       <= 16'h0;
            digled_reg    <= 32'h0;
            timer         <= 64'h0;
            memory_read_pending <= 1'b0;
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
            timer         <= timer + 64'd1;
            uart_tx_start <= 1'b0;
            uart_tx_clear <= 1'b0;
            uart_rx_pop   <= 1'b0;
            uart_rx_clear <= 1'b0;

            if (s_axi_bvalid && s_axi_bready)
                s_axi_bvalid <= 1'b0;

            if (write_accept) begin
                s_axi_bvalid <= 1'b1;
                s_axi_bresp  <= 2'b00;

                if (!write_is_memory) begin
                    case (s_axi_awaddr)
                        `PERI_ADDR_LED: begin
                            if (s_axi_wstrb[0]) led_reg[ 7:0] <= s_axi_wdata[ 7:0];
                            if (s_axi_wstrb[1]) led_reg[15:8] <= s_axi_wdata[15:8];
                        end
                        `PERI_ADDR_DIGLED: begin
                            if (s_axi_wstrb[0]) digled_reg[ 7: 0] <= s_axi_wdata[ 7: 0];
                            if (s_axi_wstrb[1]) digled_reg[15: 8] <= s_axi_wdata[15: 8];
                            if (s_axi_wstrb[2]) digled_reg[23:16] <= s_axi_wdata[23:16];
                            if (s_axi_wstrb[3]) digled_reg[31:24] <= s_axi_wdata[31:24];
                        end
                        (`PERI_ADDR_UART + 32'h4): begin
                            if (s_axi_wstrb[0] && !uart_tx_busy) begin
                                uart_tx_data  <= s_axi_wdata[7:0];
                                uart_tx_start <= 1'b1;
                            end
                        end
                        (`PERI_ADDR_UART + 32'hc): begin
                            if (s_axi_wstrb[0]) begin
                                uart_tx_clear <= s_axi_wdata[0];
                                uart_rx_clear <= s_axi_wdata[1];
                            end
                        end
                        default: s_axi_bresp <= 2'b11; // DECERR
                    endcase
                end
            end

            if (s_axi_rvalid && s_axi_rready)
                s_axi_rvalid <= 1'b0;

            // The Block Memory Generator ports have one-cycle read latency.
            if (memory_read_pending) begin
                s_axi_rdata         <= memory_read_data;
                s_axi_rresp         <= 2'b00;
                s_axi_rvalid        <= 1'b1;
                memory_read_pending <= 1'b0;
            end

            if (s_axi_arvalid && s_axi_arready) begin
                if (read_is_memory) begin
                    memory_read_pending <= 1'b1;
                end else begin
                    s_axi_rvalid <= 1'b1;
                    s_axi_rresp  <= 2'b00;
                    case (s_axi_araddr)
                        `PERI_ADDR_SWITCH: s_axi_rdata <= {16'h0, sw};
                        (`PERI_ADDR_UART + 32'h0): begin
                            s_axi_rdata <= {24'h0, uart_rx_data};
                            uart_rx_pop <= uart_rx_valid;
                        end
                        (`PERI_ADDR_UART + 32'h8): s_axi_rdata <= {28'h0, uart_status};
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

    wire _unused_axi = &{1'b0, s_axi_awlen, s_axi_awsize, s_axi_awburst,
                         s_axi_wlast, s_axi_arlen, s_axi_arsize,
                         s_axi_arburst};

endmodule
