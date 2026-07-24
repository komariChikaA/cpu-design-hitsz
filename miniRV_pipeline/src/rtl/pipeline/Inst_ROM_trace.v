`timescale 1ns / 1ps

`include "defines.vh"

module Inst_ROM_trace (
    input  wire         cpu_clk,
    input  wire         cpu_rst,
    input  wire         inst_rreq,
    input  wire [31:0]  inst_addr,
    output wire         inst_valid,
    output wire [31:0]  inst_out
);

    reg [31:0] mem [0:16383];

    assign inst_valid = inst_rreq && !cpu_rst;
    assign inst_out   = mem[inst_addr[15:2]];

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
