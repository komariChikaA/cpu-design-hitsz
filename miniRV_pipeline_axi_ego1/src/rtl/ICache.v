`timescale 1ns / 1ps

`include "defines.vh"

// -----------------------------------------------------------------------------
// Direct-mapped instruction cache
// -----------------------------------------------------------------------------
// - 64 lines, 16 bytes (4 words) per line;
// - read-only, write allocation is unnecessary;
// - a hit is returned combinationally while cpu_ren remains asserted;
// - a miss asks axi_master for one 128-bit line and installs it atomically.
//
// The CPU keeps cpu_ren/cpu_raddr stable until cpu_rvalid.  A taken branch may
// nevertheless change the requested address while an older refill is in flight.
// The old line is still installed, but no response is fabricated: after refill
// the cache rechecks the current CPU address in ST_IDLE.
module ICache #(
    parameter integer LINE_COUNT = `IC_LINE_COUNT
)(
    input  wire         clk,
    input  wire         rst,

    input  wire         cpu_ren,
    input  wire [31:0]  cpu_raddr,
    output wire         cpu_rvalid,
    output wire [31:0]  cpu_rdata,

    input  wire         dev_rrdy,
    output wire         dev_ren,
    output wire [31:0]  dev_raddr,
    input  wire         dev_rvalid,
    input  wire [`IC_BLK_SIZE-1:0] dev_rdata
);

    localparam integer OFFSET_BITS = 4; // 16-byte line
    localparam integer INDEX_BITS  = $clog2(LINE_COUNT);
    localparam integer TAG_BITS    = 32 - OFFSET_BITS - INDEX_BITS;

    localparam [1:0] ST_IDLE = 2'd0;
    localparam [1:0] ST_REQ  = 2'd1;
    localparam [1:0] ST_WAIT = 2'd2;

    reg [1:0] state;

    reg                    valid_array [0:LINE_COUNT-1];
    reg [TAG_BITS-1:0]     tag_array   [0:LINE_COUNT-1];
    reg [`IC_BLK_SIZE-1:0] data_array  [0:LINE_COUNT-1];

    wire [INDEX_BITS-1:0] cpu_index =
        cpu_raddr[OFFSET_BITS + INDEX_BITS - 1:OFFSET_BITS];
    wire [TAG_BITS-1:0] cpu_tag =
        cpu_raddr[31:OFFSET_BITS + INDEX_BITS];
    wire cpu_hit = valid_array[cpu_index] &&
                   (tag_array[cpu_index] == cpu_tag);

    reg [31:0] miss_line_addr;
    reg [INDEX_BITS-1:0] miss_index;
    reg [TAG_BITS-1:0] miss_tag;

    function automatic [31:0] select_word;
        input [`IC_BLK_SIZE-1:0] line;
        input [1:0] word_offs;
        begin
            case (word_offs)
                2'd0: select_word = line[31:0];
                2'd1: select_word = line[63:32];
                2'd2: select_word = line[95:64];
                default: select_word = line[127:96];
            endcase
        end
    endfunction

    assign cpu_rvalid = (state == ST_IDLE) && cpu_ren && cpu_hit;
    assign cpu_rdata  = select_word(data_array[cpu_index], cpu_raddr[3:2]);

    assign dev_ren   = (state == ST_REQ);
    assign dev_raddr = miss_line_addr;

    integer i;
    always @(posedge clk) begin
        if (rst) begin
            state          <= ST_IDLE;
            miss_line_addr <= 32'h0;
            miss_index     <= {INDEX_BITS{1'b0}};
            miss_tag       <= {TAG_BITS{1'b0}};
            for (i = 0; i < LINE_COUNT; i = i + 1)
                valid_array[i] <= 1'b0;
        end else begin
            case (state)
                ST_IDLE: begin
                    if (cpu_ren && !cpu_hit) begin
                        miss_line_addr <= {cpu_raddr[31:4], 4'b0000};
                        miss_index     <= cpu_index;
                        miss_tag       <= cpu_tag;
                        state          <= ST_REQ;
                    end
                end

                ST_REQ: begin
                    if (dev_ren && dev_rrdy)
                        state <= ST_WAIT;
                end

                ST_WAIT: begin
                    if (dev_rvalid) begin
                        data_array[miss_index]  <= dev_rdata;
                        tag_array[miss_index]   <= miss_tag;
                        valid_array[miss_index] <= 1'b1;
                        state                   <= ST_IDLE;
                    end
                end

                default: state <= ST_IDLE;
            endcase
        end
    end

endmodule
