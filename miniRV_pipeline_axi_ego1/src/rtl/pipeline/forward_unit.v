`timescale 1ns / 1ps

`include "defines.vh"

module forward_unit (
    // 当前 EX 指令的源寄存器号。
    input  wire [ 4:0]  ex_rs1,
    input  wire [ 4:0]  ex_rs2,

    // 前一条（MEM 级）指令的目的寄存器、写回使能和 load 类型。
    input  wire [ 4:0]  mem_rd,
    input  wire         mem_rf_we,
    input  wire [ 2:0]  mem_ram_rop,

    // 更早一条（WB 级）指令的目的寄存器和写回使能。
    input  wire [ 4:0]  wb_rd,
    input  wire         wb_rf_we,

    // 00=使用 ID/EX 原值，01=MEM 前递，10=WB 前递。
    output wire [ 1:0]  forward_a_sel,
    output wire [ 1:0]  forward_b_sel
);

    // load 在 MEM 级尚未拿到可前递的数据，不能错误地前递地址 ALU 结果。
    wire mem_is_load = (mem_ram_rop != `RAM_EXT_N);

    // x0 永远为 0，因此 rd=0 不构成数据相关。
    wire fwd_a_ex  = mem_rf_we && !mem_is_load && (mem_rd != 5'h0) && (mem_rd == ex_rs1);
    wire fwd_a_wb  = wb_rf_we  && (wb_rd  != 5'h0) && (wb_rd  == ex_rs1);

    wire fwd_b_ex  = mem_rf_we && !mem_is_load && (mem_rd != 5'h0) && (mem_rd == ex_rs2);
    wire fwd_b_wb  = wb_rf_we  && (wb_rd  != 5'h0) && (wb_rd  == ex_rs2);

    // MEM 比 WB 更新，两个来源同时匹配时必须优先选 MEM。
    assign forward_a_sel = fwd_a_ex ? 2'b01 :
                           fwd_a_wb ? 2'b10 : 2'b00;

    assign forward_b_sel = fwd_b_ex ? 2'b01 :
                           fwd_b_wb ? 2'b10 : 2'b00;

endmodule
