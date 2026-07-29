`timescale 1ns / 1ps

`include "defines.vh"
`default_nettype none

// -----------------------------------------------------------------------------
// 最终版 RV32IM 五级按序流水线核心
// -----------------------------------------------------------------------------
// 五段：IF 取指、ID 译码/读寄存器、EX 运算/分支、MEM 访存、WB 写回。
// 关键机制：
// - valid 标记真实指令，invalid 表示 bubble；
// - MEM/WB 前递解决大多数 RAW，load-use 额外暂停 1 次并注入 bubble；
// - EX 解析分支并 flush 年轻指令；
// - AXI 访存和多周期 M 扩展用 freeze 保持流水线；
// - 所有寄存器写回和 store Trace 都由 valid/完成响应门控，保证按序一次提交。
module cpu_core(
    // 高有效异步复位和 CPU 时钟。
    input  wire         cpu_rst,
    input  wire         cpu_clk,

    // 简单取指口：req/addr 保持到 cpu_top 返回单拍 valid+inst。
    output wire         ifetch_req   /* verilator public */ ,
    output wire [31:0]  ifetch_addr  /* verilator public */ ,
    input  wire         ifetch_valid /* verilator public */ ,
    input  wire [31:0]  ifetch_inst,

    // 简单数据口：ren/wen 也是 4-bit byte lane；读/写分别以 rvalid/wresp 完成。
    output wire [ 3:0]  daccess_ren,
    output wire [31:0]  daccess_addr,
    input  wire         daccess_rvalid,
    input  wire [31:0]  daccess_rdata,
    output wire [ 3:0]  daccess_wen,
    output wire [31:0]  daccess_wdata,
    input  wire         daccess_wresp,

    // 当前 IF PC 导出给板级 ILA。
    output wire [31:0]  board_debug_pc
);

    // -------------------------------------------------------------------------
    // IF：程序计数器
    // -------------------------------------------------------------------------
    reg [31:0] pc;
    assign board_debug_pc = pc;

    // 更新优先级：reset > EX 重定向 > 正常取指完成。
    // stall_if 时即使后端有旧组合值，也不能让 PC 顺序前进。
    always @(posedge cpu_clk or posedge cpu_rst) begin
        if (cpu_rst)
            pc <= 32'h0;
        else if (ex_bj_f)
            // 分支/JAL/JALR 在 EX 解析，立即把 IF 改到目标地址。
            pc <= ex_bj_target;
        else if (ifetch_valid && !stall_if)
            pc <= pc + 32'h4;
    end

    // -------------------------------------------------------------------------
    // 四级寄存器输出信号：id_*、ex_*、mem_*、wb_*
    // -------------------------------------------------------------------------
    // 每一组的 valid 才表示这些数据属于一条真实、尚未被冲刷的指令。
    wire [31:0] id_pc;
    wire [31:0] id_inst;
    wire        id_valid;

    wire [31:0] ex_pc;
    wire [31:0] ex_rf_rd1;
    wire [31:0] ex_rf_rd2;
    wire [31:0] ex_ext;
    wire [ 4:0] ex_rs1;
    wire [ 4:0] ex_rs2;
    wire [ 4:0] ex_rd;
    wire [ 4:0] ex_alu_op;
    wire        ex_alua_sel;
    wire        ex_alub_sel;
    wire [ 1:0] ex_npc_op;
    wire [ 2:0] ex_ram_rop;
    wire [ 3:0] ex_ram_wop;
    wire        ex_rf_we;
    wire [ 1:0] ex_rf_wsel;
    wire        ex_valid;

    wire [31:0] mem_pc;
    wire [31:0] mem_alu_c;
    wire [31:0] mem_ext;
    wire [31:0] mem_rf_rd2;
    wire [ 4:0] mem_rd;
    wire [ 2:0] mem_ram_rop;
    wire [ 3:0] mem_ram_wop;
    wire        mem_rf_we;
    wire [ 1:0] mem_rf_wsel;
    wire        mem_valid;

    wire [31:0] wb_pc;
    wire [31:0] wb_alu_c;
    wire [31:0] wb_ext;
    wire [31:0] wb_ram_ext;
    wire [ 4:0] wb_rd;
    wire        wb_rf_we;
    wire [ 1:0] wb_rf_wsel;
    wire        wb_valid;

    // -------------------------------------------------------------------------
    // ID：字段拆分和“是否真实使用 rs1/rs2”判断
    // -------------------------------------------------------------------------
    wire [4:0] id_rs1 = id_inst[19:15];
    wire [4:0] id_rs2 = id_inst[24:20];

    wire [6:0] id_opcode = id_inst[6:0];
    // hazard 检测不能只比较指令位域：例如 LUI 的 inst[19:15] 不是 rs1。
    // 因此先按 opcode 判断当前指令语义上是否会读取两个源寄存器。
    wire id_is_r_type = (id_opcode == 7'b0110011);
    wire id_is_i_type = (id_opcode == 7'b0010011 || id_opcode == 7'b0000011 || id_opcode == 7'b1100111);
    wire id_is_s_type = (id_opcode == 7'b0100011);
    wire id_is_b_type = (id_opcode == 7'b1100011);
    wire id_rf1 = id_is_r_type | id_is_i_type | id_is_s_type | id_is_b_type;
    wire id_rf2 = id_is_r_type | id_is_s_type | id_is_b_type;

    // -------------------------------------------------------------------------
    // 四组级间寄存器实例
    // -------------------------------------------------------------------------
    // IF/ID 接取指响应；ID/EX 接译码数据；EX/MEM 接 ALU/store 数据；
    // MEM/WB 接 load 扩展结果。stall/flush/valid 的具体优先级见 pipeline_regs.v。
    pipeline_regs U_PIPE_REGS (
        .clk            (cpu_clk),
        .rst            (cpu_rst),
        .stall_if       (stall_if),
        .stall_id       (stall_id),
        .stall_ex       (stall_ex),
        .stall_mem      (stall_mem),
        .flush          (flush),

        .if_pc          (ifetch_addr),
        .if_inst        (ifetch_inst),
        .if_valid_in    (ifetch_valid),
        .id_pc          (id_pc),
        .id_inst        (id_inst),
        .id_valid       (id_valid),

        .id_pc_in       (id_pc),
        .id_rf_rd1      (rf_rd1_fwd),
        .id_rf_rd2      (rf_rd2_fwd),
        .id_ext         (ext),
        .id_rs1         (id_rs1),
        .id_rs2         (id_rs2),
        .id_rd          (id_inst[11:7]),
        .id_alu_op      (alu_op),
        .id_alua_sel    (alua_sel),
        .id_alub_sel    (alub_sel),
        .id_npc_op      (npc_op),
        .id_ram_rop     (ram_rop),
        .id_ram_wop     (ram_wop),
        .id_rf_we       (rf_we),
        .id_rf_wsel     (rf_wsel),
        // hazard 时把真实 ID 指令变成 bubble，而不是把错误控制推进 EX。
        .id_valid_in    (id_valid_for_ex),
        .ex_pc          (ex_pc),
        .ex_rf_rd1      (ex_rf_rd1),
        .ex_rf_rd2      (ex_rf_rd2),
        .ex_ext         (ex_ext),
        .ex_rs1         (ex_rs1),
        .ex_rs2         (ex_rs2),
        .ex_rd          (ex_rd),
        .ex_alu_op      (ex_alu_op),
        .ex_alua_sel    (ex_alua_sel),
        .ex_alub_sel    (ex_alub_sel),
        .ex_npc_op      (ex_npc_op),
        .ex_ram_rop     (ex_ram_rop),
        .ex_ram_wop     (ex_ram_wop),
        .ex_rf_we       (ex_rf_we),
        .ex_rf_wsel     (ex_rf_wsel),
        .ex_valid       (ex_valid),

        .ex_pc_in       (ex_pc),
        .ex_alu_c       (alu_c),
        .ex_ext_in      (ex_ext),
        // store 的写数据也必须使用前递结果，否则 sw 紧跟生产者会写旧值。
        .ex_rf_rd2_in   (fwd_store_data),
        .ex_rd_in       (ex_rd),
        .ex_ram_rop_in  (ex_ram_rop),
        .ex_ram_wop_in  (ex_ram_wop),
        .ex_rf_we_in    (ex_rf_we),
        .ex_rf_wsel_in  (ex_rf_wsel),
        .ex_valid_in    (ex_valid),
        .mem_pc         (mem_pc),
        .mem_alu_c      (mem_alu_c),
        .mem_ext        (mem_ext),
        .mem_rf_rd2     (mem_rf_rd2),
        .mem_rd         (mem_rd),
        .mem_ram_rop    (mem_ram_rop),
        .mem_ram_wop    (mem_ram_wop),
        .mem_rf_we      (mem_rf_we),
        .mem_rf_wsel    (mem_rf_wsel),
        .mem_valid      (mem_valid),

        .mem_pc_in      (mem_pc),
        .mem_alu_c_in   (mem_alu_c),
        .mem_ext_in     (mem_ext),
        // load 返回数据在 MEM 经 MEXT 对齐/扩展后进入 WB。
        .mem_ram_ext    (ram_ext),
        .mem_rd_in      (mem_rd),
        .mem_rf_we_in   (mem_rf_we),
        .mem_rf_wsel_in (mem_rf_wsel),
        .mem_valid_in   (mem_valid),
        .wb_pc          (wb_pc),
        .wb_alu_c       (wb_alu_c),
        .wb_ext         (wb_ext),
        .wb_ram_ext     (wb_ram_ext),
        .wb_rd          (wb_rd),
        .wb_rf_we       (wb_rf_we),
        .wb_rf_wsel     (wb_rf_wsel),
        .wb_valid       (wb_valid)
    );

    // -------------------------------------------------------------------------
    // ID：Controller 组合译码
    // -------------------------------------------------------------------------
    wire [ 1:0] npc_op;
    wire [ 1:0] rf_wsel;
    wire [ 2:0] sext_op;
    wire [ 4:0] alu_op;
    wire        alua_sel;
    wire        alub_sel;
    wire [ 2:0] ram_rop;
    wire [ 3:0] ram_wop;
    wire        rf_we;
    wire        is_mul;
    wire        is_div;

    // 输入 opcode/funct，输出下一 PC、立即数、ALU、访存和 WB 控制。
    Controller U_CU (
        .opcode         (id_inst[6:0]),
        .funct3         (id_inst[14:12]),
        .funct7         (id_inst[31:25]),
        .npc_op         (npc_op),
        .sext_op        (sext_op),
        .alu_op         (alu_op),
        .alua_sel       (alua_sel),
        .alub_sel       (alub_sel),
        .is_mul         (is_mul),
        .is_div         (is_div),
        .ram_r_op       (ram_rop),
        .ram_w_op       (ram_wop),
        .rf_we          (rf_we),
        .rf_wsel        (rf_wsel)
    );

    // -------------------------------------------------------------------------
    // ID/WB：寄存器堆与同拍写后读旁路
    // -------------------------------------------------------------------------
    wire [31:0] rf_rd1;
    wire [31:0] rf_rd2;

    // ID 组合读 rs1/rs2；WB 在上升沿写 rd。valid 门控防止 bubble 写寄存器。
    RF U_RF (
        .clk        (cpu_clk),
        .rst        (cpu_rst),
        .rR1        (id_rs1),
        .rR2        (id_rs2),
        .rD1        (rf_rd1),
        .rD2        (rf_rd2),
        .we         (wb_rf_we && wb_valid),
        .wR         (wb_rd),
        .wD         (rf_wD)
    );

    // 若 WB 正在写的 rd 恰好是 ID 本拍读取的 rs，直接选择 rf_wD。
    // 这消除了不同 FPGA 寄存器堆“同拍读写同地址”行为差异。
    wire wb_fwd_rs1 = wb_rf_we && wb_valid && (wb_rd != 5'h0) && (wb_rd == id_rs1)
                      && id_rf1 && id_valid;
    wire wb_fwd_rs2 = wb_rf_we && wb_valid && (wb_rd != 5'h0) && (wb_rd == id_rs2)
                      && id_rf2 && id_valid;
    wire [31:0] rf_rd1_fwd = wb_fwd_rs1 ? rf_wD : rf_rd1;
    wire [31:0] rf_rd2_fwd = wb_fwd_rs2 ? rf_wD : rf_rd2;

    // 立即数扩展结果与当前 ID 指令一起进入 ID/EX。
    wire [31:0] ext;

    SEXT U_SEXT (
        .op         (sext_op),
        .imm        (id_inst[31:7]),
        .ext        (ext)
    );

    // -------------------------------------------------------------------------
    // 数据冒险 1：load-use
    // -------------------------------------------------------------------------
    // EX 中的 load 数据要到 AXI 返回并进入 WB 才可用，MEM 级不能前递地址结果。
    wire ex_is_load   = (ex_ram_rop != `RAM_EXT_N) && ex_valid;
    wire id_uses_rs1  = id_rf1 && id_valid;
    wire id_uses_rs2  = id_rf2 && id_valid;
    // 仅当 ID 真实使用的源寄存器与 load rd 相等时命中；rd=0 不相关。
    wire load_use_hazard = ex_is_load && ex_rf_we && (ex_rd != 5'h0) &&
                           ((id_uses_rs1 && (ex_rd == id_rs1)) ||
                            (id_uses_rs2 && (ex_rd == id_rs2)));

    // ID/EX 是否为访存指令，用于冻结和避免长延迟指令重复进入 EX。
    wire id_is_ld_st = ((ram_rop != `RAM_EXT_N) || (ram_wop != `RAM_WE_N)) && id_valid;
    wire ex_is_ld_st = ((ex_ram_rop != `RAM_EXT_N) || (ex_ram_wop != `RAM_WE_N)) && ex_valid;

    // -------------------------------------------------------------------------
    // AXI 数据访问等待
    // -------------------------------------------------------------------------
    // ld_st_suspend 从访存进入 EX 后保持，直到 R 响应或 B 响应到达。
    reg ld_st_suspend;
    wire ld_st_done = daccess_rvalid || daccess_wresp;
    // 完成优先于重新置位，保证响应拍只结束一次事务。
    always @(posedge cpu_clk or posedge cpu_rst) begin
        if (cpu_rst)
            ld_st_suspend <= 1'b0;
        else if (ld_st_done)
            ld_st_suspend <= 1'b0;
        else if (ex_is_ld_st && !ld_st_done)
            ld_st_suspend <= 1'b1;
    end

    // -------------------------------------------------------------------------
    // 多周期 M 扩展等待
    // -------------------------------------------------------------------------
    wire id_is_mul_div = (is_mul || is_div) && id_valid;
    wire ex_is_mul_div = ((ex_alu_op == `ALU_MUL)  || (ex_alu_op == `ALU_MULH) ||
                          (ex_alu_op == `ALU_MULHU) || (ex_alu_op == `ALU_DIV)  ||
                          (ex_alu_op == `ALU_DIVU)  || (ex_alu_op == `ALU_REM)  ||
                          (ex_alu_op == `ALU_REMU))  && ex_valid;

    // busy 的下降沿表示 worker 刚完成；记录前一拍用于产生单拍 mul_div_done。
    reg ex_mul_div_busy_d;
    always @(posedge cpu_clk or posedge cpu_rst) begin
        if (cpu_rst)
            ex_mul_div_busy_d <= 1'b0;
        else
            ex_mul_div_busy_d <= ex_mul_div_busy;
    end
    wire mul_div_done = ex_mul_div_busy_d && !ex_mul_div_busy;

    // -------------------------------------------------------------------------
    // EX：控制冒险、目标地址与 taken 判定
    // -------------------------------------------------------------------------
    wire ex_is_branch = (ex_npc_op == `NPC_BRA) && ex_valid;
    wire ex_is_jal    = (ex_npc_op == `NPC_JMP) && ex_valid;
    wire ex_is_jalr   = (ex_npc_op == `NPC_JALR) && ex_valid;

    wire [31:0] ex_bj_target;
    // JALR 目标来自 rs1+imm(ALU 结果)，并强制 bit0=0；branch/JAL 为 PC+imm。
    assign ex_bj_target = ex_is_jalr ? {alu_c[31:1], 1'b0} : (ex_pc + ex_ext);

    // Trace 零延迟模型可能已把目标指令放进 ID，实板 AXI 则不能以暂时地址相等
    // 证明目标响应安全，因此两种构建采用不同 flush 判据。
    wire ex_bj_target_in_id = id_valid && (id_pc == ex_bj_target);
    wire ex_bj_taken = (ex_is_branch && br) || ex_is_jal || ex_is_jalr;
    wire ex_bj_f;
`ifdef RUN_TRACE
    // Trace：目标已在 ID 时抑制重复 flush，匹配课程零延迟存储模型契约。
    assign ex_bj_f = ex_bj_taken && !ex_bj_target_in_id;
`else
    // 实板 AXI：taken 永远重定向；在途旧取指由 cpu_top 地址过滤器丢弃。
    assign ex_bj_f = ex_bj_taken;
`endif

    // -------------------------------------------------------------------------
    // 全局 stall/flush 组合
    // -------------------------------------------------------------------------
    wire stall_if, stall_id, stall_ex, stall_mem;

    // 访存或 M worker 未完成时，ID/EX 及其前级必须保持，保证按序执行。
    wire memory_freeze = ld_st_suspend && !ld_st_done;
    wire effective_freeze = memory_freeze || ex_mul_div_busy;

    // entering 用于暂停新的取指；duplicate 表示同一类长延迟指令同时驻留 ID/EX，
    // 此时不应让 ID 再次进入 EX。
    wire load_entering_id = id_is_ld_st   && !ex_is_ld_st;
    wire mul_entering_id  = id_is_mul_div && !ex_is_mul_div;
    wire load_duplicate   = id_is_ld_st   && ex_is_ld_st;
    wire mul_duplicate    = id_is_mul_div && ex_is_mul_div;

    // 访存/M 指令第一次进入 EX 时必须从 ID 被消费，不能单纯因 entering 就保持 IF/ID，
    // 否则完成后同一条会第二次进入 EX。此前 UART 轮询因此把 load 结果当新基址，
    // 地址从 0xFFFF3008 漂移到 0x8/指令字。现在仅在真实相关、duplicate 或 freeze
    // 时保持 IF。
    assign stall_if  = load_use_hazard || load_duplicate || mul_duplicate ||
                       effective_freeze;
    // freeze 时从 ID 到 MEM 的相关边界一起保持；MEM/WB 只在数据事务未完成时保持。
    assign stall_id  = effective_freeze;
    assign stall_ex  = effective_freeze;
    assign stall_mem = (ld_st_suspend) && !ld_st_done;

    // load-use/duplicate 时不推进真实 ID 指令，而向 ID/EX 注入 invalid bubble。
    wire id_valid_for_ex;
    assign id_valid_for_ex = id_valid && !load_use_hazard && !load_duplicate && !mul_duplicate;

    // taken 分支冲刷 IF/ID 和 ID/EX；老于分支的 MEM/WB 不受影响。
    wire flush;
    assign flush = ex_bj_f;

    // -------------------------------------------------------------------------
    // 数据冒险 2：EX 操作数前递
    // -------------------------------------------------------------------------
    wire [1:0] forward_a_sel;
    wire [1:0] forward_b_sel;

    // forward_unit 输出 00=原 ID/EX，01=MEM，10=WB；MEM 优先且 load 不从 MEM 前递。
    forward_unit U_FWD (
        .ex_rs1         (ex_rs1),
        .ex_rs2         (ex_rs2),
        .mem_rd         (mem_rd),
        .mem_rf_we      (mem_rf_we && mem_valid),
        .mem_ram_rop    (mem_ram_rop),
        .wb_rd          (wb_rd),
        .wb_rf_we       (wb_rf_we && wb_valid),
        .forward_a_sel  (forward_a_sel),
        .forward_b_sel  (forward_b_sel)
    );

    // MEM 级可前递的值只有 ALU/U immediate/PC+4。load 数据此时尚未完成，
    // 已由 forward_unit 的 mem_is_load 禁止选择。
    wire [31:0] mem_wb_data;
    assign mem_wb_data = (mem_rf_wsel == `WB_EXT) ? mem_ext :
                         (mem_rf_wsel == `WB_PC4) ? (mem_pc + 32'h4) :
                                                    mem_alu_c;

    wire [31:0] fwd_a;
    wire [31:0] fwd_b;

    // 多周期 ALU 在启动沿锁存操作数，因此启动拍也必须使用前递值，不能绕回旧 RF 数据。
    assign fwd_a = (forward_a_sel == 2'b01) ? mem_wb_data :
                   (forward_a_sel == 2'b10) ? rf_wD       : ex_rf_rd1;

    assign fwd_b = (forward_b_sel == 2'b01) ? mem_wb_data :
                   (forward_b_sel == 2'b10) ? rf_wD       : ex_rf_rd2;

    // rs2 既可能是 ALU B，也可能是 store 写数据；store 路径单独明确前递。
    wire [31:0] fwd_store_data;
    assign fwd_store_data = (forward_b_sel == 2'b01) ? mem_wb_data :
                            (forward_b_sel == 2'b10) ? rf_wD       : ex_rf_rd2;

    // -------------------------------------------------------------------------
    // EX：ALU 输入选择和执行
    // -------------------------------------------------------------------------
    wire [31:0] alu_a;
    wire [31:0] alu_b;
    wire [31:0] alu_c;
    wire        br;
    wire        ex_mul_div_busy;

    // AUIPC 的 A=PC；立即数/地址类 B=ext；其余选择前递后的 rs1/rs2。
    assign alu_a = ex_alua_sel ? ex_pc : fwd_a;
    assign alu_b = ex_alub_sel ? ex_ext : fwd_b;

    // bubble 的数据/控制寄存器可能保留旧值，但 valid=0。把 ALU op 强制为 ADD，
    // 防止旧 M 功能码在 invalid bubble 上重新启动 worker。
    wire [4:0] active_alu_op = ex_valid ? ex_alu_op : `ALU_ADD;

    // RUN_TRACE 选择组合 ALU_trace；实板选择带 busy 的 ALU_multicycle。
    ALU U_ALU (
        .rst        (cpu_rst),
        .clk        (cpu_clk),
        .op         (active_alu_op),
        .a          (alu_a),
        .b          (alu_b),
        .br         (br),
        .c          (alu_c),
        .busy       (ex_mul_div_busy)
    );

    // -------------------------------------------------------------------------
    // MEM：请求对齐、AXI 数据口和 load 扩展
    // -------------------------------------------------------------------------
    wire [ 3:0] da_ren;
    wire [31:0] da_addr;
    wire [ 3:0] da_wen;
    wire [31:0] da_wdata;
    wire [31:0] ram_ext;

    // MREQ 把 SB/SH/SW 的 rs2 对齐到 byte lane，并产生 ren/wen/addr/wdata。
    MREQ U_MEM_REQ (
        .ram_addr   (mem_alu_c),
        .ram_rop    (mem_ram_rop),
        .da_ren     (da_ren),
        .da_addr    (da_addr),
        .ram_wop    (mem_ram_wop),
        .ram_wdata  (mem_rf_rd2),
        .da_wen     (da_wen),
        .da_wdata   (da_wdata)
    );

    // MEXT 按地址 offset 选出字节/半字并执行有符号或零扩展。
    MEXT U_MEM_EXT (
        .op             (mem_ram_rop),
        .din            (daccess_rdata),
        .byte_offs      (mem_alu_c[1:0]),
        .ext            (ram_ext)
    );

    // 只有有效 MEM 指令可驱动请求，bubble 中残留的访存控制绝不能访问外设。
    wire mem_op_active = mem_valid && ((mem_ram_rop != `RAM_EXT_N) || (mem_ram_wop != `RAM_WE_N));

    assign daccess_ren   = mem_op_active ? da_ren   : 4'h0;
    assign daccess_addr  = da_addr;
    assign daccess_wen   = mem_op_active ? da_wen   : 4'h0;
    assign daccess_wdata = da_wdata;

    // -------------------------------------------------------------------------
    // WB：四选一写回
    // -------------------------------------------------------------------------
    reg [31:0] rf_wD;

    // 与 Controller 的 rf_wsel 对应：ALU/load/PC+4/U immediate。
    always @(*) begin
        case (wb_rf_wsel)
            `WB_ALU : rf_wD = wb_alu_c;
            `WB_RAM : rf_wD = wb_ram_ext;
            `WB_PC4 : rf_wD = wb_pc + 32'h4;
            `WB_EXT : rf_wD = wb_ext;
            default : rf_wD = wb_alu_c;
        endcase
    end

    // -------------------------------------------------------------------------
    // IF 请求门控
    // -------------------------------------------------------------------------
    // 进入长延迟操作时暂停发新取指；完成沿用 resume_ifetch 强制立即恢复，
    // 避免组合 pause 尚未撤销导致多空一拍或停住。
    wire pause_ifetch = load_use_hazard ||
                        load_entering_id ||
                        ((ld_st_suspend || ex_is_ld_st) && !ld_st_done) ||
                        mul_entering_id ||
                        ex_mul_div_busy;

    wire resume_ifetch = ld_st_done || mul_div_done;

    assign ifetch_req  = resume_ifetch | !pause_ifetch;

    // 分支重定向当拍直接把目标地址送给 cpu_top，否则请求当前 PC。
    assign ifetch_addr = ex_bj_f ? ex_bj_target : pc;

`ifdef RUN_TRACE
    // -------------------------------------------------------------------------
    // 课程 Trace 观测口
    // -------------------------------------------------------------------------
    // verilator public 让外部 C++ 测试读取按序 WB 提交和 store 提交信息。
    wire [31:0] debug_wb_pc    /* verilator public */ ;
    wire        debug_wb_rf_we /* verilator public */ ;
    wire [ 4:0] debug_wb_rf_wR /* verilator public */ ;
    wire [31:0] debug_wb_rf_wD /* verilator public */ ;

    wire [31:0] debug_mem_pc    /* verilator public */ ;
    wire [ 3:0] debug_mem_we    /* verilator public */ ;
    wire [31:0] debug_mem_waddr /* verilator public */ ;
    wire [31:0] debug_mem_wdata /* verilator public */ ;

    assign debug_wb_pc    = wb_pc;
    assign debug_wb_rf_we = wb_rf_we && wb_valid;
    assign debug_wb_rf_wR = wb_rd;
    assign debug_wb_rf_wD = rf_wD;

    assign debug_mem_pc    = mem_pc;
    // AXI 等待期间 daccess_wen 会保持多拍；只在写响应完成拍报告一次架构 store，
    // 防止 Trace 把等待周期误认为重复写。
    assign debug_mem_we    = daccess_wresp ? daccess_wen : 4'h0;
    assign debug_mem_waddr = daccess_addr;
    assign debug_mem_wdata = daccess_wdata;
`endif

endmodule

`default_nettype wire
