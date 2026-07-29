// -----------------------------------------------------------------------------
// 全工程公共控制码和地址映射
// -----------------------------------------------------------------------------
// RUN_TRACE 只在课程 Trace 仿真时由编译命令打开。下板 CoreMark 必须保持关闭，
// 否则会绕过多周期乘除法，得到与 FPGA 实现不一致的时序模型。
// `define RUN_TRACE

// 当前最终版没有 Cache。这两个宏保留接口兼容性，但不能在验收时宣称已实现 Cache。
// `define ENABLE_ICACHE
// `define ENABLE_DCACHE

// 复位后第一条取指地址。
`define PC_INIT_VAL 32'h0

// ALU 功能码：Controller 译码产生，EX 级送入 ALU。
`define ALU_ADD     5'h00
`define ALU_SUB     5'h01
`define ALU_OR      5'h03
`define ALU_XOR     5'h04
`define ALU_SLL     5'h05
`define ALU_SRL     5'h06
`define ALU_SRA     5'h07
`define ALU_EQ      5'h08
`define ALU_NE      5'h09
`define ALU_AND     5'h0A
`define ALU_SLT     5'h0B
`define ALU_SLTU    5'h0C
`define ALU_MUL     5'h0D
`define ALU_DIV     5'h0E
`define ALU_REM     5'h0F
`define ALU_LT      5'h10
`define ALU_GE      5'h11
`define ALU_LTU     5'h12
`define ALU_GEU     5'h13
`define ALU_MULH    5'h14
`define ALU_MULHU   5'h15
`define ALU_DIVU    5'h16
`define ALU_REMU    5'h17

// 下一 PC 类型：顺序 PC+4、JALR、条件分支、JAL。
`define NPC_PC4     2'b00
`define NPC_JALR    2'b01
`define NPC_BRA     2'b10
`define NPC_JMP     2'b11

// 五类 RISC-V 立即数编码，由 SEXT 使用。
`define EXT_I       3'b000
`define EXT_S       3'b001
`define EXT_B       3'b010
`define EXT_U       3'b011
`define EXT_J       3'b100

// WB 写回数据来源：ALU、内存、PC+4、U 型立即数。
`define WB_ALU      2'b00
`define WB_RAM      2'b01
`define WB_PC4      2'b10
`define WB_EXT      2'b11

// EX 级 ALU A/B 端输入选择。
`define ALU_A_RS1   1'b0
`define ALU_A_PC    1'b1

`define ALU_B_RS2   1'b0
`define ALU_B_EXT   1'b1

// Load 数据扩展类型：不读、整字、有/无符号字节、有/无符号半字。
`define RAM_EXT_N   3'b000
`define RAM_EXT_W   3'b001
`define RAM_EXT_B   3'b010
`define RAM_EXT_BU  3'b011
`define RAM_EXT_H   3'b100
`define RAM_EXT_HU  3'b101

// Store 基础字节使能；MREQ 再根据地址低两位移动到正确 byte lane。
`define RAM_WE_N    4'b0000
`define RAM_WE_B    4'b0001
`define RAM_WE_H    4'b0011
`define RAM_WE_W    4'b1111

// 地址空间。最终 EGO1 版实际片上 BRAM 为 150 KiB，板级模块还会进一步做边界判断。
`define MEM_BLOCK_MEMORY    32'h0000_0000   // 512KB (0x0000_0000 ~ 0x0007_FFFF)
`define MEM_DDR3            32'h2000_0000   // 512MB (0x2000_0000 ~ 0x3FFF_FFFF)
`define PERI_ADDR_SWITCH    32'hFFFF_0000
`define PERI_ADDR_LED       32'hFFFF_1000
`define PERI_ADDR_DIGLED    32'hFFFF_2000
`define PERI_ADDR_UART      32'hFFFF_3000
`define PERI_ADDR_TIMER     32'hFFFF_4000

// Cache 关闭时，一次总线请求只传一个 32 位字；宏打开时预留 4-word burst 宽度。
`ifdef ENABLE_ICACHE
    `define IC_BLK_LEN  4
    `define IC_BLK_SIZE (`IC_BLK_LEN*32)
`else
    `define IC_BLK_LEN  1
    `define IC_BLK_SIZE (`IC_BLK_LEN*32)
`endif

`ifdef ENABLE_DCACHE
    `define DC_BLK_LEN  4
    `define DC_BLK_SIZE (`DC_BLK_LEN*32)
`else
    `define DC_BLK_LEN  1
    `define DC_BLK_SIZE (`DC_BLK_LEN*32)
`endif
