`timescale 1ns / 1ps

`include "defines.vh"

module MREQ (
    input  wire [31:0]  ram_addr,

    input  wire [ 2:0]  ram_rop,
    output reg  [ 3:0]  da_ren,
    output wire [31:0]  da_addr,

    input  wire [ 3:0]  ram_wop,
    input  wire [31:0]  ram_wdata,
    output reg  [ 3:0]  da_wen,
    output reg  [31:0]  da_wdata
);

    wire [1:0] offset = ram_addr[1:0];

    assign da_addr = ram_addr;

    always @(*) begin
        da_wen   = 4'h0;
        da_wdata = ram_wdata;

        case (ram_wop)
            `RAM_WE_B: begin
                da_wen   = 4'b0001 << offset;
                da_wdata = ram_wdata << ({offset, 3'b000});
            end

            `RAM_WE_H: begin
                case (offset)
                    2'b00: begin
                        da_wen   = 4'b0011;
                        da_wdata = ram_wdata;
                    end
                    2'b01: begin
                        da_wen   = 4'b0110;
                        da_wdata = ram_wdata << 8;
                    end
                    2'b10: begin
                        da_wen   = 4'b1100;
                        da_wdata = {ram_wdata[15:0], 16'h0};
                    end
                    default: ;
                endcase
            end

            `RAM_WE_W: begin
                if (offset == 2'h0) begin
                    da_wen   = ram_wop;
                    da_wdata = ram_wdata;
                end
            end

            default: ;
        endcase
    end

    always @(*) begin
        if (ram_rop != `RAM_EXT_N)
            da_ren = 4'hF;
        else
            da_ren = 4'h0;
    end

endmodule
