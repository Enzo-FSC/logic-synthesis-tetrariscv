`include "defs.v"

module mmu
//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
#(
    parameter SUPPORT_MMU        = 1,
    parameter MEM_CACHE_ADDR_MIN = 32'h80000000,
    parameter MEM_CACHE_ADDR_MAX = 32'h8fffffff
)
//-----------------------------------------------------------------
// Ports
//-----------------------------------------------------------------
(
    // Inputs
    input           clk_i,
    input           rst_i,
    input  [ 1:0]   priv_d_i,
    input           sum_i,
    input           mxr_i,
    input           flush_i,
    input  [31:0]   satp_i,

    // Instruction Fetch Interface (Input from Frontend)
    input           fetch_in_rd_i,
    input           fetch_in_flush_i,
    input           fetch_in_invalidate_i,
    input  [31:0]   fetch_in_pc_i,
    input  [ 1:0]   fetch_in_priv_i,

    // Instruction Fetch Interface (Output to Memory/Cache - 128-bit)
    input           fetch_out_accept_i,
    input           fetch_out_valid_i,
    input           fetch_out_error_i,
    input [127:0]   fetch_out_inst_i, // CORREÇÃO: 64 -> 128 bits

    // LSU Interface (Input from LSU)
    input  [31:0]   lsu_in_addr_i,
    input  [31:0]   lsu_in_data_wr_i,
    input           lsu_in_rd_i,
    input  [ 3:0]   lsu_in_wr_i,
    input           lsu_in_cacheable_i,
    input  [10:0]   lsu_in_req_tag_i,
    input           lsu_in_invalidate_i,
    input           lsu_in_writeback_i,
    input           lsu_in_flush_i,

    // LSU Interface (Output to Memory/Cache)
    input  [31:0]   lsu_out_data_rd_i,
    input           lsu_out_accept_i,
    input           lsu_out_ack_i,
    input           lsu_out_error_i,
    input  [10:0]   lsu_out_resp_tag_i,

    // Outputs (To Frontend)
    output          fetch_in_accept_o,
    output          fetch_in_valid_o,
    output          fetch_in_error_o,
    output [127:0]  fetch_in_inst_o, // CORREÇÃO: 64 -> 128 bits
    output          fetch_in_fault_o,

    // Outputs (To Memory/Cache)
    output          fetch_out_rd_o,
    output          fetch_out_flush_o,
    output          fetch_out_invalidate_o,
    output [31:0]   fetch_out_pc_o,

    // Outputs (To LSU)
    output [31:0]   lsu_in_data_rd_o,
    output          lsu_in_accept_o,
    output          lsu_in_ack_o,
    output          lsu_in_error_o,
    output [10:0]   lsu_in_resp_tag_o,
    output          lsu_in_load_fault_o,
    output          lsu_in_store_fault_o,

    // Outputs (To Memory/Cache)
    output [31:0]   lsu_out_addr_o,
    output [31:0]   lsu_out_data_wr_o,
    output          lsu_out_rd_o,
    output [ 3:0]   lsu_out_wr_o,
    output          lsu_out_cacheable_o,
    output [10:0]   lsu_out_req_tag_o,
    output          lsu_out_invalidate_o,
    output          lsu_out_writeback_o,
    output          lsu_out_flush_o
);

    //-----------------------------------------------------------------
    // Simple Pass-through Implementation (No MMU or Disabled)
    //-----------------------------------------------------------------
    // Se você não estiver usando tradução virtual (SV32), a MMU apenas
    // repassa os sinais diretamente.
    
    // Instruction Path
    assign fetch_out_rd_o         = fetch_in_rd_i;
    assign fetch_out_flush_o      = fetch_in_flush_i;
    assign fetch_out_invalidate_o = fetch_in_invalidate_i;
    assign fetch_out_pc_o         = fetch_in_pc_i;

    assign fetch_in_accept_o      = fetch_out_accept_i;
    assign fetch_in_valid_o       = fetch_out_valid_i;
    assign fetch_in_error_o       = fetch_out_error_i;
    assign fetch_in_inst_o        = fetch_out_inst_i; // 128 bits pass-through
    assign fetch_in_fault_o       = 1'b0; // No page fault

    // LSU Path
    assign lsu_out_addr_o         = lsu_in_addr_i;
    assign lsu_out_data_wr_o      = lsu_in_data_wr_i;
    assign lsu_out_rd_o           = lsu_in_rd_i;
    assign lsu_out_wr_o           = lsu_in_wr_i;
    assign lsu_out_cacheable_o    = lsu_in_cacheable_i;
    assign lsu_out_req_tag_o      = lsu_in_req_tag_i;
    assign lsu_out_invalidate_o   = lsu_in_invalidate_i;
    assign lsu_out_writeback_o    = lsu_in_writeback_i;
    assign lsu_out_flush_o        = lsu_in_flush_i;

    assign lsu_in_data_rd_o       = lsu_out_data_rd_i;
    assign lsu_in_accept_o        = lsu_out_accept_i;
    assign lsu_in_ack_o           = lsu_out_ack_i;
    assign lsu_in_error_o         = lsu_out_error_i;
    assign lsu_in_resp_tag_o      = lsu_out_resp_tag_i;
    assign lsu_in_load_fault_o    = 1'b0;
    assign lsu_in_store_fault_o   = 1'b0;

endmodule