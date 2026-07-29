`timescale 1ns / 1ps

// -----------------------------------------------------------------------------
// 五级流水线的四组级间寄存器
// -----------------------------------------------------------------------------
// 数据方向：IF -> [IF/ID] -> ID -> [ID/EX] -> EX -> [EX/MEM] -> MEM
//           -> [MEM/WB] -> WB。
// valid 位与数据一起流动：valid=0 表示 bubble，即便其他寄存器仍保留旧值也不能提交。
// stall_x=1 表示对应边界保持原值；flush 只清除分支后尚未提交的 IF/ID 和 ID/EX。
module pipeline_regs (
    input  wire         clk,
    input  wire         rst,

    // 四个边界的保持控制；名字表示“不要让该级输入推进到下一边界”。
    input  wire         stall_if,
    input  wire         stall_id,
    input  wire         stall_ex,
    input  wire         stall_mem,
    // EX 判定 taken branch/jump 后清除年轻指令。
    input  wire         flush,

    // IF -> IF/ID 输入：取回的 PC、指令和本次响应是否有效。
    input  wire [31:0]  if_pc,
    input  wire [31:0]  if_inst,
    input  wire         if_valid_in,

    // IF/ID -> ID 输出。
    output wire [31:0]  id_pc,
    output wire [31:0]  id_inst,
    output wire         id_valid,

    // ID -> ID/EX 输入：寄存器值、立即数、寄存器号和全部 EX/MEM/WB 控制。
    input  wire [31:0]  id_pc_in,
    input  wire [31:0]  id_rf_rd1,
    input  wire [31:0]  id_rf_rd2,
    input  wire [31:0]  id_ext,
    input  wire [ 4:0]  id_rs1,
    input  wire [ 4:0]  id_rs2,
    input  wire [ 4:0]  id_rd,
    input  wire [ 4:0]  id_alu_op,
    input  wire         id_alua_sel,
    input  wire         id_alub_sel,
    input  wire [ 1:0]  id_npc_op,
    input  wire [ 2:0]  id_ram_rop,
    input  wire [ 3:0]  id_ram_wop,
    input  wire         id_rf_we,
    input  wire [ 1:0]  id_rf_wsel,
    input  wire         id_valid_in,

    // ID/EX -> EX 输出。
    output wire [31:0]  ex_pc,
    output wire [31:0]  ex_rf_rd1,
    output wire [31:0]  ex_rf_rd2,
    output wire [31:0]  ex_ext,
    output wire [ 4:0]  ex_rs1,
    output wire [ 4:0]  ex_rs2,
    output wire [ 4:0]  ex_rd,
    output wire [ 4:0]  ex_alu_op,
    output wire         ex_alua_sel,
    output wire         ex_alub_sel,
    output wire [ 1:0]  ex_npc_op,
    output wire [ 2:0]  ex_ram_rop,
    output wire [ 3:0]  ex_ram_wop,
    output wire         ex_rf_we,
    output wire [ 1:0]  ex_rf_wsel,
    output wire         ex_valid,

    // EX -> EX/MEM 输入：ALU/地址结果、store 数据以及后续控制。
    input  wire [31:0]  ex_pc_in,
    input  wire [31:0]  ex_alu_c,
    input  wire [31:0]  ex_ext_in,
    input  wire [31:0]  ex_rf_rd2_in,
    input  wire [ 4:0]  ex_rd_in,
    input  wire [ 2:0]  ex_ram_rop_in,
    input  wire [ 3:0]  ex_ram_wop_in,
    input  wire         ex_rf_we_in,
    input  wire [ 1:0]  ex_rf_wsel_in,
    input  wire         ex_valid_in,

    // EX/MEM -> MEM 输出。
    output wire [31:0]  mem_pc,
    output wire [31:0]  mem_alu_c,
    output wire [31:0]  mem_ext,
    output wire [31:0]  mem_rf_rd2,
    output wire [ 4:0]  mem_rd,
    output wire [ 2:0]  mem_ram_rop,
    output wire [ 3:0]  mem_ram_wop,
    output wire         mem_rf_we,
    output wire [ 1:0]  mem_rf_wsel,
    output wire         mem_valid,

    // MEM -> MEM/WB 输入：load 扩展结果与其余可能的写回数据。
    input  wire [31:0]  mem_pc_in,
    input  wire [31:0]  mem_alu_c_in,
    input  wire [31:0]  mem_ext_in,
    input  wire [31:0]  mem_ram_ext,
    input  wire [ 4:0]  mem_rd_in,
    input  wire         mem_rf_we_in,
    input  wire [ 1:0]  mem_rf_wsel_in,
    input  wire         mem_valid_in,

    // MEM/WB -> WB 输出。
    output wire [31:0]  wb_pc,
    output wire [31:0]  wb_alu_c,
    output wire [31:0]  wb_ext,
    output wire [31:0]  wb_ram_ext,
    output wire [ 4:0]  wb_rd,
    output wire         wb_rf_we,
    output wire [ 1:0]  wb_rf_wsel,
    output wire         wb_valid
);

    // -------------------------------------------------------------------------
    // IF/ID：只保存 PC、原始指令和 valid
    // -------------------------------------------------------------------------
    reg [31:0]  id_pc_r;
    reg [31:0]  id_inst_r;
    reg         id_valid_r;

    assign id_pc   = id_pc_r;
    assign id_inst = id_inst_r;
    assign id_valid = id_valid_r;

    // 优先级：reset > flush > 正常推进。stall_if 时没有赋值，即保持原内容。
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            // 复位放入有效 NOP(addi x0,x0,0)，让启动流水线行为确定且无副作用。
            id_pc_r   <= 32'h0;
            id_inst_r <= 32'h00000013;
            id_valid_r <= 1'b1;
        end else if (flush) begin
            // taken 分支后，已取回但位于错误路径的 ID 指令变成 invalid bubble。
            id_pc_r   <= 32'h0;
            id_inst_r <= 32'h0;
            id_valid_r <= 1'b0;
        end else if (!stall_if) begin
            // 只有取指握手得到的 if_valid_in 才能形成真实 ID 指令。
            id_pc_r   <= if_pc;
            id_inst_r <= if_inst;
            id_valid_r <= if_valid_in;
        end
    end

    // -------------------------------------------------------------------------
    // ID/EX：保存执行所需的数据和控制
    // -------------------------------------------------------------------------
    reg [31:0]  ex_pc_r;
    reg [31:0]  ex_rf_rd1_r;
    reg [31:0]  ex_rf_rd2_r;
    reg [31:0]  ex_ext_r;
    reg [ 4:0]  ex_rs1_r;
    reg [ 4:0]  ex_rs2_r;
    reg [ 4:0]  ex_rd_r;
    reg [ 4:0]  ex_alu_op_r;
    reg         ex_alua_sel_r;
    reg         ex_alub_sel_r;
    reg [ 1:0]  ex_npc_op_r;
    reg [ 2:0]  ex_ram_rop_r;
    reg [ 3:0]  ex_ram_wop_r;
    reg         ex_rf_we_r;
    reg [ 1:0]  ex_rf_wsel_r;
    reg         ex_valid_r;

    assign ex_pc       = ex_pc_r;
    assign ex_rf_rd1   = ex_rf_rd1_r;
    assign ex_rf_rd2   = ex_rf_rd2_r;
    assign ex_ext      = ex_ext_r;
    assign ex_rs1      = ex_rs1_r;
    assign ex_rs2      = ex_rs2_r;
    assign ex_rd       = ex_rd_r;
    assign ex_alu_op   = ex_alu_op_r;
    assign ex_alua_sel = ex_alua_sel_r;
    assign ex_alub_sel = ex_alub_sel_r;
    assign ex_npc_op   = ex_npc_op_r;
    assign ex_ram_rop  = ex_ram_rop_r;
    assign ex_ram_wop  = ex_ram_wop_r;
    assign ex_rf_we    = ex_rf_we_r;
    assign ex_rf_wsel  = ex_rf_wsel_r;
    assign ex_valid    = ex_valid_r;

    // 优先级同样是 reset > flush > 正常推进。stall_id 时整个 ID/EX 保持，
    // 用于 AXI/M 扩展全局冻结；load-use 的 bubble 则由 id_valid_in=0 注入。
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            ex_pc_r       <= 32'h0;
            ex_rf_rd1_r   <= 32'h0;
            ex_rf_rd2_r   <= 32'h0;
            ex_ext_r      <= 32'h0;
            ex_rs1_r      <= 5'h0;
            ex_rs2_r      <= 5'h0;
            ex_rd_r       <= 5'h0;
            ex_alu_op_r   <= 5'h0;
            ex_alua_sel_r <= 1'b0;
            ex_alub_sel_r <= 1'b0;
            ex_npc_op_r   <= 2'h0;
            ex_ram_rop_r  <= 3'h0;
            ex_ram_wop_r  <= 4'h0;
            ex_rf_we_r    <= 1'b0;
            ex_rf_wsel_r  <= 2'h0;
            ex_valid_r    <= 1'b0;
        end else if (flush) begin
            // 分支在 EX 才解析，此时 ID 中的年轻指令也属于错误路径，全部控制清零。
            ex_pc_r       <= 32'h0;
            ex_rf_rd1_r   <= 32'h0;
            ex_rf_rd2_r   <= 32'h0;
            ex_ext_r      <= 32'h0;
            ex_rs1_r      <= 5'h0;
            ex_rs2_r      <= 5'h0;
            ex_rd_r       <= 5'h0;
            ex_alu_op_r   <= 5'h0;
            ex_alua_sel_r <= 1'b0;
            ex_alub_sel_r <= 1'b0;
            ex_npc_op_r   <= 2'h0;
            ex_ram_rop_r  <= 3'h0;
            ex_ram_wop_r  <= 4'h0;
            ex_rf_we_r    <= 1'b0;
            ex_rf_wsel_r  <= 2'h0;
            ex_valid_r    <= 1'b0;
        end else if (!stall_id) begin
            // 同一个上升沿把 ID 数据和与它对应的控制一并锁存，避免跨指令串线。
            ex_pc_r       <= id_pc_in;
            ex_rf_rd1_r   <= id_rf_rd1;
            ex_rf_rd2_r   <= id_rf_rd2;
            ex_ext_r      <= id_ext;
            ex_rs1_r      <= id_rs1;
            ex_rs2_r      <= id_rs2;
            ex_rd_r       <= id_rd;
            ex_alu_op_r   <= id_alu_op;
            ex_alua_sel_r <= id_alua_sel;
            ex_alub_sel_r <= id_alub_sel;
            ex_npc_op_r   <= id_npc_op;
            ex_ram_rop_r  <= id_ram_rop;
            ex_ram_wop_r  <= id_ram_wop;
            ex_rf_we_r    <= id_rf_we;
            ex_rf_wsel_r  <= id_rf_wsel;
            ex_valid_r    <= id_valid_in;
        end
    end

    // -------------------------------------------------------------------------
    // EX/MEM：保存 ALU 结果、store 数据和访存/写回控制
    // -------------------------------------------------------------------------
    reg [31:0]  mem_pc_r;
    reg [31:0]  mem_alu_c_r;
    reg [31:0]  mem_ext_r;
    reg [31:0]  mem_rf_rd2_r;
    reg [ 4:0]  mem_rd_r;
    reg [ 2:0]  mem_ram_rop_r;
    reg [ 3:0]  mem_ram_wop_r;
    reg         mem_rf_we_r;
    reg [ 1:0]  mem_rf_wsel_r;
    reg         mem_valid_r;

    assign mem_pc       = mem_pc_r;
    assign mem_alu_c    = mem_alu_c_r;
    assign mem_ext      = mem_ext_r;
    assign mem_rf_rd2   = mem_rf_rd2_r;
    assign mem_rd       = mem_rd_r;
    assign mem_ram_rop  = mem_ram_rop_r;
    assign mem_ram_wop  = mem_ram_wop_r;
    assign mem_rf_we    = mem_rf_we_r;
    assign mem_rf_wsel  = mem_rf_wsel_r;
    assign mem_valid    = mem_valid_r;

    // stall_ex 主要由 M 扩展 busy 或内存等待引起，保持当前 EX/MEM 所属指令。
    // 分支指令已经在 EX 解析，不需要 flush 老于分支的 MEM/WB 指令。
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mem_pc_r       <= 32'h0;
            mem_alu_c_r    <= 32'h0;
            mem_ext_r      <= 32'h0;
            mem_rf_rd2_r   <= 32'h0;
            mem_rd_r       <= 5'h0;
            mem_ram_rop_r  <= 3'h0;
            mem_ram_wop_r  <= 4'h0;
            mem_rf_we_r    <= 1'b0;
            mem_rf_wsel_r  <= 2'h0;
            mem_valid_r    <= 1'b0;
        end else if (!stall_ex) begin
            // ex_valid_in=0 时数据可以变化，但后续不得发请求或写回。
            mem_pc_r       <= ex_pc_in;
            mem_alu_c_r    <= ex_alu_c;
            mem_ext_r      <= ex_ext_in;
            mem_rf_rd2_r   <= ex_rf_rd2_in;
            mem_rd_r       <= ex_rd_in;
            mem_ram_rop_r  <= ex_ram_rop_in;
            mem_ram_wop_r  <= ex_ram_wop_in;
            mem_rf_we_r    <= ex_rf_we_in;
            mem_rf_wsel_r  <= ex_rf_wsel_in;
            mem_valid_r    <= ex_valid_in;
        end
    end

    // -------------------------------------------------------------------------
    // MEM/WB：保存最终写回候选数据
    // -------------------------------------------------------------------------
    reg [31:0]  wb_pc_r;
    reg [31:0]  wb_alu_c_r;
    reg [31:0]  wb_ext_r;
    reg [31:0]  wb_ram_ext_r;
    reg [ 4:0]  wb_rd_r;
    reg         wb_rf_we_r;
    reg [ 1:0]  wb_rf_wsel_r;
    reg         wb_valid_r;

    assign wb_pc      = wb_pc_r;
    assign wb_alu_c   = wb_alu_c_r;
    assign wb_ext     = wb_ext_r;
    assign wb_ram_ext = wb_ram_ext_r;
    assign wb_rd      = wb_rd_r;
    assign wb_rf_we   = wb_rf_we_r;
    assign wb_rf_wsel = wb_rf_wsel_r;
    assign wb_valid   = wb_valid_r;

    // load/store 等待 AXI 响应时 stall_mem=1，防止同一指令重复进入 WB。
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            wb_pc_r      <= 32'h0;
            wb_alu_c_r   <= 32'h0;
            wb_ext_r     <= 32'h0;
            wb_ram_ext_r <= 32'h0;
            wb_rd_r      <= 5'h0;
            wb_rf_we_r   <= 1'b0;
            wb_rf_wsel_r <= 2'h0;
            wb_valid_r   <= 1'b0;
        end else if (!stall_mem) begin
            // 一次推进对应一次按序提交机会；wb_valid 最终门控寄存器写回。
            wb_pc_r      <= mem_pc_in;
            wb_alu_c_r   <= mem_alu_c_in;
            wb_ext_r     <= mem_ext_in;
            wb_ram_ext_r <= mem_ram_ext;
            wb_rd_r      <= mem_rd_in;
            wb_rf_we_r   <= mem_rf_we_in;
            wb_rf_wsel_r <= mem_rf_wsel_in;
            wb_valid_r   <= mem_valid_in;
        end
    end

endmodule
