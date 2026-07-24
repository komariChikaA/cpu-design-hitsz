`timescale 1ns / 1ps

`include "defines.vh"

module cpu_core(
    input  wire         cpu_rst,
    input  wire         cpu_clk,

    output wire         ifetch_req   /* verilator public */ ,
    output wire [31:0]  ifetch_addr  /* verilator public */ ,
    input  wire         ifetch_valid /* verilator public */ ,
    input  wire [31:0]  ifetch_inst,

    output wire [ 3:0]  daccess_ren,
    output wire [31:0]  daccess_addr,
    input  wire         daccess_rvalid,
    input  wire [31:0]  daccess_rdata,
    output wire [ 3:0]  daccess_wen,
    output wire [31:0]  daccess_wdata,
    input  wire         daccess_wresp
);

    reg [31:0] pc;

    always @(posedge cpu_clk or posedge cpu_rst) begin
        if (cpu_rst)
            pc <= 32'h0;
        else if (ex_bj_f)
            pc <= ex_bj_target;
        else if (ifetch_valid && !stall_if)
            pc <= pc + 32'h4;
    end

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

    wire [4:0] id_rs1 = id_inst[19:15];
    wire [4:0] id_rs2 = id_inst[24:20];

    wire [6:0] id_opcode = id_inst[6:0];
    wire id_is_r_type = (id_opcode == 7'b0110011);
    wire id_is_i_type = (id_opcode == 7'b0010011 || id_opcode == 7'b0000011 || id_opcode == 7'b1100111);
    wire id_is_s_type = (id_opcode == 7'b0100011);
    wire id_is_b_type = (id_opcode == 7'b1100011);
    wire id_rf1 = id_is_r_type | id_is_i_type | id_is_s_type | id_is_b_type;
    wire id_rf2 = id_is_r_type | id_is_s_type | id_is_b_type;

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

    wire [31:0] rf_rd1;
    wire [31:0] rf_rd2;

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

    wire wb_fwd_rs1 = wb_rf_we && wb_valid && (wb_rd != 5'h0) && (wb_rd == id_rs1)
                      && id_rf1 && id_valid;
    wire wb_fwd_rs2 = wb_rf_we && wb_valid && (wb_rd != 5'h0) && (wb_rd == id_rs2)
                      && id_rf2 && id_valid;
    wire [31:0] rf_rd1_fwd = wb_fwd_rs1 ? rf_wD : rf_rd1;
    wire [31:0] rf_rd2_fwd = wb_fwd_rs2 ? rf_wD : rf_rd2;

    wire [31:0] ext;

    SEXT U_SEXT (
        .op         (sext_op),
        .imm        (id_inst[31:7]),
        .ext        (ext)
    );

    wire ex_is_load   = (ex_ram_rop != `RAM_EXT_N) && ex_valid;
    wire id_uses_rs1  = id_rf1 && id_valid;
    wire id_uses_rs2  = id_rf2 && id_valid;
    wire load_use_hazard = ex_is_load && ex_rf_we && (ex_rd != 5'h0) &&
                           ((id_uses_rs1 && (ex_rd == id_rs1)) ||
                            (id_uses_rs2 && (ex_rd == id_rs2)));

    wire id_is_ld_st = ((ram_rop != `RAM_EXT_N) || (ram_wop != `RAM_WE_N)) && id_valid;
    wire ex_is_ld_st = ((ex_ram_rop != `RAM_EXT_N) || (ex_ram_wop != `RAM_WE_N)) && ex_valid;

    reg ld_st_suspend;
    wire ld_st_done = daccess_rvalid || daccess_wresp;
    always @(posedge cpu_clk or posedge cpu_rst) begin
        if (cpu_rst)
            ld_st_suspend <= 1'b0;
        else if (ld_st_done)
            ld_st_suspend <= 1'b0;
        else if (ex_is_ld_st && !ld_st_done)
            ld_st_suspend <= 1'b1;
    end

    wire id_is_mul_div = (is_mul || is_div) && id_valid;
    wire ex_is_mul_div = ((ex_alu_op == `ALU_MUL)  || (ex_alu_op == `ALU_MULH) ||
                          (ex_alu_op == `ALU_MULHU) || (ex_alu_op == `ALU_DIV)  ||
                          (ex_alu_op == `ALU_DIVU)  || (ex_alu_op == `ALU_REM)  ||
                          (ex_alu_op == `ALU_REMU))  && ex_valid;

    reg mul_div_suspend;
    reg ex_mul_div_busy_d;
    always @(posedge cpu_clk) ex_mul_div_busy_d <= ex_mul_div_busy;
    wire mul_div_done = ex_mul_div_busy_d && !ex_mul_div_busy;

    always @(posedge cpu_clk or posedge cpu_rst) begin
        if (cpu_rst)
            mul_div_suspend <= 1'b0;
        else if (id_is_mul_div && ex_mul_div_busy)
            mul_div_suspend <= 1'b1;
        else if (mul_div_done)
            mul_div_suspend <= 1'b0;
    end

    wire ex_is_branch = (ex_npc_op == `NPC_BRA) && ex_valid;
    wire ex_is_jal    = (ex_npc_op == `NPC_JMP) && ex_valid;
    wire ex_is_jalr   = (ex_npc_op == `NPC_JALR) && ex_valid;

    wire [31:0] ex_bj_target;
    assign ex_bj_target = ex_is_jalr ? {alu_c[31:1], 1'b0} : (ex_pc + ex_ext);

    wire ex_bj_target_in_id = id_valid && (id_pc == ex_bj_target);
    wire ex_bj_f;
    assign ex_bj_f = ((ex_is_branch && br) || ex_is_jal || ex_is_jalr)
                     && !ex_bj_target_in_id;

    wire stall_if, stall_id, stall_ex, stall_mem;

    wire effective_freeze = (ld_st_suspend || mul_div_suspend || ex_mul_div_busy)
                            && !ld_st_done;

    wire load_entering_id = id_is_ld_st   && !ex_is_ld_st;
    wire mul_entering_id  = id_is_mul_div && !ex_is_mul_div;

    assign stall_if  = load_use_hazard || load_entering_id || mul_entering_id || effective_freeze;
    assign stall_id  = effective_freeze;
    assign stall_ex  = effective_freeze;
    assign stall_mem = (ld_st_suspend) && !ld_st_done;

    wire load_duplicate = id_is_ld_st   && ex_is_ld_st;
    wire mul_duplicate  = id_is_mul_div && ex_is_mul_div;
    wire id_valid_for_ex;
    assign id_valid_for_ex = id_valid && !load_use_hazard && !load_duplicate && !mul_duplicate;

    wire flush;
    assign flush = ex_bj_f;

    wire [1:0] forward_a_sel;
    wire [1:0] forward_b_sel;

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

    wire [31:0] mem_wb_data;
    assign mem_wb_data = (mem_rf_wsel == `WB_EXT) ? mem_ext :
                         (mem_rf_wsel == `WB_PC4) ? (mem_pc + 32'h4) :
                                                    mem_alu_c;

    wire [31:0] fwd_a;
    wire [31:0] fwd_b;

    assign fwd_a = ex_mul_div_busy ? ex_rf_rd1 :
                   (forward_a_sel == 2'b01) ? mem_wb_data :
                   (forward_a_sel == 2'b10) ? rf_wD       : ex_rf_rd1;

    assign fwd_b = ex_mul_div_busy ? ex_rf_rd2 :
                   (forward_b_sel == 2'b01) ? mem_wb_data :
                   (forward_b_sel == 2'b10) ? rf_wD       : ex_rf_rd2;

    wire [31:0] fwd_store_data;
    assign fwd_store_data = ex_mul_div_busy ? ex_rf_rd2 :
                            (forward_b_sel == 2'b01) ? mem_wb_data :
                            (forward_b_sel == 2'b10) ? rf_wD       : ex_rf_rd2;

    wire [31:0] alu_a;
    wire [31:0] alu_b;
    wire [31:0] alu_c;
    wire        br;
    wire        ex_mul_div_busy;

    assign alu_a = ex_alua_sel ? ex_pc : fwd_a;
    assign alu_b = ex_alub_sel ? ex_ext : fwd_b;

    ALU U_ALU (
        .rst        (cpu_rst),
        .clk        (cpu_clk),
        .op         (ex_alu_op),
        .a          (alu_a),
        .b          (alu_b),
        .br         (br),
        .c          (alu_c),
        .busy       (ex_mul_div_busy)
    );

    wire [ 3:0] da_ren;
    wire [31:0] da_addr;
    wire [ 3:0] da_wen;
    wire [31:0] da_wdata;
    wire [31:0] ram_ext;

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

    MEXT U_MEM_EXT (
        .op             (mem_ram_rop),
        .din            (daccess_rdata),
        .byte_offs      (mem_alu_c[1:0]),
        .ext            (ram_ext)
    );

    wire mem_op_active = mem_valid && ((mem_ram_rop != `RAM_EXT_N) || (mem_ram_wop != `RAM_WE_N));

    assign daccess_ren   = mem_op_active ? da_ren   : 4'h0;
    assign daccess_addr  = da_addr;
    assign daccess_wen   = mem_op_active ? da_wen   : 4'h0;
    assign daccess_wdata = da_wdata;

    reg [31:0] rf_wD;

    always @(*) begin
        case (wb_rf_wsel)
            `WB_ALU : rf_wD = wb_alu_c;
            `WB_RAM : rf_wD = wb_ram_ext;
            `WB_PC4 : rf_wD = wb_pc + 32'h4;
            `WB_EXT : rf_wD = wb_ext;
            default : rf_wD = wb_alu_c;
        endcase
    end

    wire pause_ifetch = load_use_hazard ||
                        load_entering_id ||
                        ((ld_st_suspend || ex_is_ld_st) && !ld_st_done) ||
                        mul_entering_id ||
                        mul_div_suspend;

    wire resume_ifetch = ld_st_done || mul_div_done;

    assign ifetch_req  = resume_ifetch | !pause_ifetch;

    assign ifetch_addr = ex_bj_f ? ex_bj_target : pc;

`ifdef RUN_TRACE
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
    // AXI stores can hold daccess_wen while the transaction is in flight.
    // Report the architectural store exactly once, when its write response
    // completes, so Trace does not mistake wait cycles for repeated stores.
    assign debug_mem_we    = daccess_wresp ? daccess_wen : 4'h0;
    assign debug_mem_waddr = daccess_addr;
    assign debug_mem_wdata = daccess_wdata;
`endif

endmodule
