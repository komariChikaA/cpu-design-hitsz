`timescale 1ns / 1ps

`include "defines.vh"

module Controller (
    input  wire [ 6:0]  opcode,
    input  wire [ 2:0]  funct3,
    input  wire [ 6:0]  funct7,
    output wire [ 1:0]  npc_op,
    output wire [ 2:0]  sext_op,
    output wire         alua_sel,
    output wire         alub_sel,
    output wire [ 4:0]  alu_op,
    output wire         is_mul,
    output wire         is_div,
    output wire [ 2:0]  ram_r_op,
    output wire [ 3:0]  ram_w_op,
    output wire         rf_we,
    output wire [ 1:0]  rf_wsel
);

    // Instructions already supplied by the template.
    wire ADDI = (opcode == 7'b0010011) && (funct3 == 3'b000);
    wire ORI  = (opcode == 7'b0010011) && (funct3 == 3'b110);
    wire SLLI = (opcode == 7'b0010011) && (funct3 == 3'b001) && (funct7 == 7'b0000000);
    wire LW   = (opcode == 7'b0000011) && (funct3 == 3'b010);
    wire BEQ  = (opcode == 7'b1100011) && (funct3 == 3'b000);
    wire BNE  = (opcode == 7'b1100011) && (funct3 == 3'b001);
    wire LUI  = (opcode == 7'b0110111);
    wire JAL  = (opcode == 7'b1101111);

    // miniRV group A instructions.
    wire ADD_R = (opcode == 7'b0110011) && (funct3 == 3'b000) && (funct7 == 7'b0000000);
    wire SUB   = (opcode == 7'b0110011) && (funct3 == 3'b000) && (funct7 == 7'b0100000);
    wire AUIPC = (opcode == 7'b0010111);
    wire XOR_R = (opcode == 7'b0110011) && (funct3 == 3'b100) && (funct7 == 7'b0000000);
    wire XORI  = (opcode == 7'b0010011) && (funct3 == 3'b100);
    wire SLL_R = (opcode == 7'b0110011) && (funct3 == 3'b001) && (funct7 == 7'b0000000);
    wire SRL_R = (opcode == 7'b0110011) && (funct3 == 3'b101) && (funct7 == 7'b0000000);
    wire SRLI  = (opcode == 7'b0010011) && (funct3 == 3'b101) && (funct7 == 7'b0000000);
    wire SRA_R = (opcode == 7'b0110011) && (funct3 == 3'b101) && (funct7 == 7'b0100000);
    wire SRAI  = (opcode == 7'b0010011) && (funct3 == 3'b101) && (funct7 == 7'b0100000);
    wire LB    = (opcode == 7'b0000011) && (funct3 == 3'b000);
    wire LBU   = (opcode == 7'b0000011) && (funct3 == 3'b100);
    wire LH    = (opcode == 7'b0000011) && (funct3 == 3'b001);
    wire LHU   = (opcode == 7'b0000011) && (funct3 == 3'b101);
    wire SW    = (opcode == 7'b0100011) && (funct3 == 3'b010);
    wire SB    = (opcode == 7'b0100011) && (funct3 == 3'b000);
    wire SH    = (opcode == 7'b0100011) && (funct3 == 3'b001);
    wire JALR  = (opcode == 7'b1100111) && (funct3 == 3'b000);

    // miniRV group B instructions.
    wire AND_R = (opcode == 7'b0110011) && (funct3 == 3'b111) && (funct7 == 7'b0000000);
    wire OR_R  = (opcode == 7'b0110011) && (funct3 == 3'b110) && (funct7 == 7'b0000000);
    wire SLT   = (opcode == 7'b0110011) && (funct3 == 3'b010) && (funct7 == 7'b0000000);
    wire SLTU  = (opcode == 7'b0110011) && (funct3 == 3'b011) && (funct7 == 7'b0000000);
    wire SLTI  = (opcode == 7'b0010011) && (funct3 == 3'b010);
    wire SLTIU = (opcode == 7'b0010011) && (funct3 == 3'b011);
    wire ANDI  = (opcode == 7'b0010011) && (funct3 == 3'b111);
    wire BLT   = (opcode == 7'b1100011) && (funct3 == 3'b100);
    wire BGE   = (opcode == 7'b1100011) && (funct3 == 3'b101);
    wire BLTU  = (opcode == 7'b1100011) && (funct3 == 3'b110);
    wire BGEU  = (opcode == 7'b1100011) && (funct3 == 3'b111);
    wire MUL   = (opcode == 7'b0110011) && (funct3 == 3'b000) && (funct7 == 7'b0000001);
    wire MULH  = (opcode == 7'b0110011) && (funct3 == 3'b001) && (funct7 == 7'b0000001);
    wire MULHU = (opcode == 7'b0110011) && (funct3 == 3'b011) && (funct7 == 7'b0000001);
    wire DIV   = (opcode == 7'b0110011) && (funct3 == 3'b100) && (funct7 == 7'b0000001);
    wire DIVU  = (opcode == 7'b0110011) && (funct3 == 3'b101) && (funct7 == 7'b0000001);
    wire REM   = (opcode == 7'b0110011) && (funct3 == 3'b110) && (funct7 == 7'b0000001);
    wire REMU  = (opcode == 7'b0110011) && (funct3 == 3'b111) && (funct7 == 7'b0000001);

    wire load_inst    = LB | LBU | LH | LHU | LW;
    wire store_inst   = SB | SH | SW;
    wire branch_inst  = BEQ | BNE | BLT | BGE | BLTU | BGEU;
    wire reg_alu_inst = ADD_R | SUB | XOR_R | SLL_R | SRL_R | SRA_R |
                        AND_R | OR_R | SLT | SLTU;
    wire imm_alu_inst = ADDI | ORI | XORI | SLLI | SRLI | SRAI |
                        SLTI | SLTIU | ANDI;
    wire mul_div_inst = MUL | MULH | MULHU | DIV | DIVU | REM | REMU;

    assign npc_op = JALR       ? `NPC_JALR :
                    branch_inst ? `NPC_BRA  :
                    JAL         ? `NPC_JMP  : `NPC_PC4;

    assign rf_we = reg_alu_inst | imm_alu_inst | mul_div_inst | AUIPC |
                   load_inst | LUI | JAL | JALR;

    assign rf_wsel = load_inst    ? `WB_RAM :
                     (JAL | JALR) ? `WB_PC4 :
                     LUI          ? `WB_EXT : `WB_ALU;

    assign sext_op = store_inst    ? `EXT_S :
                     branch_inst   ? `EXT_B :
                     (LUI | AUIPC) ? `EXT_U :
                     JAL           ? `EXT_J : `EXT_I;

    assign alu_op = SUB              ? `ALU_SUB  :
                    (ORI | OR_R)     ? `ALU_OR   :
                    (XOR_R | XORI)   ? `ALU_XOR  :
                    (SLL_R | SLLI)   ? `ALU_SLL  :
                    (SRL_R | SRLI)   ? `ALU_SRL  :
                    (SRA_R | SRAI)   ? `ALU_SRA  :
                    (AND_R | ANDI)   ? `ALU_AND  :
                    (SLT | SLTI)     ? `ALU_SLT  :
                    (SLTU | SLTIU)   ? `ALU_SLTU :
                    MUL               ? `ALU_MUL  :
                    MULH              ? `ALU_MULH :
                    MULHU             ? `ALU_MULHU:
                    DIV               ? `ALU_DIV  :
                    DIVU              ? `ALU_DIVU :
                    REM               ? `ALU_REM  :
                    REMU              ? `ALU_REMU :
                    BEQ               ? `ALU_EQ   :
                    BNE               ? `ALU_NE   :
                    BLT               ? `ALU_LT   :
                    BGE               ? `ALU_GE   :
                    BLTU              ? `ALU_LTU  :
                    BGEU              ? `ALU_GEU  : `ALU_ADD;

    assign alua_sel = AUIPC ? `ALU_A_PC : `ALU_A_RS1;
    assign alub_sel = (imm_alu_inst | AUIPC | load_inst | store_inst | JALR)
                      ? `ALU_B_EXT : `ALU_B_RS2;

    assign ram_r_op = LB  ? `RAM_EXT_B  :
                      LBU ? `RAM_EXT_BU :
                      LH  ? `RAM_EXT_H  :
                      LHU ? `RAM_EXT_HU :
                      LW  ? `RAM_EXT_W  : `RAM_EXT_N;

    assign ram_w_op = SB ? `RAM_WE_B :
                      SH ? `RAM_WE_H :
                      SW ? `RAM_WE_W : `RAM_WE_N;

    assign is_mul = MUL | MULH | MULHU;
    assign is_div = DIV | DIVU | REM | REMU;

endmodule
