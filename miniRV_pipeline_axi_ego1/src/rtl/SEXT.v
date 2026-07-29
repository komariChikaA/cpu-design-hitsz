`timescale 1ns / 1ps

`include "defines.vh"

module SEXT (
    // op 指定 I/S/B/U/J 型；imm 是指令 [31:7]，其中包含所有立即数字段。
    input  wire [ 2:0]  op,
    input  wire [31:7]  imm,
    output reg  [31:0]  ext
);

    // 按 RISC-V 不连续位域重新拼接并符号扩展。B/J 最低位补 0，
    // 因为分支和跳转目标至少按 2 字节对齐。
    always @(*) begin
        case (op)
            // I 型：ALU immediate、load、JALR。
            `EXT_I : ext = {{20{imm[31]}}, imm[31:20]};
            // S 型：store，低 5 位来自 inst[11:7]。
            `EXT_S : ext = {{20{imm[31]}}, imm[31:25], imm[11:7]};
            // B 型：条件分支，位域顺序为 imm[12|10:5|4:1|11|0]。
            `EXT_B : ext = {{19{imm[31]}}, imm[31], imm[7], imm[30:25], imm[11:8], 1'b0};
            // U 型：LUI/AUIPC，立即数放在高 20 位。
            `EXT_U : ext = {imm[31:12], 12'h0};
            // J 型：JAL，位域顺序为 imm[20|10:1|11|19:12|0]。
            `EXT_J : ext = {{11{imm[31]}}, imm[31], imm[19:12], imm[20], imm[30:21], 1'b0};
            default: ext = 32'h0;
        endcase
    end

endmodule
