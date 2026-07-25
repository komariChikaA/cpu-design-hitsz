`timescale 1ns / 1ps

`include "defines.vh"

module forward_unit (
    input  wire [ 4:0]  ex_rs1,
    input  wire [ 4:0]  ex_rs2,

    input  wire [ 4:0]  mem_rd,
    input  wire         mem_rf_we,
    input  wire [ 2:0]  mem_ram_rop,

    input  wire [ 4:0]  wb_rd,
    input  wire         wb_rf_we,

    output wire [ 1:0]  forward_a_sel,
    output wire [ 1:0]  forward_b_sel
);

    wire mem_is_load = (mem_ram_rop != `RAM_EXT_N);

    wire fwd_a_ex  = mem_rf_we && !mem_is_load && (mem_rd != 5'h0) && (mem_rd == ex_rs1);
    wire fwd_a_wb  = wb_rf_we  && (wb_rd  != 5'h0) && (wb_rd  == ex_rs1);

    wire fwd_b_ex  = mem_rf_we && !mem_is_load && (mem_rd != 5'h0) && (mem_rd == ex_rs2);
    wire fwd_b_wb  = wb_rf_we  && (wb_rd  != 5'h0) && (wb_rd  == ex_rs2);

    assign forward_a_sel = fwd_a_ex ? 2'b01 :
                           fwd_a_wb ? 2'b10 : 2'b00;

    assign forward_b_sel = fwd_b_ex ? 2'b01 :
                           fwd_b_wb ? 2'b10 : 2'b00;

endmodule
