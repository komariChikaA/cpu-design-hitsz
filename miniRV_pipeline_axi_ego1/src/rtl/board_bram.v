`timescale 1ns / 1ps

// -----------------------------------------------------------------------------
// 板级 150 KiB BRAM 适配器
// -----------------------------------------------------------------------------
// 两个显式 Block Memory Generator IP 拼成连续地址空间：
//   IROM：12,800 words（50 KiB），0x0000_0000..0x0000_C7FF；
//   DRAM：25,600 words（100 KiB），0x0000_C800..0x0002_57FF。
//
// AXI Master 最多只有一个未完成事务，所以每个 BRAM 只需单端口。IROM 区写请求
// 在 AXI Slave 层仍会获得响应，但在本模块中有意屏蔽，不修改程序区。
module board_bram(
    input  wire        clk,

    input  wire        read_en,
    input  wire [15:0] read_addr,
    output wire [31:0] read_data,

    input  wire [ 3:0] write_en,
    input  wire [15:0] write_addr,
    input  wire [31:0] write_data
);

    // 下面地址均为“字地址”，不是字节地址。
    localparam [15:0] IROM_WORDS = 16'd12_800;

    // 读写共用 BRAM 端口地址；有任意写使能时优先使用 write_addr。
    wire access_is_write = |write_en;
    wire [15:0] access_addr = access_is_write ? write_addr : read_addr;
    wire access_dram = access_addr >= IROM_WORDS;
    wire [15:0] dram_word_addr = access_addr - IROM_WORDS;
    wire [3:0] dram_write_en = access_dram ? write_en : 4'h0;

    wire [31:0] irom_read_data;
    wire [31:0] dram_read_data;
    // BMG 为同步读，数据下一拍返回，所以必须同步记住上一拍选择的是 IROM 还是 DRAM。
    reg         read_from_dram;

    always @(posedge clk) begin
        if (read_en)
            read_from_dram <= read_addr >= IROM_WORDS;
    end

    // 与同步选择寄存器配合，在返回拍选中正确 bank 的数据。
    assign read_data = read_from_dram ? dram_read_data : irom_read_data;

    // 程序存储器只读。
    IROM U_program_memory (
        .clka  (clk),
        .addra (read_addr[13:0]),
        .douta (irom_read_data)
    );

    // 数据存储器支持 4 个独立 byte write enable。
    DRAM U_data_memory (
        .clka  (clk),
        .wea   (dram_write_en),
        .addra (dram_word_addr[14:0]),
        .dina  (write_data),
        .douta (dram_read_data)
    );

endmodule
