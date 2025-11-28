`include "defs.v"

module issue
//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
#(
    parameter SUPPORT_MULDIV   = 1,
    parameter SUPPORT_DUAL_ISSUE = 1,
    parameter SUPPORT_LOAD_BYPASS = 1,
    parameter SUPPORT_MUL_BYPASS = 1,
    parameter SUPPORT_REGFILE_XILINX = 0
)
//-----------------------------------------------------------------
// Ports
//-----------------------------------------------------------------
(
    // Inputs
    input           clk_i,
    input           rst_i,
    // Fetch 0
    input           fetch0_valid_i,
    input  [ 31:0]  fetch0_instr_i,
    input  [ 31:0]  fetch0_pc_i,
    input           fetch0_fault_fetch_i,
    input           fetch0_fault_page_i,
    input           fetch0_instr_exec_i,
    input           fetch0_instr_lsu_i,
    input           fetch0_instr_branch_i,
    input           fetch0_instr_mul_i,
    input           fetch0_instr_div_i,
    input           fetch0_instr_csr_i,
    input           fetch0_instr_rd_valid_i,
    input           fetch0_instr_invalid_i,
    // Fetch 1
    input           fetch1_valid_i,
    input  [ 31:0]  fetch1_instr_i,
    input  [ 31:0]  fetch1_pc_i,
    input           fetch1_fault_fetch_i,
    input           fetch1_fault_page_i,
    input           fetch1_instr_exec_i,
    input           fetch1_instr_lsu_i,
    input           fetch1_instr_branch_i,
    input           fetch1_instr_mul_i,
    input           fetch1_instr_div_i,
    input           fetch1_instr_csr_i,
    input           fetch1_instr_rd_valid_i,
    input           fetch1_instr_invalid_i,
    // Fetch 2
    input           fetch2_valid_i,
    input  [ 31:0]  fetch2_instr_i,
    input  [ 31:0]  fetch2_pc_i,
    input           fetch2_fault_fetch_i,
    input           fetch2_fault_page_i,
    input           fetch2_instr_exec_i,
    input           fetch2_instr_lsu_i,
    input           fetch2_instr_branch_i,
    input           fetch2_instr_mul_i,
    input           fetch2_instr_div_i,
    input           fetch2_instr_csr_i,
    input           fetch2_instr_rd_valid_i,
    input           fetch2_instr_invalid_i,
    // Fetch 3
    input           fetch3_valid_i,
    input  [ 31:0]  fetch3_instr_i,
    input  [ 31:0]  fetch3_pc_i,
    input           fetch3_fault_fetch_i,
    input           fetch3_fault_page_i,
    input           fetch3_instr_exec_i,
    input           fetch3_instr_lsu_i,
    input           fetch3_instr_branch_i,
    input           fetch3_instr_mul_i,
    input           fetch3_instr_div_i,
    input           fetch3_instr_csr_i,
    input           fetch3_instr_rd_valid_i,
    input           fetch3_instr_invalid_i,

    // Branch Exec Inputs
    input           branch_exec0_request_i,
    input           branch_exec0_is_taken_i,
    input           branch_exec0_is_not_taken_i,
    input  [ 31:0]  branch_exec0_source_i,
    input           branch_exec0_is_call_i,
    input           branch_exec0_is_ret_i,
    input           branch_exec0_is_jmp_i,
    input  [ 31:0]  branch_exec0_pc_i,
    input           branch_d_exec0_request_i,
    input  [ 31:0]  branch_d_exec0_pc_i,
    input  [  1:0]  branch_d_exec0_priv_i,
    
    input           branch_exec1_request_i,
    input           branch_exec1_is_taken_i,
    input           branch_exec1_is_not_taken_i,
    input  [ 31:0]  branch_exec1_source_i,
    input           branch_exec1_is_call_i,
    input           branch_exec1_is_ret_i,
    input           branch_exec1_is_jmp_i,
    input  [ 31:0]  branch_exec1_pc_i,
    input           branch_d_exec1_request_i,
    input  [ 31:0]  branch_d_exec1_pc_i,
    input  [  1:0]  branch_d_exec1_priv_i,

    input           branch_exec2_request_i,
    input           branch_exec2_is_taken_i,
    input           branch_exec2_is_not_taken_i,
    input  [ 31:0]  branch_exec2_source_i,
    input           branch_exec2_is_call_i,
    input           branch_exec2_is_ret_i,
    input           branch_exec2_is_jmp_i,
    input  [ 31:0]  branch_exec2_pc_i,
    input           branch_d_exec2_request_i,
    input  [ 31:0]  branch_d_exec2_pc_i,
    input  [  1:0]  branch_d_exec2_priv_i,

    input           branch_exec3_request_i,
    input           branch_exec3_is_taken_i,
    input           branch_exec3_is_not_taken_i,
    input  [ 31:0]  branch_exec3_source_i,
    input           branch_exec3_is_call_i,
    input           branch_exec3_is_ret_i,
    input           branch_exec3_is_jmp_i,
    input  [ 31:0]  branch_exec3_pc_i,
    input           branch_d_exec3_request_i,
    input  [ 31:0]  branch_d_exec3_pc_i,
    input  [  1:0]  branch_d_exec3_priv_i,

    input           branch_csr_request_i,
    input  [ 31:0]  branch_csr_pc_i,
    input  [  1:0]  branch_csr_priv_i,
    
    // Writeback Inputs
    input  [ 31:0]  writeback_exec0_value_i,
    input  [ 31:0]  writeback_exec1_value_i,
    input  [ 31:0]  writeback_exec2_value_i,
    input  [ 31:0]  writeback_exec3_value_i,
    input           writeback_mem_valid_i,
    input  [ 31:0]  writeback_mem_value_i,
    input  [  5:0]  writeback_mem_exception_i,
    input  [ 31:0]  writeback_mul_value_i,
    input           writeback_div_valid_i,
    input  [ 31:0]  writeback_div_value_i,
    input  [ 31:0]  csr_result_e1_value_i,
    input           csr_result_e1_write_i,
    input  [ 31:0]  csr_result_e1_wdata_i,
    input  [  5:0]  csr_result_e1_exception_i,
    input           lsu_stall_i,
    input           take_interrupt_i,

    // Outputs
    output          fetch0_accept_o,
    output          fetch1_accept_o,
    output          fetch2_accept_o,
    output          fetch3_accept_o,
    output          branch_request_o,
    output [ 31:0]  branch_pc_o,
    output [  1:0]  branch_priv_o,
    output          branch_info_request_o,
    output          branch_info_is_taken_o,
    output          branch_info_is_not_taken_o,
    output [ 31:0]  branch_info_source_o,
    output          branch_info_is_call_o,
    output          branch_info_is_ret_o,
    output          branch_info_is_jmp_o,
    output [ 31:0]  branch_info_pc_o,
    
    // Exec Valids
    output          exec0_opcode_valid_o,
    output          exec1_opcode_valid_o,
    output          exec2_opcode_valid_o,
    output          exec3_opcode_valid_o,
    output          lsu_opcode_valid_o,
    output          csr_opcode_valid_o,
    output          mul_opcode_valid_o,
    output          div_opcode_valid_o,

    // Opcode 0
    output [ 31:0]  opcode0_opcode_o,
    output [ 31:0]  opcode0_pc_o,
    output          opcode0_invalid_o,
    output [  4:0]  opcode0_rd_idx_o,
    output [  4:0]  opcode0_ra_idx_o,
    output [  4:0]  opcode0_rb_idx_o,
    output [ 31:0]  opcode0_ra_operand_o,
    output [ 31:0]  opcode0_rb_operand_o,
    // Opcode 1
    output [ 31:0]  opcode1_opcode_o,
    output [ 31:0]  opcode1_pc_o,
    output          opcode1_invalid_o,
    output [  4:0]  opcode1_rd_idx_o,
    output [  4:0]  opcode1_ra_idx_o,
    output [  4:0]  opcode1_rb_idx_o,
    output [ 31:0]  opcode1_ra_operand_o,
    output [ 31:0]  opcode1_rb_operand_o,
    // Opcode 2
    output [ 31:0]  opcode2_opcode_o,
    output [ 31:0]  opcode2_pc_o,
    output          opcode2_invalid_o,
    output [  4:0]  opcode2_rd_idx_o,
    output [  4:0]  opcode2_ra_idx_o,
    output [  4:0]  opcode2_rb_idx_o,
    output [ 31:0]  opcode2_ra_operand_o,
    output [ 31:0]  opcode2_rb_operand_o,
    // Opcode 3
    output [ 31:0]  opcode3_opcode_o,
    output [ 31:0]  opcode3_pc_o,
    output          opcode3_invalid_o,
    output [  4:0]  opcode3_rd_idx_o,
    output [  4:0]  opcode3_ra_idx_o,
    output [  4:0]  opcode3_rb_idx_o,
    output [ 31:0]  opcode3_ra_operand_o,
    output [ 31:0]  opcode3_rb_operand_o,

    // LSU / MUL / CSR Special Ops (Muxed)
    output [ 31:0]  lsu_opcode_opcode_o,
    output [ 31:0]  lsu_opcode_pc_o,
    output          lsu_opcode_invalid_o,
    output [  4:0]  lsu_opcode_rd_idx_o,
    output [  4:0]  lsu_opcode_ra_idx_o,
    output [  4:0]  lsu_opcode_rb_idx_o,
    output [ 31:0]  lsu_opcode_ra_operand_o,
    output [ 31:0]  lsu_opcode_rb_operand_o,
    output [ 31:0]  mul_opcode_opcode_o,
    output [ 31:0]  mul_opcode_pc_o,
    output          mul_opcode_invalid_o,
    output [  4:0]  mul_opcode_rd_idx_o,
    output [  4:0]  mul_opcode_ra_idx_o,
    output [  4:0]  mul_opcode_rb_idx_o,
    output [ 31:0]  mul_opcode_ra_operand_o,
    output [ 31:0]  mul_opcode_rb_operand_o,
    output [ 31:0]  csr_opcode_opcode_o,
    output [ 31:0]  csr_opcode_pc_o,
    output          csr_opcode_invalid_o,
    output [  4:0]  csr_opcode_rd_idx_o,
    output [  4:0]  csr_opcode_ra_idx_o,
    output [  4:0]  csr_opcode_rb_idx_o,
    output [ 31:0]  csr_opcode_ra_operand_o,
    output [ 31:0]  csr_opcode_rb_operand_o,
    output          csr_writeback_write_o,
    output [ 11:0]  csr_writeback_waddr_o,
    output [ 31:0]  csr_writeback_wdata_o,
    output [  5:0]  csr_writeback_exception_o,
    output [ 31:0]  csr_writeback_exception_pc_o,
    output [ 31:0]  csr_writeback_exception_addr_o,
    output          exec0_hold_o,
    output          exec1_hold_o,
    output          exec2_hold_o,
    output          exec3_hold_o,
    output          mul_hold_o,
    output          interrupt_inhibit_o
);
wire enable_dual_issue_w = SUPPORT_DUAL_ISSUE;
wire enable_muldiv_w     = SUPPORT_MULDIV;
wire enable_mul_bypass_w = SUPPORT_MUL_BYPASS;

wire stall_w;
wire squash_w;
//-------------------------------------------------------------
// PC
//-------------------------------------------------------------
wire        single_issue_w;
wire        dual_issue_w;
wire        triple_issue_w;
wire        quad_issue_w;

reg  [31:0] pc_x_q;
reg   [1:0] priv_x_q;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    pc_x_q <= 32'b0;
else if (branch_csr_request_i)
    pc_x_q <= branch_csr_pc_i;
else if (branch_d_exec3_request_i)
    pc_x_q <= branch_d_exec3_pc_i;
else if (branch_d_exec2_request_i)
    pc_x_q <= branch_d_exec2_pc_i;
else if (branch_d_exec1_request_i)
    pc_x_q <= branch_d_exec1_pc_i;
else if (branch_d_exec0_request_i)
    pc_x_q <= branch_d_exec0_pc_i;
else if (quad_issue_w)
    pc_x_q <= pc_x_q + 32'd16;
else if (triple_issue_w)
    pc_x_q <= pc_x_q + 32'd12;
else if (dual_issue_w)
    pc_x_q <= pc_x_q + 32'd8;
else if (single_issue_w)
    pc_x_q <= pc_x_q + 32'd4;

always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    priv_x_q <= `PRIV_MACHINE;
else if (branch_csr_request_i)
    priv_x_q <= branch_csr_priv_i;

//-------------------------------------------------------------
// Issue Select
//-------------------------------------------------------------
reg mispredicted_r;
reg slot0_valid_r;
reg slot1_valid_r;
reg slot2_valid_r;
reg slot3_valid_r;

always @ *
begin
    mispredicted_r = 1'b0;
    slot0_valid_r  = 1'b0;
    slot1_valid_r  = 1'b0;
    slot2_valid_r  = 1'b0;
    slot3_valid_r  = 1'b0;

    // Flush due to CSR branch
    if (branch_csr_request_i || squash_w)
    begin
        slot0_valid_r  = 1'b0;
        slot1_valid_r  = 1'b0;
        slot2_valid_r  = 1'b0;
        slot3_valid_r  = 1'b0;
    end
    // Slot 0 Check
    else if (fetch0_valid_i && {fetch0_pc_i[31:2], 2'b0} == {pc_x_q[31:2], 2'b0})
        slot0_valid_r  = 1'b1;
    // Slot 1 Check
    else if (fetch1_valid_i && {fetch1_pc_i[31:2], 2'b0} == {pc_x_q[31:2], 2'b0})
        slot1_valid_r  = 1'b1;
    // Slot 2 Check
    else if (fetch2_valid_i && {fetch2_pc_i[31:2], 2'b0} == {pc_x_q[31:2], 2'b0})
        slot2_valid_r  = 1'b1;
    // Slot 3 Check
    else if (fetch3_valid_i && {fetch3_pc_i[31:2], 2'b0} == {pc_x_q[31:2], 2'b0})
        slot3_valid_r  = 1'b1;
    // Neither word is the expected PC - must be a branch misprediction
    else if (fetch0_valid_i || fetch1_valid_i || fetch2_valid_i || fetch3_valid_i)
        mispredicted_r = 1'b1;
end

// Branch request (CSR branch - ecall, xret, or branch misprediction)
// Note: Correctly predicted branches are silent
assign branch_request_o          = branch_csr_request_i | mispredicted_r;
assign branch_pc_o               = branch_csr_request_i ? branch_csr_pc_i : pc_x_q;
assign branch_priv_o             = branch_csr_request_i ? branch_csr_priv_i : priv_x_q;

//-------------------------------------------------------------
// Instruction Decoder
//-------------------------------------------------------------
reg        opcode_a_valid_r;
reg        opcode_b_valid_r;
reg        opcode_c_valid_r;
reg        opcode_d_valid_r;
reg [1:0]  opcode_a_fault_r;
reg [1:0]  opcode_b_fault_r;
reg [1:0]  opcode_c_fault_r;
reg [1:0]  opcode_d_fault_r;
reg [31:0] opcode_a_r;
reg [31:0] opcode_b_r;
reg [31:0] opcode_c_r;
reg [31:0] opcode_d_r;
reg [31:0] opcode_a_pc_r;
reg [31:0] opcode_b_pc_r;
reg [31:0] opcode_c_pc_r;
reg [31:0] opcode_d_pc_r;

always @ *
begin
    opcode_a_r       = 32'b0;
    opcode_b_r       = 32'b0;
    opcode_c_r       = 32'b0;
    opcode_d_r       = 32'b0;
    opcode_a_valid_r = 1'b0;
    opcode_b_valid_r = 1'b0;
    opcode_c_valid_r = 1'b0;
    opcode_d_valid_r = 1'b0;
    opcode_a_fault_r = 2'b0;
    opcode_b_fault_r = 2'b0;
    opcode_c_fault_r = 2'b0;
    opcode_d_fault_r = 2'b0;
    opcode_a_pc_r    = 32'b0;
    opcode_b_pc_r    = 32'b0;
    opcode_c_pc_r    = 32'b0;
    opcode_d_pc_r    = 32'b0;

    // Word 0 (and possibly others) are valid instructions
    if (slot0_valid_r)
    begin
        opcode_a_valid_r = 1'b1;
        opcode_b_valid_r = fetch1_valid_i;
        opcode_c_valid_r = fetch2_valid_i;
        opcode_d_valid_r = fetch3_valid_i;

        opcode_a_r       = fetch0_instr_i;
        opcode_a_pc_r    = fetch0_pc_i;
        opcode_a_fault_r = {fetch0_fault_page_i, fetch0_fault_fetch_i};

        opcode_b_r       = fetch1_instr_i;
        opcode_b_pc_r    = fetch1_pc_i;
        opcode_b_fault_r = {fetch1_fault_page_i, fetch1_fault_fetch_i};

        opcode_c_r       = fetch2_instr_i;
        opcode_c_pc_r    = fetch2_pc_i;
        opcode_c_fault_r = {fetch2_fault_page_i, fetch2_fault_fetch_i};

        opcode_d_r       = fetch3_instr_i;
        opcode_d_pc_r    = fetch3_pc_i;
        opcode_d_fault_r = {fetch3_fault_page_i, fetch3_fault_fetch_i};
    end
    // Word 1 valid - mux to first issue slot
    else if (slot1_valid_r)
    begin
        opcode_a_valid_r = 1'b1;
        opcode_b_valid_r = fetch2_valid_i;
        opcode_c_valid_r = fetch3_valid_i;
        opcode_d_valid_r = 1'b0;

        opcode_a_r       = fetch1_instr_i;
        opcode_a_pc_r    = fetch1_pc_i;
        opcode_a_fault_r = {fetch1_fault_page_i, fetch1_fault_fetch_i};

        opcode_b_r       = fetch2_instr_i;
        opcode_b_pc_r    = fetch2_pc_i;
        opcode_b_fault_r = {fetch2_fault_page_i, fetch2_fault_fetch_i};

        opcode_c_r       = fetch3_instr_i;
        opcode_c_pc_r    = fetch3_pc_i;
        opcode_c_fault_r = {fetch3_fault_page_i, fetch3_fault_fetch_i};
    end
    // Slot 2 valid - mux to first
    else if (slot2_valid_r)
    begin
        opcode_a_valid_r = 1'b1;
        opcode_b_valid_r = fetch3_valid_i;
        opcode_c_valid_r = 1'b0;
        opcode_d_valid_r = 1'b0;

        opcode_a_r       = fetch2_instr_i;
        opcode_a_pc_r    = fetch2_pc_i;
        opcode_a_fault_r = {fetch2_fault_page_i, fetch2_fault_fetch_i};

        opcode_b_r       = fetch3_instr_i;
        opcode_b_pc_r    = fetch3_pc_i;
        opcode_b_fault_r = {fetch3_fault_page_i, fetch3_fault_fetch_i};
    end
    // Slot 3 valid - mux to first
    else if (slot3_valid_r)
    begin
        opcode_a_valid_r = 1'b1;
        opcode_b_valid_r = 1'b0;
        opcode_c_valid_r = 1'b0;
        opcode_d_valid_r = 1'b0;

        opcode_a_r       = fetch3_instr_i;
        opcode_a_pc_r    = fetch3_pc_i;
        opcode_a_fault_r = {fetch3_fault_page_i, fetch3_fault_fetch_i};
    end
end

// Decode wires - Slot A
wire [4:0] issue_a_ra_idx_w   = opcode_a_r[19:15];
wire [4:0] issue_a_rb_idx_w   = opcode_a_r[24:20];
wire [4:0] issue_a_rd_idx_w   = opcode_a_r[11:7];
wire       issue_a_sb_alloc_w = (slot0_valid_r ? fetch0_instr_rd_valid_i : (slot1_valid_r ? fetch1_instr_rd_valid_i : (slot2_valid_r ? fetch2_instr_rd_valid_i : fetch3_instr_rd_valid_i)));
wire       issue_a_exec_w     = (slot0_valid_r ? fetch0_instr_exec_i     : (slot1_valid_r ? fetch1_instr_exec_i     : (slot2_valid_r ? fetch2_instr_exec_i     : fetch3_instr_exec_i)));
wire       issue_a_lsu_w      = (slot0_valid_r ? fetch0_instr_lsu_i      : (slot1_valid_r ? fetch1_instr_lsu_i      : (slot2_valid_r ? fetch2_instr_lsu_i      : fetch3_instr_lsu_i)));
wire       issue_a_branch_w   = (slot0_valid_r ? fetch0_instr_branch_i   : (slot1_valid_r ? fetch1_instr_branch_i   : (slot2_valid_r ? fetch2_instr_branch_i   : fetch3_instr_branch_i)));
wire       issue_a_mul_w      = (slot0_valid_r ? fetch0_instr_mul_i      : (slot1_valid_r ? fetch1_instr_mul_i      : (slot2_valid_r ? fetch2_instr_mul_i      : fetch3_instr_mul_i)));
wire       issue_a_div_w      = (slot0_valid_r ? fetch0_instr_div_i      : (slot1_valid_r ? fetch1_instr_div_i      : (slot2_valid_r ? fetch2_instr_div_i      : fetch3_instr_div_i)));
wire       issue_a_csr_w      = (slot0_valid_r ? fetch0_instr_csr_i      : (slot1_valid_r ? fetch1_instr_csr_i      : (slot2_valid_r ? fetch2_instr_csr_i      : fetch3_instr_csr_i)));
wire       issue_a_invalid_w  = (slot0_valid_r ? fetch0_instr_invalid_i  : (slot1_valid_r ? fetch1_instr_invalid_i  : (slot2_valid_r ? fetch2_instr_invalid_i  : fetch3_instr_invalid_i)));

// Decode wires - Slot B
wire [4:0] issue_b_ra_idx_w   = opcode_b_r[19:15];
wire [4:0] issue_b_rb_idx_w   = opcode_b_r[24:20];
wire [4:0] issue_b_rd_idx_w   = opcode_b_r[11:7];
// Approximation: uses muxed signal logic based on slot shifts
wire       issue_b_sb_alloc_w = (slot0_valid_r ? fetch1_instr_rd_valid_i : (slot1_valid_r ? fetch2_instr_rd_valid_i : fetch3_instr_rd_valid_i));
wire       issue_b_exec_w     = (slot0_valid_r ? fetch1_instr_exec_i     : (slot1_valid_r ? fetch2_instr_exec_i     : fetch3_instr_exec_i));
wire       issue_b_lsu_w      = (slot0_valid_r ? fetch1_instr_lsu_i      : (slot1_valid_r ? fetch2_instr_lsu_i      : fetch3_instr_lsu_i));
wire       issue_b_branch_w   = (slot0_valid_r ? fetch1_instr_branch_i   : (slot1_valid_r ? fetch2_instr_branch_i   : fetch3_instr_branch_i));
wire       issue_b_mul_w      = (slot0_valid_r ? fetch1_instr_mul_i      : (slot1_valid_r ? fetch2_instr_mul_i      : fetch3_instr_mul_i));
wire       issue_b_div_w      = (slot0_valid_r ? fetch1_instr_div_i      : (slot1_valid_r ? fetch2_instr_div_i      : fetch3_instr_div_i));
wire       issue_b_csr_w      = (slot0_valid_r ? fetch1_instr_csr_i      : (slot1_valid_r ? fetch2_instr_csr_i      : fetch3_instr_csr_i));
wire       issue_b_invalid_w  = (slot0_valid_r ? fetch1_instr_invalid_i  : (slot1_valid_r ? fetch2_instr_invalid_i  : fetch3_instr_invalid_i));

// Decode wires - Slot C
wire [4:0] issue_c_ra_idx_w   = opcode_c_r[19:15];
wire [4:0] issue_c_rb_idx_w   = opcode_c_r[24:20];
wire [4:0] issue_c_rd_idx_w   = opcode_c_r[11:7];
wire       issue_c_sb_alloc_w = (slot0_valid_r ? fetch2_instr_rd_valid_i : fetch3_instr_rd_valid_i);
wire       issue_c_exec_w     = (slot0_valid_r ? fetch2_instr_exec_i     : fetch3_instr_exec_i);
wire       issue_c_lsu_w      = (slot0_valid_r ? fetch2_instr_lsu_i      : fetch3_instr_lsu_i);
wire       issue_c_branch_w   = (slot0_valid_r ? fetch2_instr_branch_i   : fetch3_instr_branch_i);
wire       issue_c_mul_w      = (slot0_valid_r ? fetch2_instr_mul_i      : fetch3_instr_mul_i);
wire       issue_c_div_w      = (slot0_valid_r ? fetch2_instr_div_i      : fetch3_instr_div_i);
wire       issue_c_csr_w      = (slot0_valid_r ? fetch2_instr_csr_i      : fetch3_instr_csr_i);
wire       issue_c_invalid_w  = (slot0_valid_r ? fetch2_instr_invalid_i  : fetch3_instr_invalid_i);

// Decode wires - Slot D
wire [4:0] issue_d_ra_idx_w   = opcode_d_r[19:15];
wire [4:0] issue_d_rb_idx_w   = opcode_d_r[24:20];
wire [4:0] issue_d_rd_idx_w   = opcode_d_r[11:7];
wire       issue_d_sb_alloc_w = fetch3_instr_rd_valid_i;
wire       issue_d_exec_w     = fetch3_instr_exec_i;
wire       issue_d_lsu_w      = fetch3_instr_lsu_i;
wire       issue_d_branch_w   = fetch3_instr_branch_i;
wire       issue_d_mul_w      = fetch3_instr_mul_i;
wire       issue_d_div_w      = fetch3_instr_div_i;
wire       issue_d_csr_w      = fetch3_instr_csr_i;
wire       issue_d_invalid_w  = fetch3_instr_invalid_i;

//-------------------------------------------------------------
// Pipe Status Tracking (0 and 1 existing, 2 and 3 added)
//------------------------------------------------------------- 
wire        pipe0_squash_e1_e2_w;
wire        pipe1_squash_e1_e2_w;
wire        pipe2_squash_e1_e2_w;
wire        pipe3_squash_e1_e2_w;

reg         opcode_a_issue_r;
reg         opcode_a_accept_r;
wire        pipe0_stall_raw_w;
wire        pipe0_load_e1_w;
wire        pipe0_store_e1_w;
wire        pipe0_mul_e1_w;
wire        pipe0_branch_e1_w;
wire [4:0]  pipe0_rd_e1_w;
wire [31:0] pipe0_pc_e1_w;
wire [31:0] pipe0_opcode_e1_w;
wire [31:0] pipe0_operand_ra_e1_w;
wire [31:0] pipe0_operand_rb_e1_w;
wire        pipe0_load_e2_w;
wire        pipe0_mul_e2_w;
wire [4:0]  pipe0_rd_e2_w;
wire [31:0] pipe0_result_e2_w;
wire        pipe0_valid_wb_w;
wire        pipe0_csr_wb_w;
wire [4:0]  pipe0_rd_wb_w;
wire [31:0] pipe0_result_wb_w;
wire [31:0] pipe0_pc_wb_w;
wire [31:0] pipe0_opc_wb_w;
wire [31:0] pipe0_ra_val_wb_w;
wire [31:0] pipe0_rb_val_wb_w;
wire [`EXCEPTION_W-1:0] pipe0_exception_wb_w;

wire [`EXCEPTION_W-1:0] issue_a_fault_w = opcode_a_fault_r[0] ? `EXCEPTION_FAULT_FETCH:
                                          opcode_a_fault_r[1] ? `EXCEPTION_PAGE_FAULT_INST: `EXCEPTION_W'b0;

pipe_ctrl
#( 
    .SUPPORT_LOAD_BYPASS(SUPPORT_LOAD_BYPASS),
    .SUPPORT_MUL_BYPASS(SUPPORT_MUL_BYPASS)
)
u_pipe0_ctrl
(
    .clk_i(clk_i),
    .rst_i(rst_i),    
    // Issue
    .issue_valid_i(opcode_a_issue_r),
    .issue_accept_i(opcode_a_accept_r),
    .issue_stall_i(stall_w),
    .issue_lsu_i(issue_a_lsu_w),
    .issue_csr_i(issue_a_csr_w),
    .issue_div_i(issue_a_div_w),
    .issue_mul_i(issue_a_mul_w),
    .issue_branch_i(issue_a_branch_w),
    .issue_rd_valid_i(issue_a_sb_alloc_w),
    .issue_rd_i(issue_a_rd_idx_w),
    .issue_exception_i(issue_a_fault_w),
    .issue_pc_i(opcode0_pc_o),
    .issue_opcode_i(opcode0_opcode_o),
    .issue_operand_ra_i(opcode0_ra_operand_o),
    .issue_operand_rb_i(opcode0_rb_operand_o),
    .issue_branch_taken_i(branch_d_exec0_request_i),
    .issue_branch_target_i(branch_d_exec0_pc_i),
    .take_interrupt_i(take_interrupt_i),
    // Execution stage 1: ALU result
    .alu_result_e1_i(writeback_exec0_value_i),
    .csr_result_value_e1_i(csr_result_e1_value_i),
    .csr_result_write_e1_i(csr_result_e1_write_i),
    .csr_result_wdata_e1_i(csr_result_e1_wdata_i),
    .csr_result_exception_e1_i(csr_result_e1_exception_i),
    // Execution stage 1
    .load_e1_o(pipe0_load_e1_w),
    .store_e1_o(pipe0_store_e1_w),
    .mul_e1_o(pipe0_mul_e1_w),
    .branch_e1_o(pipe0_branch_e1_w),
    .rd_e1_o(pipe0_rd_e1_w),
    .pc_e1_o(pipe0_pc_e1_w),
    .opcode_e1_o(pipe0_opcode_e1_w),
    .operand_ra_e1_o(pipe0_operand_ra_e1_w),
    .operand_rb_e1_o(pipe0_operand_rb_e1_w),
    // Execution stage 2: Other results
    .mem_complete_i(writeback_mem_valid_i),
    .mem_result_e2_i(writeback_mem_value_i),
    .mem_exception_e2_i(writeback_mem_exception_i),
    .mul_result_e2_i(writeback_mul_value_i),
    // Execution stage 2
    .load_e2_o(pipe0_load_e2_w),
    .mul_e2_o(pipe0_mul_e2_w),
    .rd_e2_o(pipe0_rd_e2_w),
    .result_e2_o(pipe0_result_e2_w),
    .stall_o(pipe0_stall_raw_w),
    .squash_e1_e2_o(pipe0_squash_e1_e2_w),
    .squash_e1_e2_i(pipe1_squash_e1_e2_w | pipe2_squash_e1_e2_w | pipe3_squash_e1_e2_w),
    .squash_wb_i(1'b0),
    // Out of pipe: Divide Result
    .div_complete_i(writeback_div_valid_i),
    .div_result_i(writeback_div_value_i),
    // Commit
    .valid_wb_o(pipe0_valid_wb_w),
    .csr_wb_o(pipe0_csr_wb_w),
    .rd_wb_o(pipe0_rd_wb_w),
    .result_wb_o(pipe0_result_wb_w),
    .pc_wb_o(pipe0_pc_wb_w),
    .opcode_wb_o(pipe0_opc_wb_w),
    .operand_ra_wb_o(pipe0_ra_val_wb_w),
    .operand_rb_wb_o(pipe0_rb_val_wb_w),
    .exception_wb_o(pipe0_exception_wb_w),
    .csr_write_wb_o(csr_writeback_write_o),
    .csr_waddr_wb_o(csr_writeback_waddr_o),
    .csr_wdata_wb_o(csr_writeback_wdata_o)   
);

assign exec0_hold_o = stall_w;
assign mul_hold_o   = stall_w;

//-------------------------------------------------------------
// Pipe1
//-------------------------------------------------------------
reg         opcode_b_issue_r;
reg         opcode_b_accept_r;
wire        pipe1_stall_raw_w;
wire        pipe1_load_e1_w;
wire        pipe1_store_e1_w;
wire        pipe1_mul_e1_w;
wire        pipe1_branch_e1_w;
wire [4:0]  pipe1_rd_e1_w;
wire [31:0] pipe1_pc_e1_w;
wire [31:0] pipe1_opcode_e1_w;
wire [31:0] pipe1_operand_ra_e1_w;
wire [31:0] pipe1_operand_rb_e1_w;
wire        pipe1_load_e2_w;
wire        pipe1_mul_e2_w;
wire [4:0]  pipe1_rd_e2_w;
wire [31:0] pipe1_result_e2_w;
wire        pipe1_valid_wb_w;
wire [4:0]  pipe1_rd_wb_w;
wire [31:0] pipe1_result_wb_w;
wire [31:0] pipe1_pc_wb_w;
wire [31:0] pipe1_opc_wb_w;
wire [31:0] pipe1_ra_val_wb_w;
wire [31:0] pipe1_rb_val_wb_w;
wire [`EXCEPTION_W-1:0] pipe1_exception_wb_w;

wire [`EXCEPTION_W-1:0] issue_b_fault_w = opcode_b_fault_r[0] ? `EXCEPTION_FAULT_FETCH:
                                          opcode_b_fault_r[1] ? `EXCEPTION_PAGE_FAULT_INST: `EXCEPTION_W'b0;

pipe_ctrl
#( 
    .SUPPORT_LOAD_BYPASS(SUPPORT_LOAD_BYPASS),
    .SUPPORT_MUL_BYPASS(SUPPORT_MUL_BYPASS)
)
u_pipe1_ctrl
(
    .clk_i(clk_i),
    .rst_i(rst_i),
    // Issue
    .issue_valid_i(opcode_b_issue_r),
    .issue_accept_i(opcode_b_accept_r),
    .issue_stall_i(stall_w),
    .issue_lsu_i(issue_b_lsu_w),
    .issue_csr_i(1'b0),
    .issue_div_i(1'b0),
    .issue_mul_i(issue_b_mul_w),
    .issue_branch_i(issue_b_branch_w),
    .issue_rd_valid_i(issue_b_sb_alloc_w),
    .issue_rd_i(issue_b_rd_idx_w),
    .issue_exception_i(issue_b_fault_w),
    .issue_pc_i(opcode1_pc_o),
    .issue_opcode_i(opcode1_opcode_o),
    .issue_operand_ra_i(opcode1_ra_operand_o),
    .issue_operand_rb_i(opcode1_rb_operand_o),
    .issue_branch_taken_i(branch_d_exec1_request_i),
    .issue_branch_target_i(branch_d_exec1_pc_i),
    .take_interrupt_i(take_interrupt_i),
    // Execution stage 1: ALU, CSR result
    .alu_result_e1_i(writeback_exec1_value_i),
    .csr_result_value_e1_i(csr_result_e1_value_i),
    .csr_result_write_e1_i(csr_result_e1_write_i),
    .csr_result_wdata_e1_i(csr_result_e1_wdata_i),
    .csr_result_exception_e1_i(csr_result_e1_exception_i),
    // Execution stage 1
    .load_e1_o(pipe1_load_e1_w),
    .store_e1_o(pipe1_store_e1_w),
    .mul_e1_o(pipe1_mul_e1_w),
    .branch_e1_o(pipe1_branch_e1_w),
    .rd_e1_o(pipe1_rd_e1_w),
    .pc_e1_o(pipe1_pc_e1_w),
    .opcode_e1_o(pipe1_opcode_e1_w),
    .operand_ra_e1_o(pipe1_operand_ra_e1_w),
    .operand_rb_e1_o(pipe1_operand_rb_e1_w),
    // Execution stage 2: Other results
    .mem_complete_i(writeback_mem_valid_i),
    .mem_result_e2_i(writeback_mem_value_i),
    .mem_exception_e2_i(writeback_mem_exception_i),
    .mul_result_e2_i(writeback_mul_value_i),
    // Execution stage 2
    .load_e2_o(pipe1_load_e2_w),
    .mul_e2_o(pipe1_mul_e2_w),
    .rd_e2_o(pipe1_rd_e2_w),
    .result_e2_o(pipe1_result_e2_w),
    .stall_o(pipe1_stall_raw_w),
    .squash_e1_e2_o(pipe1_squash_e1_e2_w),
    .squash_e1_e2_i(pipe0_squash_e1_e2_w | pipe2_squash_e1_e2_w | pipe3_squash_e1_e2_w),
    .squash_wb_i(pipe0_squash_e1_e2_w),
    // Out of pipe: Divide Result
    .div_complete_i(writeback_div_valid_i),
    .div_result_i(writeback_div_value_i),
    // Commit
    .valid_wb_o(pipe1_valid_wb_w),
    .csr_wb_o(),
    .rd_wb_o(pipe1_rd_wb_w),
    .result_wb_o(pipe1_result_wb_w),
    .pc_wb_o(pipe1_pc_wb_w),
    .opcode_wb_o(pipe1_opc_wb_w),
    .operand_ra_wb_o(pipe1_ra_val_wb_w),
    .operand_rb_wb_o(pipe1_rb_val_wb_w),
    .exception_wb_o(pipe1_exception_wb_w),
    .csr_write_wb_o(),
    .csr_waddr_wb_o(),
    .csr_wdata_wb_o()
);

assign exec1_hold_o = stall_w;

//-------------------------------------------------------------
// Pipe2
//-------------------------------------------------------------
reg         opcode_c_issue_r;
reg         opcode_c_accept_r;
wire        pipe2_stall_raw_w;
wire        pipe2_load_e1_w;
wire        pipe2_store_e1_w;
wire        pipe2_mul_e1_w;
wire        pipe2_branch_e1_w;
wire [4:0]  pipe2_rd_e1_w;
wire [31:0] pipe2_pc_e1_w;
wire [31:0] pipe2_opcode_e1_w;
wire [31:0] pipe2_operand_ra_e1_w;
wire [31:0] pipe2_operand_rb_e1_w;
wire        pipe2_load_e2_w;
wire        pipe2_mul_e2_w;
wire [4:0]  pipe2_rd_e2_w;
wire [31:0] pipe2_result_e2_w;
wire        pipe2_valid_wb_w;
wire [4:0]  pipe2_rd_wb_w;
wire [31:0] pipe2_result_wb_w;
wire [31:0] pipe2_pc_wb_w;
wire [31:0] pipe2_opc_wb_w;
wire [31:0] pipe2_ra_val_wb_w;
wire [31:0] pipe2_rb_val_wb_w;
wire [`EXCEPTION_W-1:0] pipe2_exception_wb_w;

wire [`EXCEPTION_W-1:0] issue_c_fault_w = opcode_c_fault_r[0] ? `EXCEPTION_FAULT_FETCH:
                                          opcode_c_fault_r[1] ? `EXCEPTION_PAGE_FAULT_INST: `EXCEPTION_W'b0;

pipe_ctrl
#( 
    .SUPPORT_LOAD_BYPASS(SUPPORT_LOAD_BYPASS),
    .SUPPORT_MUL_BYPASS(SUPPORT_MUL_BYPASS)
)
u_pipe2_ctrl
(
    .clk_i(clk_i),
    .rst_i(rst_i),
    // Issue
    .issue_valid_i(opcode_c_issue_r),
    .issue_accept_i(opcode_c_accept_r),
    .issue_stall_i(stall_w),
    .issue_lsu_i(issue_c_lsu_w),
    .issue_csr_i(1'b0),
    .issue_div_i(1'b0),
    .issue_mul_i(issue_c_mul_w),
    .issue_branch_i(issue_c_branch_w),
    .issue_rd_valid_i(issue_c_sb_alloc_w),
    .issue_rd_i(issue_c_rd_idx_w),
    .issue_exception_i(issue_c_fault_w),
    .issue_pc_i(opcode2_pc_o),
    .issue_opcode_i(opcode2_opcode_o),
    .issue_operand_ra_i(opcode2_ra_operand_o),
    .issue_operand_rb_i(opcode2_rb_operand_o),
    .issue_branch_taken_i(branch_d_exec2_request_i),
    .issue_branch_target_i(branch_d_exec2_pc_i),
    .take_interrupt_i(take_interrupt_i),
    // Execution stage 1
    .alu_result_e1_i(writeback_exec2_value_i),
    .csr_result_value_e1_i(csr_result_e1_value_i),
    .csr_result_write_e1_i(csr_result_e1_write_i),
    .csr_result_wdata_e1_i(csr_result_e1_wdata_i),
    .csr_result_exception_e1_i(csr_result_e1_exception_i),
    // Execution stage 1
    .load_e1_o(pipe2_load_e1_w),
    .store_e1_o(pipe2_store_e1_w),
    .mul_e1_o(pipe2_mul_e1_w),
    .branch_e1_o(pipe2_branch_e1_w),
    .rd_e1_o(pipe2_rd_e1_w),
    .pc_e1_o(pipe2_pc_e1_w),
    .opcode_e1_o(pipe2_opcode_e1_w),
    .operand_ra_e1_o(pipe2_operand_ra_e1_w),
    .operand_rb_e1_o(pipe2_operand_rb_e1_w),
    // Execution stage 2: Other results
    .mem_complete_i(writeback_mem_valid_i),
    .mem_result_e2_i(writeback_mem_value_i),
    .mem_exception_e2_i(writeback_mem_exception_i),
    .mul_result_e2_i(writeback_mul_value_i),
    // Execution stage 2
    .load_e2_o(pipe2_load_e2_w),
    .mul_e2_o(pipe2_mul_e2_w),
    .rd_e2_o(pipe2_rd_e2_w),
    .result_e2_o(pipe2_result_e2_w),
    .stall_o(pipe2_stall_raw_w),
    .squash_e1_e2_o(pipe2_squash_e1_e2_w),
    .squash_e1_e2_i(pipe0_squash_e1_e2_w | pipe1_squash_e1_e2_w | pipe3_squash_e1_e2_w),
    .squash_wb_i(pipe0_squash_e1_e2_w | pipe1_squash_e1_e2_w),
    // Out of pipe: Divide Result
    .div_complete_i(writeback_div_valid_i),
    .div_result_i(writeback_div_value_i),
    // Commit
    .valid_wb_o(pipe2_valid_wb_w),
    .csr_wb_o(),
    .rd_wb_o(pipe2_rd_wb_w),
    .result_wb_o(pipe2_result_wb_w),
    .pc_wb_o(pipe2_pc_wb_w),
    .opcode_wb_o(pipe2_opc_wb_w),
    .operand_ra_wb_o(pipe2_ra_val_wb_w),
    .operand_rb_wb_o(pipe2_rb_val_wb_w),
    .exception_wb_o(pipe2_exception_wb_w),
    .csr_write_wb_o(),
    .csr_waddr_wb_o(),
    .csr_wdata_wb_o()
);

assign exec2_hold_o = stall_w;

//-------------------------------------------------------------
// Pipe3
//-------------------------------------------------------------
reg         opcode_d_issue_r;
reg         opcode_d_accept_r;
wire        pipe3_stall_raw_w;
wire        pipe3_load_e1_w;
wire        pipe3_store_e1_w;
wire        pipe3_mul_e1_w;
wire        pipe3_branch_e1_w;
wire [4:0]  pipe3_rd_e1_w;
wire [31:0] pipe3_pc_e1_w;
wire [31:0] pipe3_opcode_e1_w;
wire [31:0] pipe3_operand_ra_e1_w;
wire [31:0] pipe3_operand_rb_e1_w;
wire        pipe3_load_e2_w;
wire        pipe3_mul_e2_w;
wire [4:0]  pipe3_rd_e2_w;
wire [31:0] pipe3_result_e2_w;
wire        pipe3_valid_wb_w;
wire [4:0]  pipe3_rd_wb_w;
wire [31:0] pipe3_result_wb_w;
wire [31:0] pipe3_pc_wb_w;
wire [31:0] pipe3_opc_wb_w;
wire [31:0] pipe3_ra_val_wb_w;
wire [31:0] pipe3_rb_val_wb_w;
wire [`EXCEPTION_W-1:0] pipe3_exception_wb_w;

wire [`EXCEPTION_W-1:0] issue_d_fault_w = opcode_d_fault_r[0] ? `EXCEPTION_FAULT_FETCH:
                                          opcode_d_fault_r[1] ? `EXCEPTION_PAGE_FAULT_INST: `EXCEPTION_W'b0;

pipe_ctrl
#( 
    .SUPPORT_LOAD_BYPASS(SUPPORT_LOAD_BYPASS),
    .SUPPORT_MUL_BYPASS(SUPPORT_MUL_BYPASS)
)
u_pipe3_ctrl
(
    .clk_i(clk_i),
    .rst_i(rst_i),
    // Issue
    .issue_valid_i(opcode_d_issue_r),
    .issue_accept_i(opcode_d_accept_r),
    .issue_stall_i(stall_w),
    .issue_lsu_i(issue_d_lsu_w),
    .issue_csr_i(1'b0),
    .issue_div_i(1'b0),
    .issue_mul_i(issue_d_mul_w),
    .issue_branch_i(issue_d_branch_w),
    .issue_rd_valid_i(issue_d_sb_alloc_w),
    .issue_rd_i(issue_d_rd_idx_w),
    .issue_exception_i(issue_d_fault_w),
    .issue_pc_i(opcode3_pc_o),
    .issue_opcode_i(opcode3_opcode_o),
    .issue_operand_ra_i(opcode3_ra_operand_o),
    .issue_operand_rb_i(opcode3_rb_operand_o),
    .issue_branch_taken_i(branch_d_exec3_request_i),
    .issue_branch_target_i(branch_d_exec3_pc_i),
    .take_interrupt_i(take_interrupt_i),
    // Execution stage 1
    .alu_result_e1_i(writeback_exec3_value_i),
    .csr_result_value_e1_i(csr_result_e1_value_i),
    .csr_result_write_e1_i(csr_result_e1_write_i),
    .csr_result_wdata_e1_i(csr_result_e1_wdata_i),
    .csr_result_exception_e1_i(csr_result_e1_exception_i),
    // Execution stage 1
    .load_e1_o(pipe3_load_e1_w),
    .store_e1_o(pipe3_store_e1_w),
    .mul_e1_o(pipe3_mul_e1_w),
    .branch_e1_o(pipe3_branch_e1_w),
    .rd_e1_o(pipe3_rd_e1_w),
    .pc_e1_o(pipe3_pc_e1_w),
    .opcode_e1_o(pipe3_opcode_e1_w),
    .operand_ra_e1_o(pipe3_operand_ra_e1_w),
    .operand_rb_e1_o(pipe3_operand_rb_e1_w),
    // Execution stage 2: Other results
    .mem_complete_i(writeback_mem_valid_i),
    .mem_result_e2_i(writeback_mem_value_i),
    .mem_exception_e2_i(writeback_mem_exception_i),
    .mul_result_e2_i(writeback_mul_value_i),
    // Execution stage 2
    .load_e2_o(pipe3_load_e2_w),
    .mul_e2_o(pipe3_mul_e2_w),
    .rd_e2_o(pipe3_rd_e2_w),
    .result_e2_o(pipe3_result_e2_w),
    .stall_o(pipe3_stall_raw_w),
    .squash_e1_e2_o(pipe3_squash_e1_e2_w),
    .squash_e1_e2_i(pipe0_squash_e1_e2_w | pipe1_squash_e1_e2_w | pipe2_squash_e1_e2_w),
    .squash_wb_i(pipe0_squash_e1_e2_w | pipe1_squash_e1_e2_w | pipe2_squash_e1_e2_w),
    // Out of pipe: Divide Result
    .div_complete_i(writeback_div_valid_i),
    .div_result_i(writeback_div_value_i),
    // Commit
    .valid_wb_o(pipe3_valid_wb_w),
    .csr_wb_o(),
    .rd_wb_o(pipe3_rd_wb_w),
    .result_wb_o(pipe3_result_wb_w),
    .pc_wb_o(pipe3_pc_wb_w),
    .opcode_wb_o(pipe3_opc_wb_w),
    .operand_ra_wb_o(pipe3_ra_val_wb_w),
    .operand_rb_wb_o(pipe3_rb_val_wb_w),
    .exception_wb_o(pipe3_exception_wb_w),
    .csr_write_wb_o(),
    .csr_waddr_wb_o(),
    .csr_wdata_wb_o()
);

assign exec3_hold_o = stall_w;

assign csr_writeback_exception_o      = pipe0_exception_wb_w | pipe1_exception_wb_w | pipe2_exception_wb_w | pipe3_exception_wb_w;
assign csr_writeback_exception_pc_o   = (|pipe0_exception_wb_w) ? pipe0_pc_wb_w : 
                                        (|pipe1_exception_wb_w) ? pipe1_pc_wb_w :
                                        (|pipe2_exception_wb_w) ? pipe2_pc_wb_w : pipe3_pc_wb_w;
assign csr_writeback_exception_addr_o = (|pipe0_exception_wb_w) ? pipe0_result_wb_w : 
                                        (|pipe1_exception_wb_w) ? pipe1_result_wb_w :
                                        (|pipe2_exception_wb_w) ? pipe2_result_wb_w : pipe3_result_wb_w;

//-------------------------------------------------------------
// Branch predictor info
//-------------------------------------------------------------
assign branch_info_request_o      = mispredicted_r;
assign branch_info_is_taken_o     = (pipe3_branch_e1_w & branch_exec3_is_taken_i)     | (pipe2_branch_e1_w & branch_exec2_is_taken_i) | (pipe1_branch_e1_w & branch_exec1_is_taken_i) | (pipe0_branch_e1_w & branch_exec0_is_taken_i);
assign branch_info_is_not_taken_o = (pipe3_branch_e1_w & branch_exec3_is_not_taken_i) | (pipe2_branch_e1_w & branch_exec2_is_not_taken_i) | (pipe1_branch_e1_w & branch_exec1_is_not_taken_i) | (pipe0_branch_e1_w & branch_exec0_is_not_taken_i);
assign branch_info_is_call_o      = (pipe3_branch_e1_w & branch_exec3_is_call_i)      | (pipe2_branch_e1_w & branch_exec2_is_call_i) | (pipe1_branch_e1_w & branch_exec1_is_call_i) | (pipe0_branch_e1_w & branch_exec0_is_call_i);
assign branch_info_is_ret_o       = (pipe3_branch_e1_w & branch_exec3_is_ret_i)       | (pipe2_branch_e1_w & branch_exec2_is_ret_i) | (pipe1_branch_e1_w & branch_exec1_is_ret_i) | (pipe0_branch_e1_w & branch_exec0_is_ret_i);
assign branch_info_is_jmp_o       = (pipe3_branch_e1_w & branch_exec3_is_jmp_i)       | (pipe2_branch_e1_w & branch_exec2_is_jmp_i) | (pipe1_branch_e1_w & branch_exec1_is_jmp_i) | (pipe0_branch_e1_w & branch_exec0_is_jmp_i);
assign branch_info_source_o       = (pipe3_branch_e1_w & branch_exec3_request_i)      ? branch_exec3_source_i : 
                                    (pipe2_branch_e1_w & branch_exec2_request_i)      ? branch_exec2_source_i : 
                                    (pipe1_branch_e1_w & branch_exec1_request_i)      ? branch_exec1_source_i : branch_exec0_source_i;
assign branch_info_pc_o           = (pipe3_branch_e1_w & branch_exec3_request_i)      ? branch_exec3_pc_i     : 
                                    (pipe2_branch_e1_w & branch_exec2_request_i)      ? branch_exec2_pc_i     :
                                    (pipe1_branch_e1_w & branch_exec1_request_i)      ? branch_exec1_pc_i     : branch_exec0_pc_i;

//-------------------------------------------------------------
// Blocking events (division, CSR unit access)
//-------------------------------------------------------------
reg div_pending_q;
reg csr_pending_q;
// Division operations take 2 - 34 cycles and stall
// the pipeline (complete out-of-pipe) until completed.
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    div_pending_q <= 1'b0;
else if (pipe0_squash_e1_e2_w || pipe1_squash_e1_e2_w || pipe2_squash_e1_e2_w || pipe3_squash_e1_e2_w)
    div_pending_q <= 1'b0;
else if (div_opcode_valid_o && issue_a_div_w)
    div_pending_q <= 1'b1;
else if (writeback_div_valid_i)
    div_pending_q <= 1'b0;
// CSR operations are infrequent - avoid any complications of pipelining them.
// These only take a 2-3 cycles anyway and may result in a pipe flush (e.g. ecall, ebreak..).
always @ (posedge clk_i or posedge rst_i)
if (rst_i)
    csr_pending_q <= 1'b0;
else if (pipe0_squash_e1_e2_w || pipe1_squash_e1_e2_w || pipe2_squash_e1_e2_w || pipe3_squash_e1_e2_w)
    csr_pending_q <= 1'b0;
else if (csr_opcode_valid_o && issue_a_csr_w)
    csr_pending_q <= 1'b1;
else if (pipe0_csr_wb_w)
    csr_pending_q <= 1'b0;
assign squash_w = pipe0_squash_e1_e2_w || pipe1_squash_e1_e2_w || pipe2_squash_e1_e2_w || pipe3_squash_e1_e2_w;

//-------------------------------------------------------------
// Issue / scheduling logic
//-------------------------------------------------------------
reg [31:0] scoreboard_r;
reg [1:0]  pipe_mux_lsu_r; // 0=A, 1=B, 2=C, 3=D
reg [1:0]  pipe_mux_mul_r; // 0=A, 1=B, 2=C, 3=D

wire pipe1_ok_w      = issue_b_exec_w | issue_b_branch_w | issue_b_lsu_w | issue_b_mul_w;
wire pipe2_ok_w      = issue_c_exec_w | issue_c_branch_w | issue_c_lsu_w | issue_c_mul_w;
wire pipe3_ok_w      = issue_d_exec_w | issue_d_branch_w | issue_d_lsu_w | issue_d_mul_w;

// Helper to track resource usage (single LSU/MUL constraint assumption from original)
reg lsu_claimed;
reg mul_claimed;

always @ *
begin
    opcode_a_issue_r     = 1'b0;
    opcode_b_issue_r     = 1'b0;
    opcode_c_issue_r     = 1'b0;
    opcode_d_issue_r     = 1'b0;
    opcode_a_accept_r    = 1'b0;
    opcode_b_accept_r    = 1'b0;
    opcode_c_accept_r    = 1'b0;
    opcode_d_accept_r    = 1'b0;
    scoreboard_r         = 32'b0;
    pipe_mux_lsu_r       = 2'b0;
    pipe_mux_mul_r       = 2'b0;
    lsu_claimed          = 1'b0;
    mul_claimed          = 1'b0;

    // Execution units with >= 2 cycle latency (E2 check)
    if (SUPPORT_LOAD_BYPASS == 0) begin
        if (pipe0_load_e2_w) scoreboard_r[pipe0_rd_e2_w] = 1'b1;
        if (pipe1_load_e2_w) scoreboard_r[pipe1_rd_e2_w] = 1'b1;
        if (pipe2_load_e2_w) scoreboard_r[pipe2_rd_e2_w] = 1'b1;
        if (pipe3_load_e2_w) scoreboard_r[pipe3_rd_e2_w] = 1'b1;
    end
    if (SUPPORT_MUL_BYPASS == 0) begin
        if (pipe0_mul_e2_w) scoreboard_r[pipe0_rd_e2_w] = 1'b1;
        if (pipe1_mul_e2_w) scoreboard_r[pipe1_rd_e2_w] = 1'b1;
        if (pipe2_mul_e2_w) scoreboard_r[pipe2_rd_e2_w] = 1'b1;
        if (pipe3_mul_e2_w) scoreboard_r[pipe3_rd_e2_w] = 1'b1;
    end

    // Execution units with >= 1 cycle latency (loads / multiply) (E1 check)
    if (pipe0_load_e1_w || pipe0_mul_e1_w) scoreboard_r[pipe0_rd_e1_w] = 1'b1;
    if (pipe1_load_e1_w || pipe1_mul_e1_w) scoreboard_r[pipe1_rd_e1_w] = 1'b1;
    if (pipe2_load_e1_w || pipe2_mul_e1_w) scoreboard_r[pipe2_rd_e1_w] = 1'b1;
    if (pipe3_load_e1_w || pipe3_mul_e1_w) scoreboard_r[pipe3_rd_e1_w] = 1'b1;

    // Do not start multiply, division or CSR operation in the cycle after a load
    if ((pipe0_load_e1_w || pipe0_store_e1_w || pipe1_load_e1_w || pipe1_store_e1_w || pipe2_load_e1_w || pipe2_store_e1_w || pipe3_load_e1_w || pipe3_store_e1_w) 
        && (issue_a_mul_w || issue_a_div_w || issue_a_csr_w))
        scoreboard_r = 32'hFFFFFFFF;

    // Stall - no issues...
    if (lsu_stall_i || stall_w || div_pending_q || csr_pending_q)
        ;
    // Primary slot (Slot A)
    else if (opcode_a_valid_r &&
        !(scoreboard_r[issue_a_ra_idx_w] || 
          scoreboard_r[issue_a_rb_idx_w] ||
          scoreboard_r[issue_a_rd_idx_w]))
    begin
        opcode_a_issue_r  = 1'b1;
        opcode_a_accept_r = 1'b1;

        if (issue_a_lsu_w) lsu_claimed = 1'b1;
        if (issue_a_mul_w) mul_claimed = 1'b1;

        if (opcode_a_accept_r && issue_a_sb_alloc_w && (|issue_a_rd_idx_w))
            scoreboard_r[issue_a_rd_idx_w] = 1'b1; // Mark dest as busy for next slots
    end

    // Stall check
    if (lsu_stall_i || stall_w || div_pending_q || csr_pending_q)
        ;
    // Secondary Slot (Slot B)
    else if (enable_dual_issue_w && opcode_b_valid_r && opcode_a_accept_r && pipe1_ok_w &&
        !(issue_b_lsu_w && lsu_claimed) && // Structural hazard: LSU
        !(issue_b_mul_w && mul_claimed) && // Structural hazard: MUL
        !(scoreboard_r[issue_b_ra_idx_w] || 
          scoreboard_r[issue_b_rb_idx_w] ||
          scoreboard_r[issue_b_rd_idx_w]))
    begin
        opcode_b_issue_r  = 1'b1;
        opcode_b_accept_r = 1'b1;

        if (issue_b_lsu_w) begin pipe_mux_lsu_r = 2'd1; lsu_claimed = 1'b1; end
        if (issue_b_mul_w) begin pipe_mux_mul_r = 2'd1; mul_claimed = 1'b1; end

        if (opcode_b_accept_r && issue_b_sb_alloc_w && (|issue_b_rd_idx_w))
            scoreboard_r[issue_b_rd_idx_w] = 1'b1;
    end  

    // Stall check
    if (lsu_stall_i || stall_w || div_pending_q || csr_pending_q)
        ;
    // Tertiary Slot (Slot C)
    else if (enable_dual_issue_w && opcode_c_valid_r && opcode_b_accept_r && pipe2_ok_w &&
        !(issue_c_lsu_w && lsu_claimed) &&
        !(issue_c_mul_w && mul_claimed) &&
        !(scoreboard_r[issue_c_ra_idx_w] || 
          scoreboard_r[issue_c_rb_idx_w] ||
          scoreboard_r[issue_c_rd_idx_w]))
    begin
        opcode_c_issue_r  = 1'b1;
        opcode_c_accept_r = 1'b1;

        if (issue_c_lsu_w) begin pipe_mux_lsu_r = 2'd2; lsu_claimed = 1'b1; end
        if (issue_c_mul_w) begin pipe_mux_mul_r = 2'd2; mul_claimed = 1'b1; end

        if (opcode_c_accept_r && issue_c_sb_alloc_w && (|issue_c_rd_idx_w))
            scoreboard_r[issue_c_rd_idx_w] = 1'b1;
    end

    // Stall check
    if (lsu_stall_i || stall_w || div_pending_q || csr_pending_q)
        ;
    // Quaternary Slot (Slot D)
    else if (enable_dual_issue_w && opcode_d_valid_r && opcode_c_accept_r && pipe3_ok_w &&
        !(issue_d_lsu_w && lsu_claimed) &&
        !(issue_d_mul_w && mul_claimed) &&
        !(scoreboard_r[issue_d_ra_idx_w] || 
          scoreboard_r[issue_d_rb_idx_w] ||
          scoreboard_r[issue_d_rd_idx_w]))
    begin
        opcode_d_issue_r  = 1'b1;
        opcode_d_accept_r = 1'b1;

        if (issue_d_lsu_w) begin pipe_mux_lsu_r = 2'd3; lsu_claimed = 1'b1; end
        if (issue_d_mul_w) begin pipe_mux_mul_r = 2'd3; mul_claimed = 1'b1; end

        // No need to update scoreboard for last slot
    end
end

assign lsu_opcode_valid_o   = ((pipe_mux_lsu_r == 2'd0) ? opcode_a_issue_r : (pipe_mux_lsu_r == 2'd1) ? opcode_b_issue_r : (pipe_mux_lsu_r == 2'd2) ? opcode_c_issue_r : opcode_d_issue_r) & ~take_interrupt_i;
assign exec0_opcode_valid_o = opcode_a_issue_r;
assign exec1_opcode_valid_o = opcode_b_issue_r;
assign exec2_opcode_valid_o = opcode_c_issue_r;
assign exec3_opcode_valid_o = opcode_d_issue_r;

assign mul_opcode_valid_o   = enable_muldiv_w & ((pipe_mux_mul_r == 2'd0) ? opcode_a_issue_r : (pipe_mux_mul_r == 2'd1) ? opcode_b_issue_r : (pipe_mux_mul_r == 2'd2) ? opcode_c_issue_r : opcode_d_issue_r);
assign div_opcode_valid_o   = enable_muldiv_w & (opcode_a_issue_r);
assign interrupt_inhibit_o  = csr_pending_q || issue_a_csr_w;

assign quad_issue_w         = opcode_d_issue_r & opcode_d_accept_r & ~take_interrupt_i;
assign triple_issue_w       = (opcode_c_issue_r & opcode_c_accept_r) & ~quad_issue_w & ~take_interrupt_i;
assign dual_issue_w         = (opcode_b_issue_r & opcode_b_accept_r) & ~triple_issue_w & ~quad_issue_w & ~take_interrupt_i;
assign single_issue_w       = (opcode_a_issue_r & opcode_a_accept_r) & ~dual_issue_w & ~triple_issue_w & ~quad_issue_w & ~take_interrupt_i;

assign fetch0_accept_o      = ((slot0_valid_r & opcode_a_accept_r) | slot1_valid_r | slot2_valid_r | slot3_valid_r) & ~take_interrupt_i;
assign fetch1_accept_o      = ((slot1_valid_r & opcode_a_accept_r) | (opcode_b_accept_r) | slot2_valid_r | slot3_valid_r) & ~take_interrupt_i;
assign fetch2_accept_o      = ((slot2_valid_r & opcode_a_accept_r) | (opcode_c_accept_r) | slot3_valid_r) & ~take_interrupt_i;
assign fetch3_accept_o      = ((slot3_valid_r & opcode_a_accept_r) | (opcode_d_accept_r)) & ~take_interrupt_i;

assign stall_w              = pipe0_stall_raw_w | pipe1_stall_raw_w | pipe2_stall_raw_w | pipe3_stall_raw_w;

//-------------------------------------------------------------
// Register File
//------------------------------------------------------------- 
wire [31:0] issue_a_ra_value_w;
wire [31:0] issue_a_rb_value_w;
wire [31:0] issue_b_ra_value_w;
wire [31:0] issue_b_rb_value_w;
wire [31:0] issue_c_ra_value_w;
wire [31:0] issue_c_rb_value_w;
wire [31:0] issue_d_ra_value_w;
wire [31:0] issue_d_rb_value_w;

// Register file: 4W8R
regfile
#(
    .SUPPORT_REGFILE_XILINX(SUPPORT_REGFILE_XILINX),
    //.SUPPORT_DUAL_ISSUE(SUPPORT_DUAL_ISSUE),
    .NUM_READ_PORTS(8),
    .NUM_WRITE_PORTS(4)
)
u_regfile
(
    .clk_i(clk_i),
    .rst_i(rst_i),

    // Write ports
    .rd0_i(pipe0_rd_wb_w),
    .rd0_value_i(pipe0_result_wb_w),
    .rd1_i(pipe1_rd_wb_w),
    .rd1_value_i(pipe1_result_wb_w),
    .rd2_i(pipe2_rd_wb_w),
    .rd2_value_i(pipe2_result_wb_w),
    .rd3_i(pipe3_rd_wb_w),
    .rd3_value_i(pipe3_result_wb_w),

    // Read ports
    .ra0_i(issue_a_ra_idx_w),
    .rb0_i(issue_a_rb_idx_w),
    .ra0_value_o(issue_a_ra_value_w),
    .rb0_value_o(issue_a_rb_value_w),

    .ra1_i(issue_b_ra_idx_w),
    .rb1_i(issue_b_rb_idx_w),
    .ra1_value_o(issue_b_ra_value_w),
    .rb1_value_o(issue_b_rb_value_w),

    .ra2_i(issue_c_ra_idx_w),
    .rb2_i(issue_c_rb_idx_w),
    .ra2_value_o(issue_c_ra_value_w),
    .rb2_value_o(issue_c_rb_value_w),

    .ra3_i(issue_d_ra_idx_w),
    .rb3_i(issue_d_rb_idx_w),
    .ra3_value_o(issue_d_ra_value_w),
    .rb3_value_o(issue_d_rb_value_w)
);

//-------------------------------------------------------------
// Issue Slot 0 (A) Bypass
//------------------------------------------------------------- 
assign opcode0_opcode_o = opcode_a_r;
assign opcode0_pc_o     = opcode_a_pc_r;
assign opcode0_rd_idx_o = issue_a_rd_idx_w;
assign opcode0_ra_idx_o = issue_a_ra_idx_w;
assign opcode0_rb_idx_o = issue_a_rb_idx_w;
assign opcode0_invalid_o= 1'b0; 

reg [31:0] issue_a_ra_value_r;
reg [31:0] issue_a_rb_value_r;
always @ *
begin
    issue_a_ra_value_r = issue_a_ra_value_w;
    issue_a_rb_value_r = issue_a_rb_value_w;
    // Bypass - WB
    if (pipe0_rd_wb_w == issue_a_ra_idx_w) issue_a_ra_value_r = pipe0_result_wb_w;
    if (pipe0_rd_wb_w == issue_a_rb_idx_w) issue_a_rb_value_r = pipe0_result_wb_w;
    if (pipe1_rd_wb_w == issue_a_ra_idx_w) issue_a_ra_value_r = pipe1_result_wb_w;
    if (pipe1_rd_wb_w == issue_a_rb_idx_w) issue_a_rb_value_r = pipe1_result_wb_w;
    if (pipe2_rd_wb_w == issue_a_ra_idx_w) issue_a_ra_value_r = pipe2_result_wb_w;
    if (pipe2_rd_wb_w == issue_a_rb_idx_w) issue_a_rb_value_r = pipe2_result_wb_w;
    if (pipe3_rd_wb_w == issue_a_ra_idx_w) issue_a_ra_value_r = pipe3_result_wb_w;
    if (pipe3_rd_wb_w == issue_a_rb_idx_w) issue_a_rb_value_r = pipe3_result_wb_w;
    // Bypass - E2
    if (pipe0_rd_e2_w == issue_a_ra_idx_w) issue_a_ra_value_r = pipe0_result_e2_w;
    if (pipe0_rd_e2_w == issue_a_rb_idx_w) issue_a_rb_value_r = pipe0_result_e2_w;
    if (pipe1_rd_e2_w == issue_a_ra_idx_w) issue_a_ra_value_r = pipe1_result_e2_w;
    if (pipe1_rd_e2_w == issue_a_rb_idx_w) issue_a_rb_value_r = pipe1_result_e2_w;
    if (pipe2_rd_e2_w == issue_a_ra_idx_w) issue_a_ra_value_r = pipe2_result_e2_w;
    if (pipe2_rd_e2_w == issue_a_rb_idx_w) issue_a_rb_value_r = pipe2_result_e2_w;
    if (pipe3_rd_e2_w == issue_a_ra_idx_w) issue_a_ra_value_r = pipe3_result_e2_w;
    if (pipe3_rd_e2_w == issue_a_rb_idx_w) issue_a_rb_value_r = pipe3_result_e2_w;
    // Bypass - E1
    if (pipe0_rd_e1_w == issue_a_ra_idx_w) issue_a_ra_value_r = writeback_exec0_value_i;
    if (pipe0_rd_e1_w == issue_a_rb_idx_w) issue_a_rb_value_r = writeback_exec0_value_i;
    if (pipe1_rd_e1_w == issue_a_ra_idx_w) issue_a_ra_value_r = writeback_exec1_value_i;
    if (pipe1_rd_e1_w == issue_a_rb_idx_w) issue_a_rb_value_r = writeback_exec1_value_i;
    if (pipe2_rd_e1_w == issue_a_ra_idx_w) issue_a_ra_value_r = writeback_exec2_value_i;
    if (pipe2_rd_e1_w == issue_a_rb_idx_w) issue_a_rb_value_r = writeback_exec2_value_i;
    if (pipe3_rd_e1_w == issue_a_ra_idx_w) issue_a_ra_value_r = writeback_exec3_value_i;
    if (pipe3_rd_e1_w == issue_a_rb_idx_w) issue_a_rb_value_r = writeback_exec3_value_i;
    // Reg 0 source
    if (issue_a_ra_idx_w == 5'b0) issue_a_ra_value_r = 32'b0;
    if (issue_a_rb_idx_w == 5'b0) issue_a_rb_value_r = 32'b0;
end
assign opcode0_ra_operand_o = issue_a_ra_value_r;
assign opcode0_rb_operand_o = issue_a_rb_value_r;

//-------------------------------------------------------------
// Issue Slot 1 (B) Bypass
//------------------------------------------------------------- 
assign opcode1_opcode_o = opcode_b_r;
assign opcode1_pc_o     = opcode_b_pc_r;
assign opcode1_rd_idx_o = issue_b_rd_idx_w;
assign opcode1_ra_idx_o = issue_b_ra_idx_w;
assign opcode1_rb_idx_o = issue_b_rb_idx_w;
assign opcode1_invalid_o= 1'b0;

reg [31:0] issue_b_ra_value_r;
reg [31:0] issue_b_rb_value_r;
always @ *
begin
    issue_b_ra_value_r = issue_b_ra_value_w;
    issue_b_rb_value_r = issue_b_rb_value_w;
    // Bypass - WB
    if (pipe0_rd_wb_w == issue_b_ra_idx_w) issue_b_ra_value_r = pipe0_result_wb_w;
    if (pipe0_rd_wb_w == issue_b_rb_idx_w) issue_b_rb_value_r = pipe0_result_wb_w;
    if (pipe1_rd_wb_w == issue_b_ra_idx_w) issue_b_ra_value_r = pipe1_result_wb_w;
    if (pipe1_rd_wb_w == issue_b_rb_idx_w) issue_b_rb_value_r = pipe1_result_wb_w;
    if (pipe2_rd_wb_w == issue_b_ra_idx_w) issue_b_ra_value_r = pipe2_result_wb_w;
    if (pipe2_rd_wb_w == issue_b_rb_idx_w) issue_b_rb_value_r = pipe2_result_wb_w;
    if (pipe3_rd_wb_w == issue_b_ra_idx_w) issue_b_ra_value_r = pipe3_result_wb_w;
    if (pipe3_rd_wb_w == issue_b_rb_idx_w) issue_b_rb_value_r = pipe3_result_wb_w;
    // Bypass - E2
    if (pipe0_rd_e2_w == issue_b_ra_idx_w) issue_b_ra_value_r = pipe0_result_e2_w;
    if (pipe0_rd_e2_w == issue_b_rb_idx_w) issue_b_rb_value_r = pipe0_result_e2_w;
    if (pipe1_rd_e2_w == issue_b_ra_idx_w) issue_b_ra_value_r = pipe1_result_e2_w;
    if (pipe1_rd_e2_w == issue_b_rb_idx_w) issue_b_rb_value_r = pipe1_result_e2_w;
    if (pipe2_rd_e2_w == issue_b_ra_idx_w) issue_b_ra_value_r = pipe2_result_e2_w;
    if (pipe2_rd_e2_w == issue_b_rb_idx_w) issue_b_rb_value_r = pipe2_result_e2_w;
    if (pipe3_rd_e2_w == issue_b_ra_idx_w) issue_b_ra_value_r = pipe3_result_e2_w;
    if (pipe3_rd_e2_w == issue_b_rb_idx_w) issue_b_rb_value_r = pipe3_result_e2_w;
    // Bypass - E1
    if (pipe0_rd_e1_w == issue_b_ra_idx_w) issue_b_ra_value_r = writeback_exec0_value_i;
    if (pipe0_rd_e1_w == issue_b_rb_idx_w) issue_b_rb_value_r = writeback_exec0_value_i;
    if (pipe1_rd_e1_w == issue_b_ra_idx_w) issue_b_ra_value_r = writeback_exec1_value_i;
    if (pipe1_rd_e1_w == issue_b_rb_idx_w) issue_b_rb_value_r = writeback_exec1_value_i;
    if (pipe2_rd_e1_w == issue_b_ra_idx_w) issue_b_ra_value_r = writeback_exec2_value_i;
    if (pipe2_rd_e1_w == issue_b_rb_idx_w) issue_b_rb_value_r = writeback_exec2_value_i;
    if (pipe3_rd_e1_w == issue_b_ra_idx_w) issue_b_ra_value_r = writeback_exec3_value_i;
    if (pipe3_rd_e1_w == issue_b_rb_idx_w) issue_b_rb_value_r = writeback_exec3_value_i;
    // Reg 0 source
    if (issue_b_ra_idx_w == 5'b0) issue_b_ra_value_r = 32'b0;
    if (issue_b_rb_idx_w == 5'b0) issue_b_rb_value_r = 32'b0;
end
assign opcode1_ra_operand_o = issue_b_ra_value_r;
assign opcode1_rb_operand_o = issue_b_rb_value_r;

//-------------------------------------------------------------
// Issue Slot 2 (C) Bypass
//------------------------------------------------------------- 
assign opcode2_opcode_o = opcode_c_r;
assign opcode2_pc_o     = opcode_c_pc_r;
assign opcode2_rd_idx_o = issue_c_rd_idx_w;
assign opcode2_ra_idx_o = issue_c_ra_idx_w;
assign opcode2_rb_idx_o = issue_c_rb_idx_w;
assign opcode2_invalid_o= 1'b0;

reg [31:0] issue_c_ra_value_r;
reg [31:0] issue_c_rb_value_r;
always @ *
begin
    issue_c_ra_value_r = issue_c_ra_value_w;
    issue_c_rb_value_r = issue_c_rb_value_w;
    // Bypass - WB
    if (pipe0_rd_wb_w == issue_c_ra_idx_w) issue_c_ra_value_r = pipe0_result_wb_w;
    if (pipe0_rd_wb_w == issue_c_rb_idx_w) issue_c_rb_value_r = pipe0_result_wb_w;
    if (pipe1_rd_wb_w == issue_c_ra_idx_w) issue_c_ra_value_r = pipe1_result_wb_w;
    if (pipe1_rd_wb_w == issue_c_rb_idx_w) issue_c_rb_value_r = pipe1_result_wb_w;
    if (pipe2_rd_wb_w == issue_c_ra_idx_w) issue_c_ra_value_r = pipe2_result_wb_w;
    if (pipe2_rd_wb_w == issue_c_rb_idx_w) issue_c_rb_value_r = pipe2_result_wb_w;
    if (pipe3_rd_wb_w == issue_c_ra_idx_w) issue_c_ra_value_r = pipe3_result_wb_w;
    if (pipe3_rd_wb_w == issue_c_rb_idx_w) issue_c_rb_value_r = pipe3_result_wb_w;
    // Bypass - E2
    if (pipe0_rd_e2_w == issue_c_ra_idx_w) issue_c_ra_value_r = pipe0_result_e2_w;
    if (pipe0_rd_e2_w == issue_c_rb_idx_w) issue_c_rb_value_r = pipe0_result_e2_w;
    if (pipe1_rd_e2_w == issue_c_ra_idx_w) issue_c_ra_value_r = pipe1_result_e2_w;
    if (pipe1_rd_e2_w == issue_c_rb_idx_w) issue_c_rb_value_r = pipe1_result_e2_w;
    if (pipe2_rd_e2_w == issue_c_ra_idx_w) issue_c_ra_value_r = pipe2_result_e2_w;
    if (pipe2_rd_e2_w == issue_c_rb_idx_w) issue_c_rb_value_r = pipe2_result_e2_w;
    if (pipe3_rd_e2_w == issue_c_ra_idx_w) issue_c_ra_value_r = pipe3_result_e2_w;
    if (pipe3_rd_e2_w == issue_c_rb_idx_w) issue_c_rb_value_r = pipe3_result_e2_w;
    // Bypass - E1
    if (pipe0_rd_e1_w == issue_c_ra_idx_w) issue_c_ra_value_r = writeback_exec0_value_i;
    if (pipe0_rd_e1_w == issue_c_rb_idx_w) issue_c_rb_value_r = writeback_exec0_value_i;
    if (pipe1_rd_e1_w == issue_c_ra_idx_w) issue_c_ra_value_r = writeback_exec1_value_i;
    if (pipe1_rd_e1_w == issue_c_rb_idx_w) issue_c_rb_value_r = writeback_exec1_value_i;
    if (pipe2_rd_e1_w == issue_c_ra_idx_w) issue_c_ra_value_r = writeback_exec2_value_i;
    if (pipe2_rd_e1_w == issue_c_rb_idx_w) issue_c_rb_value_r = writeback_exec2_value_i;
    if (pipe3_rd_e1_w == issue_c_ra_idx_w) issue_c_ra_value_r = writeback_exec3_value_i;
    if (pipe3_rd_e1_w == issue_c_rb_idx_w) issue_c_rb_value_r = writeback_exec3_value_i;
    // Reg 0 source
    if (issue_c_ra_idx_w == 5'b0) issue_c_ra_value_r = 32'b0;
    if (issue_c_rb_idx_w == 5'b0) issue_c_rb_value_r = 32'b0;
end
assign opcode2_ra_operand_o = issue_c_ra_value_r;
assign opcode2_rb_operand_o = issue_c_rb_value_r;

//-------------------------------------------------------------
// Issue Slot 3 (D) Bypass
//------------------------------------------------------------- 
assign opcode3_opcode_o = opcode_d_r;
assign opcode3_pc_o     = opcode_d_pc_r;
assign opcode3_rd_idx_o = issue_d_rd_idx_w;
assign opcode3_ra_idx_o = issue_d_ra_idx_w;
assign opcode3_rb_idx_o = issue_d_rb_idx_w;
assign opcode3_invalid_o= 1'b0;

reg [31:0] issue_d_ra_value_r;
reg [31:0] issue_d_rb_value_r;
always @ *
begin
    issue_d_ra_value_r = issue_d_ra_value_w;
    issue_d_rb_value_r = issue_d_rb_value_w;
    // Bypass - WB
    if (pipe0_rd_wb_w == issue_d_ra_idx_w) issue_d_ra_value_r = pipe0_result_wb_w;
    if (pipe0_rd_wb_w == issue_d_rb_idx_w) issue_d_rb_value_r = pipe0_result_wb_w;
    if (pipe1_rd_wb_w == issue_d_ra_idx_w) issue_d_ra_value_r = pipe1_result_wb_w;
    if (pipe1_rd_wb_w == issue_d_rb_idx_w) issue_d_rb_value_r = pipe1_result_wb_w;
    if (pipe2_rd_wb_w == issue_d_ra_idx_w) issue_d_ra_value_r = pipe2_result_wb_w;
    if (pipe2_rd_wb_w == issue_d_rb_idx_w) issue_d_rb_value_r = pipe2_result_wb_w;
    if (pipe3_rd_wb_w == issue_d_ra_idx_w) issue_d_ra_value_r = pipe3_result_wb_w;
    if (pipe3_rd_wb_w == issue_d_rb_idx_w) issue_d_rb_value_r = pipe3_result_wb_w;
    // Bypass - E2
    if (pipe0_rd_e2_w == issue_d_ra_idx_w) issue_d_ra_value_r = pipe0_result_e2_w;
    if (pipe0_rd_e2_w == issue_d_rb_idx_w) issue_d_rb_value_r = pipe0_result_e2_w;
    if (pipe1_rd_e2_w == issue_d_ra_idx_w) issue_d_ra_value_r = pipe1_result_e2_w;
    if (pipe1_rd_e2_w == issue_d_rb_idx_w) issue_d_rb_value_r = pipe1_result_e2_w;
    if (pipe2_rd_e2_w == issue_d_ra_idx_w) issue_d_ra_value_r = pipe2_result_e2_w;
    if (pipe2_rd_e2_w == issue_d_rb_idx_w) issue_d_rb_value_r = pipe2_result_e2_w;
    if (pipe3_rd_e2_w == issue_d_ra_idx_w) issue_d_ra_value_r = pipe3_result_e2_w;
    if (pipe3_rd_e2_w == issue_d_rb_idx_w) issue_d_rb_value_r = pipe3_result_e2_w;
    // Bypass - E1
    if (pipe0_rd_e1_w == issue_d_ra_idx_w) issue_d_ra_value_r = writeback_exec0_value_i;
    if (pipe0_rd_e1_w == issue_d_rb_idx_w) issue_d_rb_value_r = writeback_exec0_value_i;
    if (pipe1_rd_e1_w == issue_d_ra_idx_w) issue_d_ra_value_r = writeback_exec1_value_i;
    if (pipe1_rd_e1_w == issue_d_rb_idx_w) issue_d_rb_value_r = writeback_exec1_value_i;
    if (pipe2_rd_e1_w == issue_d_ra_idx_w) issue_d_ra_value_r = writeback_exec2_value_i;
    if (pipe2_rd_e1_w == issue_d_rb_idx_w) issue_d_rb_value_r = writeback_exec2_value_i;
    if (pipe3_rd_e1_w == issue_d_ra_idx_w) issue_d_ra_value_r = writeback_exec3_value_i;
    if (pipe3_rd_e1_w == issue_d_rb_idx_w) issue_d_rb_value_r = writeback_exec3_value_i;
    // Reg 0 source
    if (issue_d_ra_idx_w == 5'b0) issue_d_ra_value_r = 32'b0;
    if (issue_d_rb_idx_w == 5'b0) issue_d_rb_value_r = 32'b0;
end
assign opcode3_ra_operand_o = issue_d_ra_value_r;
assign opcode3_rb_operand_o = issue_d_rb_value_r;

//-------------------------------------------------------------
// Load store unit
//-------------------------------------------------------------
assign lsu_opcode_opcode_o      = (pipe_mux_lsu_r == 2'd0) ? opcode0_opcode_o : (pipe_mux_lsu_r == 2'd1) ? opcode1_opcode_o : (pipe_mux_lsu_r == 2'd2) ? opcode2_opcode_o : opcode3_opcode_o;
assign lsu_opcode_pc_o          = (pipe_mux_lsu_r == 2'd0) ? opcode0_pc_o     : (pipe_mux_lsu_r == 2'd1) ? opcode1_pc_o     : (pipe_mux_lsu_r == 2'd2) ? opcode2_pc_o     : opcode3_pc_o;
assign lsu_opcode_rd_idx_o      = (pipe_mux_lsu_r == 2'd0) ? opcode0_rd_idx_o : (pipe_mux_lsu_r == 2'd1) ? opcode1_rd_idx_o : (pipe_mux_lsu_r == 2'd2) ? opcode2_rd_idx_o : opcode3_rd_idx_o;
assign lsu_opcode_ra_idx_o      = (pipe_mux_lsu_r == 2'd0) ? opcode0_ra_idx_o : (pipe_mux_lsu_r == 2'd1) ? opcode1_ra_idx_o : (pipe_mux_lsu_r == 2'd2) ? opcode2_ra_idx_o : opcode3_ra_idx_o;
assign lsu_opcode_rb_idx_o      = (pipe_mux_lsu_r == 2'd0) ? opcode0_rb_idx_o : (pipe_mux_lsu_r == 2'd1) ? opcode1_rb_idx_o : (pipe_mux_lsu_r == 2'd2) ? opcode2_rb_idx_o : opcode3_rb_idx_o;
assign lsu_opcode_ra_operand_o  = (pipe_mux_lsu_r == 2'd0) ? opcode0_ra_operand_o : (pipe_mux_lsu_r == 2'd1) ? opcode1_ra_operand_o : (pipe_mux_lsu_r == 2'd2) ? opcode2_ra_operand_o : opcode3_ra_operand_o;
assign lsu_opcode_rb_operand_o  = (pipe_mux_lsu_r == 2'd0) ? opcode0_rb_operand_o : (pipe_mux_lsu_r == 2'd1) ? opcode1_rb_operand_o : (pipe_mux_lsu_r == 2'd2) ? opcode2_rb_operand_o : opcode3_rb_operand_o;
assign lsu_opcode_invalid_o     = 1'b0;

//-------------------------------------------------------------
// Multiply
//-------------------------------------------------------------
assign mul_opcode_opcode_o      = (pipe_mux_mul_r == 2'd0) ? opcode0_opcode_o : (pipe_mux_mul_r == 2'd1) ? opcode1_opcode_o : (pipe_mux_mul_r == 2'd2) ? opcode2_opcode_o : opcode3_opcode_o;
assign mul_opcode_pc_o          = (pipe_mux_mul_r == 2'd0) ? opcode0_pc_o     : (pipe_mux_mul_r == 2'd1) ? opcode1_pc_o     : (pipe_mux_mul_r == 2'd2) ? opcode2_pc_o     : opcode3_pc_o;
assign mul_opcode_rd_idx_o      = (pipe_mux_mul_r == 2'd0) ? opcode0_rd_idx_o : (pipe_mux_mul_r == 2'd1) ? opcode1_rd_idx_o : (pipe_mux_mul_r == 2'd2) ? opcode2_rd_idx_o : opcode3_rd_idx_o;
assign mul_opcode_ra_idx_o      = (pipe_mux_mul_r == 2'd0) ? opcode0_ra_idx_o : (pipe_mux_mul_r == 2'd1) ? opcode1_ra_idx_o : (pipe_mux_mul_r == 2'd2) ? opcode2_ra_idx_o : opcode3_ra_idx_o;
assign mul_opcode_rb_idx_o      = (pipe_mux_mul_r == 2'd0) ? opcode0_rb_idx_o : (pipe_mux_mul_r == 2'd1) ? opcode1_rb_idx_o : (pipe_mux_mul_r == 2'd2) ? opcode2_rb_idx_o : opcode3_rb_idx_o;
assign mul_opcode_ra_operand_o  = (pipe_mux_mul_r == 2'd0) ? opcode0_ra_operand_o : (pipe_mux_mul_r == 2'd1) ? opcode1_ra_operand_o : (pipe_mux_mul_r == 2'd2) ? opcode2_ra_operand_o : opcode3_ra_operand_o;
assign mul_opcode_rb_operand_o  = (pipe_mux_mul_r == 2'd0) ? opcode0_rb_operand_o : (pipe_mux_mul_r == 2'd1) ? opcode1_rb_operand_o : (pipe_mux_mul_r == 2'd2) ? opcode2_rb_operand_o : opcode3_rb_operand_o;
assign mul_opcode_invalid_o     = 1'b0;

//-------------------------------------------------------------
// CSR unit
//-------------------------------------------------------------
assign csr_opcode_valid_o       = opcode_a_issue_r & ~take_interrupt_i;
assign csr_opcode_opcode_o      = opcode0_opcode_o;
assign csr_opcode_pc_o          = opcode0_pc_o;
assign csr_opcode_rd_idx_o      = opcode0_rd_idx_o;
assign csr_opcode_ra_idx_o      = opcode0_ra_idx_o;
assign csr_opcode_rb_idx_o      = opcode0_rb_idx_o;
assign csr_opcode_ra_operand_o  = opcode0_ra_operand_o;
assign csr_opcode_rb_operand_o  = opcode0_rb_operand_o;
assign csr_opcode_invalid_o     = opcode_a_issue_r && issue_a_invalid_w;

//-------------------------------------------------------------
// Checker Interface
//-------------------------------------------------------------
`ifdef verilator
trace_sim
u_pipe0_dec0_verif
(
    .valid_i(pipe0_valid_wb_w),
    .pc_i(pipe0_pc_wb_w),
    .opcode_i(pipe0_opc_wb_w)
);
wire [4:0] v_pipe0_rs1_w = pipe0_opc_wb_w[19:15];
wire [4:0] v_pipe0_rs2_w = pipe0_opc_wb_w[24:20];

function [0:0] complete_valid0; /*verilator public*/
begin
    complete_valid0 = pipe0_valid_wb_w;
end
endfunction
function [31:0] complete_pc0; /*verilator public*/
begin
    complete_pc0 = pipe0_pc_wb_w;
end
endfunction
function [31:0] complete_opcode0; /*verilator public*/
begin
    complete_opcode0 = pipe0_opc_wb_w;
end
endfunction
function [4:0] complete_ra0; /*verilator public*/
begin
    complete_ra0 = v_pipe0_rs1_w;
end
endfunction
function [4:0] complete_rb0; /*verilator public*/
begin
    complete_rb0 = v_pipe0_rs2_w;
end
endfunction
function [4:0] complete_rd0; /*verilator public*/
begin
    complete_rd0 = pipe0_rd_wb_w;
end
endfunction
function [31:0] complete_ra_val0; /*verilator public*/
begin
    complete_ra_val0 = pipe0_ra_val_wb_w;
end
endfunction
function [31:0] complete_rb_val0; /*verilator public*/
begin
    complete_rb_val0 = pipe0_rb_val_wb_w;
end
endfunction
function [31:0] complete_rd_val0; /*verilator public*/
begin
    if (|pipe0_rd_wb_w)
        complete_rd_val0 = pipe0_result_wb_w;
    else
        complete_rd_val0 = 32'b0;
end
endfunction

trace_sim
u_pipe0_dec1_verif
(
    .valid_i(pipe1_valid_wb_w),
    .pc_i(pipe1_pc_wb_w),
    .opcode_i(pipe1_opc_wb_w)
);

wire [4:0] v_pipe1_rs1_w = pipe1_opc_wb_w[19:15];
wire [4:0] v_pipe1_rs2_w = pipe1_opc_wb_w[24:20];

function [0:0] complete_valid1; /*verilator public*/
begin
    complete_valid1 = pipe1_valid_wb_w;
end
endfunction
function [31:0] complete_pc1; /*verilator public*/
begin
    complete_pc1 = pipe1_pc_wb_w;
end
endfunction
function [31:0] complete_opcode1; /*verilator public*/
begin
    complete_opcode1 = pipe1_opc_wb_w;
end
endfunction
function [4:0] complete_ra1; /*verilator public*/
begin
    complete_ra1 = v_pipe1_rs1_w;
end
endfunction
function [4:0] complete_rb1; /*verilator public*/
begin
    complete_rb1 = v_pipe1_rs2_w;
end
endfunction
function [4:0] complete_rd1; /*verilator public*/
begin
    complete_rd1 = pipe1_rd_wb_w;
end
endfunction
function [31:0] complete_ra_val1; /*verilator public*/
begin
    complete_ra_val1 = pipe1_ra_val_wb_w;
end
endfunction
function [31:0] complete_rb_val1; /*verilator public*/
begin
    complete_rb_val1 = pipe1_rb_val_wb_w;
end
endfunction
function [31:0] complete_rd_val1; /*verilator public*/
begin
    if (|pipe1_rd_wb_w)
        complete_rd_val1 = pipe1_result_wb_w;
    else
        complete_rd_val1 = 32'b0;
end
endfunction

// Pipe 2 Verif
trace_sim
u_pipe0_dec2_verif
(
    .valid_i(pipe2_valid_wb_w),
    .pc_i(pipe2_pc_wb_w),
    .opcode_i(pipe2_opc_wb_w)
);
wire [4:0] v_pipe2_rs1_w = pipe2_opc_wb_w[19:15];
wire [4:0] v_pipe2_rs2_w = pipe2_opc_wb_w[24:20];
function [0:0] complete_valid2; /*verilator public*/ begin complete_valid2 = pipe2_valid_wb_w; end endfunction
function [31:0] complete_pc2; /*verilator public*/ begin complete_pc2 = pipe2_pc_wb_w; end endfunction
function [31:0] complete_opcode2; /*verilator public*/ begin complete_opcode2 = pipe2_opc_wb_w; end endfunction
function [4:0] complete_ra2; /*verilator public*/ begin complete_ra2 = v_pipe2_rs1_w; end endfunction
function [4:0] complete_rb2; /*verilator public*/ begin complete_rb2 = v_pipe2_rs2_w; end endfunction
function [4:0] complete_rd2; /*verilator public*/ begin complete_rd2 = pipe2_rd_wb_w; end endfunction
function [31:0] complete_ra_val2; /*verilator public*/ begin complete_ra_val2 = pipe2_ra_val_wb_w; end endfunction
function [31:0] complete_rb_val2; /*verilator public*/ begin complete_rb_val2 = pipe2_rb_val_wb_w; end endfunction
function [31:0] complete_rd_val2; /*verilator public*/ begin
    if (|pipe2_rd_wb_w) complete_rd_val2 = pipe2_result_wb_w;
    else complete_rd_val2 = 32'b0;
end endfunction

// Pipe 3 Verif
trace_sim
u_pipe0_dec3_verif
(
    .valid_i(pipe3_valid_wb_w),
    .pc_i(pipe3_pc_wb_w),
    .opcode_i(pipe3_opc_wb_w)
);
wire [4:0] v_pipe3_rs1_w = pipe3_opc_wb_w[19:15];
wire [4:0] v_pipe3_rs2_w = pipe3_opc_wb_w[24:20];
function [0:0] complete_valid3; /*verilator public*/ begin complete_valid3 = pipe3_valid_wb_w; end endfunction
function [31:0] complete_pc3; /*verilator public*/ begin complete_pc3 = pipe3_pc_wb_w; end endfunction
function [31:0] complete_opcode3; /*verilator public*/ begin complete_opcode3 = pipe3_opc_wb_w; end endfunction
function [4:0] complete_ra3; /*verilator public*/ begin complete_ra3 = v_pipe3_rs1_w; end endfunction
function [4:0] complete_rb3; /*verilator public*/ begin complete_rb3 = v_pipe3_rs2_w; end endfunction
function [4:0] complete_rd3; /*verilator public*/ begin complete_rd3 = pipe3_rd_wb_w; end endfunction
function [31:0] complete_ra_val3; /*verilator public*/ begin complete_ra_val3 = pipe3_ra_val_wb_w; end endfunction
function [31:0] complete_rb_val3; /*verilator public*/ begin complete_rb_val3 = pipe3_rb_val_wb_w; end endfunction
function [31:0] complete_rd_val3; /*verilator public*/ begin
    if (|pipe3_rd_wb_w) complete_rd_val3 = pipe3_result_wb_w;
    else complete_rd_val3 = 32'b0;
end endfunction

function [5:0] complete_exception;
/*verilator public*/
begin
    complete_exception = pipe0_exception_wb_w | pipe1_exception_wb_w | pipe2_exception_wb_w | pipe3_exception_wb_w;
end
endfunction
`endif
endmodule