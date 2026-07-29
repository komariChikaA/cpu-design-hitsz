`timescale 1ns / 1ps

`include "defines.vh"

module Controller (
    // ID 级把 32 位指令拆出的三个字段送入组合译码器。
    input  wire [ 6:0]  opcode,
    input  wire [ 2:0]  funct3,
    input  wire [ 6:0]  funct7,
    // 输出控制信号会随 ID/EX 寄存器进入 EX，并继续传到需要的后续级。
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

    // -------------------------------------------------------------------------
    // 第 1 部分：逐条指令识别
    // -------------------------------------------------------------------------
    // 每个 wire 只在 opcode/funct3/funct7 与该指令编码完全匹配时为 1。
    // 基础模板已有的指令。
    wire ADDI = (opcode == 7'b0010011) && (funct3 == 3'b000);
    wire ORI  = (opcode == 7'b0010011) && (funct3 == 3'b110);
    wire SLLI = (opcode == 7'b0010011) && (funct3 == 3'b001) && (funct7 == 7'b0000000);
    wire LW   = (opcode == 7'b0000011) && (funct3 == 3'b010);
    wire BEQ  = (opcode == 7'b1100011) && (funct3 == 3'b000);
    wire BNE  = (opcode == 7'b1100011) && (funct3 == 3'b001);
    wire LUI  = (opcode == 7'b0110111);
    wire JAL  = (opcode == 7'b1101111);

    // A 组扩展的整数、访存和跳转指令。
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

    // B 组扩展的比较、分支和 RV32M 指令。
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

    // -------------------------------------------------------------------------
    // 第 2 部分：按控制行为归类
    // -------------------------------------------------------------------------
    // 后续控制信号无需再次列举每条指令，只判断它属于哪一类。
    wire load_inst    = LB | LBU | LH | LHU | LW;
    wire store_inst   = SB | SH | SW;
    wire branch_inst  = BEQ | BNE | BLT | BGE | BLTU | BGEU;
    wire reg_alu_inst = ADD_R | SUB | XOR_R | SLL_R | SRL_R | SRA_R |
                        AND_R | OR_R | SLT | SLTU;
    wire imm_alu_inst = ADDI | ORI | XORI | SLLI | SRLI | SRAI |
                        SLTI | SLTIU | ANDI;
    wire mul_div_inst = MUL | MULH | MULHU | DIV | DIVU | REM | REMU;

    // -------------------------------------------------------------------------
    // 第 3 部分：生成各级控制信号
    // -------------------------------------------------------------------------
    // 下一 PC 类型：JALR 用 rs1+imm，条件分支用 PC+imm，JAL 用 PC+imm，
    // 其他指令顺序执行 PC+4。是否真的跳转由 EX 级比较结果决定。
    assign npc_op = JALR       ? `NPC_JALR :
                    branch_inst ? `NPC_BRA  :
                    JAL         ? `NPC_JMP  : `NPC_PC4;

    // 只有会产生 rd 结果的指令才允许 WB 写寄存器；branch/store 不写。
    assign rf_we = reg_alu_inst | imm_alu_inst | mul_div_inst | AUIPC |
                   load_inst | LUI | JAL | JALR;

    // WB 四选一：load 数据、跳转返回地址 PC+4、LUI 立即数或 ALU 结果。
    assign rf_wsel = load_inst    ? `WB_RAM :
                     (JAL | JALR) ? `WB_PC4 :
                     LUI          ? `WB_EXT : `WB_ALU;

    // 立即数编码类型；普通 ALU immediate、load 和 JALR 都使用 I 型。
    assign sext_op = store_inst    ? `EXT_S :
                     branch_inst   ? `EXT_B :
                     (LUI | AUIPC) ? `EXT_U :
                     JAL           ? `EXT_J : `EXT_I;

    // ALU 功能选择。没有显式列出的地址计算类指令默认使用 ADD，
    // 包括 ADD/ADDI/AUIPC/load/store/JALR。
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

    // AUIPC 的 A 端使用当前 PC，其他指令使用 rs1。
    assign alua_sel = AUIPC ? `ALU_A_PC : `ALU_A_RS1;
    // immediate、地址计算类指令的 B 端使用扩展立即数，其余使用 rs2。
    assign alub_sel = (imm_alu_inst | AUIPC | load_inst | store_inst | JALR)
                      ? `ALU_B_EXT : `ALU_B_RS2;

    // Load 类型同时决定“是否发读请求”和返回数据的扩展方式。
    assign ram_r_op = LB  ? `RAM_EXT_B  :
                      LBU ? `RAM_EXT_BU :
                      LH  ? `RAM_EXT_H  :
                      LHU ? `RAM_EXT_HU :
                      LW  ? `RAM_EXT_W  : `RAM_EXT_N;

    // Store 类型给出基础 byte enable，MREQ 再按地址 offset 对齐。
    assign ram_w_op = SB ? `RAM_WE_B :
                      SH ? `RAM_WE_H :
                      SW ? `RAM_WE_W : `RAM_WE_N;

    // 这两个分类信号用于调试/接口兼容；实际 ALU 功能仍由 alu_op 唯一确定。
    assign is_mul = MUL | MULH | MULHU;
    assign is_div = DIV | DIVU | REM | REMU;

endmodule
