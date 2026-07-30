`timescale 1ns / 1ps

`include "defines.vh"

// -----------------------------------------------------------------------------
// Direct-mapped write-through data cache
// -----------------------------------------------------------------------------
// - 64 lines, 16 bytes (4 words) per line;
// - cached read miss: allocate a complete 128-bit line;
// - cached write: update the resident line on hit and always write through;
// - write miss: no-write-allocate, forward the write to memory;
// - MMIO/out-of-range accesses are Uncached and always use a single AXI beat.
//
// The CPU request is held until cpu_rvalid/cpu_wresp.  The device-side request
// is asserted only in ST_RREQ/ST_WREQ, so an AXI response cannot accidentally
// cause the same persistent CPU request to be accepted twice.
module DCache #(
    parameter integer LINE_COUNT = `DC_LINE_COUNT
)(
    input  wire         clk,
    input  wire         rst,

    input  wire [ 3:0]  cpu_ren,
    input  wire [31:0]  cpu_addr,
    output wire         cpu_rvalid,
    output wire [31:0]  cpu_rdata,
    input  wire [ 3:0]  cpu_wen,
    input  wire [31:0]  cpu_wdata,
    output wire         cpu_wresp,

    input  wire         dev_rrdy,
    output wire         dev_ren,
    output wire [31:0]  dev_raddr,
    output wire         dev_uncached,
    input  wire         dev_rvalid,
    input  wire [`DC_BLK_SIZE-1:0] dev_rdata,

    input  wire         dev_wrdy,
    output wire [ 3:0]  dev_wen,
    output wire [31:0]  dev_waddr,
    output wire [31:0]  dev_wdata,
    input  wire         dev_wresp
);

    localparam integer OFFSET_BITS = 4;
    localparam integer INDEX_BITS  = $clog2(LINE_COUNT);
    localparam integer TAG_BITS    = 32 - OFFSET_BITS - INDEX_BITS;

    localparam [2:0] ST_IDLE  = 3'd0;
    localparam [2:0] ST_RREQ  = 3'd1;
    localparam [2:0] ST_RWAIT = 3'd2;
    localparam [2:0] ST_WREQ  = 3'd3;
    localparam [2:0] ST_WWAIT = 3'd4;

    reg [2:0] state;

    reg                    valid_array [0:LINE_COUNT-1];
    reg [TAG_BITS-1:0]     tag_array   [0:LINE_COUNT-1];
    reg [`DC_BLK_SIZE-1:0] data_array  [0:LINE_COUNT-1];

    wire [INDEX_BITS-1:0] cpu_index =
        cpu_addr[OFFSET_BITS + INDEX_BITS - 1:OFFSET_BITS];
    wire [TAG_BITS-1:0] cpu_tag =
        cpu_addr[31:OFFSET_BITS + INDEX_BITS];
    wire cpu_hit = valid_array[cpu_index] &&
                   (tag_array[cpu_index] == cpu_tag);
    wire cpu_cacheable = cpu_addr < `CACHEABLE_LIMIT;

    reg [31:0] req_addr;
    reg        req_uncached;
    reg [INDEX_BITS-1:0] miss_index;
    reg [TAG_BITS-1:0] miss_tag;

    reg [3:0]  write_wen;
    reg [31:0] write_addr;
    reg [31:0] write_data;

    function automatic [31:0] select_word;
        input [`DC_BLK_SIZE-1:0] line;
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

    function automatic [31:0] merge_bytes;
        input [31:0] old_word;
        input [31:0] new_word;
        input [ 3:0] wen;
        begin
            merge_bytes = old_word;
            if (wen[0]) merge_bytes[ 7: 0] = new_word[ 7: 0];
            if (wen[1]) merge_bytes[15: 8] = new_word[15: 8];
            if (wen[2]) merge_bytes[23:16] = new_word[23:16];
            if (wen[3]) merge_bytes[31:24] = new_word[31:24];
        end
    endfunction

    wire cached_read_hit = (state == ST_IDLE) && (|cpu_ren) &&
                           !(|cpu_wen) && cpu_cacheable && cpu_hit;
    wire uncached_read_done = (state == ST_RWAIT) && req_uncached &&
                              dev_rvalid;

    assign cpu_rvalid = cached_read_hit || uncached_read_done;
    assign cpu_rdata  = uncached_read_done
                      ? dev_rdata[31:0]
                      : select_word(data_array[cpu_index], cpu_addr[3:2]);
    assign cpu_wresp  = (state == ST_WWAIT) && dev_wresp;

    assign dev_ren      = (state == ST_RREQ);
    assign dev_raddr    = req_addr;
    assign dev_uncached = req_uncached;

    assign dev_wen   = (state == ST_WREQ) ? write_wen : 4'h0;
    assign dev_waddr = write_addr;
    assign dev_wdata = write_data;

    integer i;
    reg [31:0] updated_word;
    always @(posedge clk) begin
        if (rst) begin
            state          <= ST_IDLE;
            req_addr       <= 32'h0;
            req_uncached   <= 1'b0;
            miss_index     <= {INDEX_BITS{1'b0}};
            miss_tag       <= {TAG_BITS{1'b0}};
            write_wen      <= 4'h0;
            write_addr     <= 32'h0;
            write_data     <= 32'h0;
            updated_word   <= 32'h0;
            for (i = 0; i < LINE_COUNT; i = i + 1)
                valid_array[i] <= 1'b0;
        end else begin
            case (state)
                ST_IDLE: begin
                    if (|cpu_wen) begin
                        write_wen  <= cpu_wen;
                        write_addr <= {cpu_addr[31:2], 2'b00};
                        write_data <= cpu_wdata;

                        // Write-through: a resident cached copy is updated now,
                        // while the same byte lanes are also sent to memory.
                        if (cpu_cacheable && cpu_hit) begin
                            updated_word = merge_bytes(
                                select_word(data_array[cpu_index],
                                            cpu_addr[3:2]),
                                cpu_wdata,
                                cpu_wen
                            );
                            case (cpu_addr[3:2])
                                2'd0: data_array[cpu_index][31:0]   <= updated_word;
                                2'd1: data_array[cpu_index][63:32]  <= updated_word;
                                2'd2: data_array[cpu_index][95:64]  <= updated_word;
                                2'd3: data_array[cpu_index][127:96] <= updated_word;
                            endcase
                        end
                        state <= ST_WREQ;
                    end else if (|cpu_ren) begin
                        if (!cpu_cacheable) begin
                            req_addr     <= {cpu_addr[31:2], 2'b00};
                            req_uncached <= 1'b1;
                            state        <= ST_RREQ;
                        end else if (!cpu_hit) begin
                            req_addr     <= {cpu_addr[31:4], 4'b0000};
                            req_uncached <= 1'b0;
                            miss_index   <= cpu_index;
                            miss_tag     <= cpu_tag;
                            state        <= ST_RREQ;
                        end
                    end
                end

                ST_RREQ: begin
                    if (dev_ren && dev_rrdy)
                        state <= ST_RWAIT;
                end

                ST_RWAIT: begin
                    if (dev_rvalid) begin
                        if (!req_uncached) begin
                            data_array[miss_index]  <= dev_rdata;
                            tag_array[miss_index]   <= miss_tag;
                            valid_array[miss_index] <= 1'b1;
                        end
                        state <= ST_IDLE;
                    end
                end

                ST_WREQ: begin
                    if ((|dev_wen) && dev_wrdy)
                        state <= ST_WWAIT;
                end

                ST_WWAIT: begin
                    if (dev_wresp)
                        state <= ST_IDLE;
                end

                default: state <= ST_IDLE;
            endcase
        end
    end

endmodule
