`timescale 1ns / 1ps

module pipeline_regs (
    input  wire         clk,
    input  wire         rst,

    input  wire         stall_if,
    input  wire         stall_id,
    input  wire         stall_ex,
    input  wire         stall_mem,
    input  wire         flush,

    input  wire [31:0]  if_pc,
    input  wire [31:0]  if_inst,
    input  wire         if_valid_in,

    output wire [31:0]  id_pc,
    output wire [31:0]  id_inst,
    output wire         id_valid,

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

    input  wire [31:0]  mem_pc_in,
    input  wire [31:0]  mem_alu_c_in,
    input  wire [31:0]  mem_ext_in,
    input  wire [31:0]  mem_ram_ext,
    input  wire [ 4:0]  mem_rd_in,
    input  wire         mem_rf_we_in,
    input  wire [ 1:0]  mem_rf_wsel_in,
    input  wire         mem_valid_in,

    output wire [31:0]  wb_pc,
    output wire [31:0]  wb_alu_c,
    output wire [31:0]  wb_ext,
    output wire [31:0]  wb_ram_ext,
    output wire [ 4:0]  wb_rd,
    output wire         wb_rf_we,
    output wire [ 1:0]  wb_rf_wsel,
    output wire         wb_valid
);

    reg [31:0]  id_pc_r;
    reg [31:0]  id_inst_r;
    reg         id_valid_r;

    assign id_pc   = id_pc_r;
    assign id_inst = id_inst_r;
    assign id_valid = id_valid_r;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            id_pc_r   <= 32'h0;
            id_inst_r <= 32'h00000013;
            id_valid_r <= 1'b1;
        end else if (flush) begin
            id_pc_r   <= 32'h0;
            id_inst_r <= 32'h0;
            id_valid_r <= 1'b0;
        end else if (!stall_if) begin
            id_pc_r   <= if_pc;
            id_inst_r <= if_inst;
            id_valid_r <= if_valid_in;
        end
    end

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
