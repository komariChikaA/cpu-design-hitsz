`timescale 1ns / 1ps

`include "defines.vh"

module MREQ (
    // MEM 级地址和 load/store 控制进入本模块，输出 AXI 数据口需要的
    // 4-bit byte enable、对齐后的写数据以及读使能。
    input  wire [31:0]  ram_addr,

    input  wire [ 2:0]  ram_rop,
    output reg  [ 3:0]  da_ren,
    output wire [31:0]  da_addr,

    input  wire [ 3:0]  ram_wop,
    input  wire [31:0]  ram_wdata,
    output reg  [ 3:0]  da_wen,
    output reg  [31:0]  da_wdata
);

    // 地址低两位决定访问 32 位总线中的哪个字节 lane。
    wire [1:0] offset = ram_addr[1:0];

    // 总线地址保持 CPU 计算结果；板级 Slave 内部再按字地址访问 BRAM。
    assign da_addr = ram_addr;

    // Store 对齐逻辑：把原始 rs2 数据移动到目标 byte lane，并产生 WSTRB。
    always @(*) begin
        da_wen   = 4'h0;
        da_wdata = ram_wdata;

        case (ram_wop)
            // SB：一个字节使能左移 offset，同时数据左移 offset*8。
            `RAM_WE_B: begin
                da_wen   = 4'b0001 << offset;
                da_wdata = ram_wdata << ({offset, 3'b000});
            end

            // SH：允许 offset 0/1/2；offset 3 会跨 32 位边界，当前设计不发写使能。
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

            // SW：只接受 4 字节对齐地址。
            `RAM_WE_W: begin
                if (offset == 2'h0) begin
                    da_wen   = ram_wop;
                    da_wdata = ram_wdata;
                end
            end

            default: ;
        endcase
    end

    // 任何有效 load 类型都发起一次 32 位总线读；MEXT 在返回后截取目标字节/半字。
    always @(*) begin
        if (ram_rop != `RAM_EXT_N)
            da_ren = 4'hF;
        else
            da_ren = 4'h0;
    end

endmodule
