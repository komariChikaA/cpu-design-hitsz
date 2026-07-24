`timescale 1ns / 1ps

`include "defines.vh"

module Data_RAM_trace (
    input  wire         cpu_clk,
    input  wire         cpu_rst,
    input  wire [ 3:0]  data_ren,
    input  wire [31:0]  data_addr,
    output wire         data_valid,
    output wire [31:0]  data_rdata,
    input  wire [ 3:0]  data_wen,
    input  wire [31:0]  data_wdata,
    output wire         data_wresp
);

    reg [31:0] mem [0:16383];

    assign data_valid = (|data_ren) && !cpu_rst;
    assign data_wresp = (|data_wen) && !cpu_rst;
    assign data_rdata = mem[data_addr[15:2]];

    always @(posedge cpu_clk) begin
        if (data_wen[0]) mem[data_addr[15:2]][ 7: 0] <= data_wdata[ 7: 0];
        if (data_wen[1]) mem[data_addr[15:2]][15: 8] <= data_wdata[15: 8];
        if (data_wen[2]) mem[data_addr[15:2]][23:16] <= data_wdata[23:16];
        if (data_wen[3]) mem[data_addr[15:2]][31:24] <= data_wdata[31:24];
    end

    initial begin : load_binary
        integer fd, idx, b;
        reg [31:0] word;
        fd = $fopen("meminit.bin", "rb");
        if (fd) begin
            idx = 0; word = 0;
            while (!$feof(fd)) begin
                b = $fgetc(fd);
                if (b == -1) begin
                    mem[idx >> 2] = word;
                end else begin
                    word = word | (b << (8 * (idx % 4)));
                    idx = idx + 1;
                    if (idx % 4 == 0) begin
                        mem[(idx >> 2) - 1] = word;
                        word = 0;
                    end
                end
            end
            $fclose(fd);
        end
    end

endmodule
