`timescale 1ns / 1ps

// Adapter for the two explicit Block Memory Generator IPs:
//   IROM: 12,800 words (50 KiB), addresses 0x0000_0000..0x0000_C7FF
//   DRAM: 25,600 words (100 KiB), addresses 0x0000_C800..0x0002_57FF
//
// The AXI master permits only one outstanding transaction, so each bank can
// use a single native BMG port. Writes to the IROM range are acknowledged by
// the AXI slave but intentionally ignored here.
module board_bram(
    input  wire        clk,

    input  wire        read_en,
    input  wire [15:0] read_addr,
    output wire [31:0] read_data,

    input  wire [ 3:0] write_en,
    input  wire [15:0] write_addr,
    input  wire [31:0] write_data
);

    localparam [15:0] IROM_WORDS = 16'd12_800;

    wire access_is_write = |write_en;
    wire [15:0] access_addr = access_is_write ? write_addr : read_addr;
    wire access_dram = access_addr >= IROM_WORDS;
    wire [15:0] dram_word_addr = access_addr - IROM_WORDS;
    wire [3:0] dram_write_en = access_dram ? write_en : 4'h0;

    wire [31:0] irom_read_data;
    wire [31:0] dram_read_data;
    reg         read_from_dram;

    always @(posedge clk) begin
        if (read_en)
            read_from_dram <= read_addr >= IROM_WORDS;
    end

    assign read_data = read_from_dram ? dram_read_data : irom_read_data;

    IROM U_program_memory (
        .clka  (clk),
        .addra (read_addr[13:0]),
        .douta (irom_read_data)
    );

    DRAM U_data_memory (
        .clka  (clk),
        .wea   (dram_write_en),
        .addra (dram_word_addr[14:0]),
        .dina  (write_data),
        .douta (dram_read_data)
    );

endmodule
