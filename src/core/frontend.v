`include "defs.v"

module frontend
//-----------------------------------------------------------------
// Params
//-----------------------------------------------------------------
#(
    parameter SUPPORT_BRANCH_PREDICTION = 1,
    parameter SUPPORT_MULDIV            = 1,
    parameter SUPPORT_MMU               = 1,
    parameter EXTRA_DECODE_STAGE        = 0,
    parameter NUM_BTB_ENTRIES           = 32,
    parameter NUM_BTB_ENTRIES_W         = 5,
    parameter NUM_BHT_ENTRIES           = 512,
    parameter NUM_BHT_ENTRIES_W         = 9,
    parameter RAS_ENABLE                = 1,
    parameter GSHARE_ENABLE             = 0,
    parameter BHT_ENABLE                = 1,
    parameter NUM_RAS_ENTRIES           = 8,
    parameter NUM_RAS_ENTRIES_W         = 3
)
//-----------------------------------------------------------------
// Ports
//-----------------------------------------------------------------
(
    // Inputs
    input           clk_i,
    input           rst_i,
    input           icache_accept_i,
    input           icache_valid_i,
    input           icache_error_i,
    input  [127:0]  icache_inst_i,
    input           icache_page_fault_i,
    input           fetch0_accept_i,
    input           fetch1_accept_i,
    input           fetch2_accept_i,
    input           fetch3_accept_i,
    input           fetch_invalidate_i,
    input           branch_request_i,
    input  [31:0]   branch_pc_i,
    input  [1:0]    branch_priv_i,
    input           branch_info_request_i,
    input           branch_info_is_taken_i,
    input           branch_info_is_not_taken_i,
    input  [31:0]   branch_info_source_i,
    input           branch_info_is_call_i,
    input           branch_info_is_ret_i,
    input           branch_info_is_jmp_i,
    input  [31:0]   branch_info_pc_i,

    // Outputs
    output          icache_rd_o,
    output          icache_flush_o,
    output          icache_invalidate_o,
    output [31:0]   icache_pc_o,
    output [1:0]    icache_priv_o,
    output          fetch0_valid_o,
    output [31:0]   fetch0_instr_o,
    output [31:0]   fetch0_pc_o,
    output          fetch0_fault_fetch_o,
    output          fetch0_fault_page_o,
    output          fetch0_instr_exec_o,
    output          fetch0_instr_lsu_o,
    output          fetch0_instr_branch_o,
    output          fetch0_instr_mul_o,
    output          fetch0_instr_div_o,
    output          fetch0_instr_csr_o,
    output          fetch0_instr_rd_valid_o,
    output          fetch0_instr_invalid_o,
    output          fetch1_valid_o,
    output [31:0]   fetch1_instr_o,
    output [31:0]   fetch1_pc_o,
    output          fetch1_fault_fetch_o,
    output          fetch1_fault_page_o,
    output          fetch1_instr_exec_o,
    output          fetch1_instr_lsu_o,
    output          fetch1_instr_branch_o,
    output          fetch1_instr_mul_o,
    output          fetch1_instr_div_o,
    output          fetch1_instr_csr_o,
    output          fetch1_instr_rd_valid_o,
    output          fetch1_instr_invalid_o,
    output          fetch2_valid_o,
    output [31:0]   fetch2_instr_o,
    output [31:0]   fetch2_pc_o,
    output          fetch2_fault_fetch_o,
    output          fetch2_fault_page_o,
    output          fetch2_instr_exec_o,
    output          fetch2_instr_lsu_o,
    output          fetch2_instr_branch_o,
    output          fetch2_instr_mul_o,
    output          fetch2_instr_div_o,
    output          fetch2_instr_csr_o,
    output          fetch2_instr_rd_valid_o,
    output          fetch2_instr_invalid_o,
    output          fetch3_valid_o,
    output [31:0]   fetch3_instr_o,
    output [31:0]   fetch3_pc_o,
    output          fetch3_fault_fetch_o,
    output          fetch3_fault_page_o,
    output          fetch3_instr_exec_o,
    output          fetch3_instr_lsu_o,
    output          fetch3_instr_branch_o,
    output          fetch3_instr_mul_o,
    output          fetch3_instr_div_o,
    output          fetch3_instr_csr_o,
    output          fetch3_instr_rd_valid_o,
    output          fetch3_instr_invalid_o
);
    wire            fetch_valid_w;
    wire [127:0]    fetch_instr_w;
    wire            fetch_fault_page_w;
    wire [31:0]     next_pc_f_w;
    wire [3:0]      next_taken_f_w;
    wire [31:0]     fetch_pc_f_w;
    wire            fetch_accept_w;
    wire [3:0]      fetch_pred_branch_w;
    wire [31:0]     fetch_pc_w;
    wire            fetch_fault_fetch_w;
    wire            fetch_pc_accept_w;

    npc
    #(
        .NUM_BTB_ENTRIES(NUM_BTB_ENTRIES),
        .SUPPORT_BRANCH_PREDICTION(SUPPORT_BRANCH_PREDICTION),
        .GSHARE_ENABLE(GSHARE_ENABLE),
        .NUM_RAS_ENTRIES_W(NUM_RAS_ENTRIES_W),
        .NUM_BHT_ENTRIES_W(NUM_BHT_ENTRIES_W),
        .BHT_ENABLE(BHT_ENABLE),
        .NUM_BTB_ENTRIES_W(NUM_BTB_ENTRIES_W),
        .NUM_BHT_ENTRIES(NUM_BHT_ENTRIES),
        .RAS_ENABLE(RAS_ENABLE),
        .NUM_RAS_ENTRIES(NUM_RAS_ENTRIES)
    )
    u_npc
    (
        // Inputs
        .clk_i(clk_i),
        .rst_i(rst_i),
        .invalidate_i(1'b0),
        .branch_request_i(branch_info_request_i),
        .branch_is_taken_i(branch_info_is_taken_i),
        .branch_is_not_taken_i(branch_info_is_not_taken_i),
        .branch_source_i(branch_info_source_i),
        .branch_is_call_i(branch_info_is_call_i),
        .branch_is_ret_i(branch_info_is_ret_i),
        .branch_is_jmp_i(branch_info_is_jmp_i),
        .branch_pc_i(branch_info_pc_i),
        .pc_f_i(fetch_pc_f_w),
        .pc_accept_i(fetch_pc_accept_w),

        // Outputs
        .next_pc_f_o(next_pc_f_w),
        .next_taken_f_o(next_taken_f_w)
    );

    //-----------------------------------------------------------------
    // Internal signals to capture Decoder output (pre-alignment)
    //-----------------------------------------------------------------
    wire        dec0_valid_w;
    wire [31:0] dec0_instr_w;
    wire [31:0] dec0_pc_w;
    wire        dec0_fault_fetch_w;
    wire        dec0_fault_page_w;
    wire        dec0_instr_exec_w;
    wire        dec0_instr_lsu_w;
    wire        dec0_instr_branch_w;
    wire        dec0_instr_mul_w;
    wire        dec0_instr_div_w;
    wire        dec0_instr_csr_w;
    wire        dec0_instr_rd_valid_w;
    wire        dec0_instr_invalid_w;
    wire        dec0_accept_w;

    wire        dec1_valid_w;
    wire [31:0] dec1_instr_w;
    wire [31:0] dec1_pc_w;
    wire        dec1_fault_fetch_w;
    wire        dec1_fault_page_w;
    wire        dec1_instr_exec_w;
    wire        dec1_instr_lsu_w;
    wire        dec1_instr_branch_w;
    wire        dec1_instr_mul_w;
    wire        dec1_instr_div_w;
    wire        dec1_instr_csr_w;
    wire        dec1_instr_rd_valid_w;
    wire        dec1_instr_invalid_w;
    wire        dec1_accept_w;

    wire        dec2_valid_w;
    wire [31:0] dec2_instr_w;
    wire [31:0] dec2_pc_w;
    wire        dec2_fault_fetch_w;
    wire        dec2_fault_page_w;
    wire        dec2_instr_exec_w;
    wire        dec2_instr_lsu_w;
    wire        dec2_instr_branch_w;
    wire        dec2_instr_mul_w;
    wire        dec2_instr_div_w;
    wire        dec2_instr_csr_w;
    wire        dec2_instr_rd_valid_w;
    wire        dec2_instr_invalid_w;
    wire        dec2_accept_w;

    wire        dec3_valid_w;
    wire [31:0] dec3_instr_w;
    wire [31:0] dec3_pc_w;
    wire        dec3_fault_fetch_w;
    wire        dec3_fault_page_w;
    wire        dec3_instr_exec_w;
    wire        dec3_instr_lsu_w;
    wire        dec3_instr_branch_w;
    wire        dec3_instr_mul_w;
    wire        dec3_instr_div_w;
    wire        dec3_instr_csr_w;
    wire        dec3_instr_rd_valid_w;
    wire        dec3_instr_invalid_w;
    wire        dec3_accept_w;

    decode
    #(
        .EXTRA_DECODE_STAGE(EXTRA_DECODE_STAGE),
        .SUPPORT_MULDIV(SUPPORT_MULDIV)
    )
    u_decode
    (
        // Inputs
        .clk_i(clk_i),
        .rst_i(rst_i),
        .fetch_in_valid_i(fetch_valid_w),
        .fetch_in_instr_i(fetch_instr_w),
        .fetch_in_pred_branch_i(fetch_pred_branch_w),
        .fetch_in_fault_fetch_i(fetch_fault_fetch_w),
        .fetch_in_fault_page_i(fetch_fault_page_w),
        .fetch_in_pc_i(fetch_pc_w),
        
        // Connect accepts to internal aligner logic instead of external inputs
        .fetch_out0_accept_i(dec0_accept_w),
        .fetch_out1_accept_i(dec1_accept_w),
        .fetch_out2_accept_i(dec2_accept_w),
        .fetch_out3_accept_i(dec3_accept_w),
        
        .branch_request_i(branch_request_i),
        .branch_pc_i(branch_pc_i),
        .branch_priv_i(branch_priv_i),

        // Outputs (to internal wires)
        .fetch_in_accept_o(fetch_accept_w),
        
        .fetch_out0_valid_o(dec0_valid_w),
        .fetch_out0_instr_o(dec0_instr_w),
        .fetch_out0_pc_o(dec0_pc_w),
        .fetch_out0_fault_fetch_o(dec0_fault_fetch_w),
        .fetch_out0_fault_page_o(dec0_fault_page_w),
        .fetch_out0_instr_exec_o(dec0_instr_exec_w),
        .fetch_out0_instr_lsu_o(dec0_instr_lsu_w),
        .fetch_out0_instr_branch_o(dec0_instr_branch_w),
        .fetch_out0_instr_mul_o(dec0_instr_mul_w),
        .fetch_out0_instr_div_o(dec0_instr_div_w),
        .fetch_out0_instr_csr_o(dec0_instr_csr_w),
        .fetch_out0_instr_rd_valid_o(dec0_instr_rd_valid_w),
        .fetch_out0_instr_invalid_o(dec0_instr_invalid_w),

        .fetch_out1_valid_o(dec1_valid_w),
        .fetch_out1_instr_o(dec1_instr_w),
        .fetch_out1_pc_o(dec1_pc_w),
        .fetch_out1_fault_fetch_o(dec1_fault_fetch_w),
        .fetch_out1_fault_page_o(dec1_fault_page_w),
        .fetch_out1_instr_exec_o(dec1_instr_exec_w),
        .fetch_out1_instr_lsu_o(dec1_instr_lsu_w),
        .fetch_out1_instr_branch_o(dec1_instr_branch_w),
        .fetch_out1_instr_mul_o(dec1_instr_mul_w),
        .fetch_out1_instr_div_o(dec1_instr_div_w),
        .fetch_out1_instr_csr_o(dec1_instr_csr_w),
        .fetch_out1_instr_rd_valid_o(dec1_instr_rd_valid_w),
        .fetch_out1_instr_invalid_o(dec1_instr_invalid_w),

        .fetch_out2_valid_o(dec2_valid_w),
        .fetch_out2_instr_o(dec2_instr_w),
        .fetch_out2_pc_o(dec2_pc_w),
        .fetch_out2_fault_fetch_o(dec2_fault_fetch_w),
        .fetch_out2_fault_page_o(dec2_fault_page_w),
        .fetch_out2_instr_exec_o(dec2_instr_exec_w),
        .fetch_out2_instr_lsu_o(dec2_instr_lsu_w),
        .fetch_out2_instr_branch_o(dec2_instr_branch_w),
        .fetch_out2_instr_mul_o(dec2_instr_mul_w),
        .fetch_out2_instr_div_o(dec2_instr_div_w),
        .fetch_out2_instr_csr_o(dec2_instr_csr_w),
        .fetch_out2_instr_rd_valid_o(dec2_instr_rd_valid_w),
        .fetch_out2_instr_invalid_o(dec2_instr_invalid_w),

        .fetch_out3_valid_o(dec3_valid_w),
        .fetch_out3_instr_o(dec3_instr_w),
        .fetch_out3_pc_o(dec3_pc_w),
        .fetch_out3_fault_fetch_o(dec3_fault_fetch_w),
        .fetch_out3_fault_page_o(dec3_fault_page_w),
        .fetch_out3_instr_exec_o(dec3_instr_exec_w),
        .fetch_out3_instr_lsu_o(dec3_instr_lsu_w),
        .fetch_out3_instr_branch_o(dec3_instr_branch_w),
        .fetch_out3_instr_mul_o(dec3_instr_mul_w),
        .fetch_out3_instr_div_o(dec3_instr_div_w),
        .fetch_out3_instr_csr_o(dec3_instr_csr_w),
        .fetch_out3_instr_rd_valid_o(dec3_instr_rd_valid_w),
        .fetch_out3_instr_invalid_o(dec3_instr_invalid_w)
    );

    //-----------------------------------------------------------------
    // Aligner / Collapsing Logic (Funnel 4 -> 2)
    //-----------------------------------------------------------------
    
    // Grouping payloads for easy muxing
    // Payload width: 32+32+1+1+1+1+1+1+1+1+1+1 = 74 bits
    wire [73:0] payload0_w = {dec0_instr_w, dec0_pc_w, dec0_fault_fetch_w, dec0_fault_page_w, dec0_instr_exec_w, dec0_instr_lsu_w, dec0_instr_branch_w, dec0_instr_mul_w, dec0_instr_div_w, dec0_instr_csr_w, dec0_instr_rd_valid_w, dec0_instr_invalid_w};
    wire [73:0] payload1_w = {dec1_instr_w, dec1_pc_w, dec1_fault_fetch_w, dec1_fault_page_w, dec1_instr_exec_w, dec1_instr_lsu_w, dec1_instr_branch_w, dec1_instr_mul_w, dec1_instr_div_w, dec1_instr_csr_w, dec1_instr_rd_valid_w, dec1_instr_invalid_w};
    wire [73:0] payload2_w = {dec2_instr_w, dec2_pc_w, dec2_fault_fetch_w, dec2_fault_page_w, dec2_instr_exec_w, dec2_instr_lsu_w, dec2_instr_branch_w, dec2_instr_mul_w, dec2_instr_div_w, dec2_instr_csr_w, dec2_instr_rd_valid_w, dec2_instr_invalid_w};
    wire [73:0] payload3_w = {dec3_instr_w, dec3_pc_w, dec3_fault_fetch_w, dec3_fault_page_w, dec3_instr_exec_w, dec3_instr_lsu_w, dec3_instr_branch_w, dec3_instr_mul_w, dec3_instr_div_w, dec3_instr_csr_w, dec3_instr_rd_valid_w, dec3_instr_invalid_w};

    // Selection Logic for Output Port 0 (First valid instruction)
    reg [1:0] sel0_r;
    reg       val0_r;
    always @* begin
        if (dec0_valid_w) begin
            sel0_r = 2'd0; val0_r = 1'b1;
        end else if (dec1_valid_w) begin
            sel0_r = 2'd1; val0_r = 1'b1;
        end else if (dec2_valid_w) begin
            sel0_r = 2'd2; val0_r = 1'b1;
        end else if (dec3_valid_w) begin
            sel0_r = 2'd3; val0_r = 1'b1;
        end else begin
            sel0_r = 2'd0; val0_r = 1'b0;
        end
    end

    // Selection Logic for Output Port 1 (Second valid instruction)
    reg [1:0] sel1_r;
    reg       val1_r;
    always @* begin
        sel1_r = 2'd0;
        val1_r = 1'b0;
        case (sel0_r)
            2'd0: begin // Used Slot 0, search 1..3
                if (dec1_valid_w)      begin sel1_r = 2'd1; val1_r = 1'b1; end
                else if (dec2_valid_w) begin sel1_r = 2'd2; val1_r = 1'b1; end
                else if (dec3_valid_w) begin sel1_r = 2'd3; val1_r = 1'b1; end
            end
            2'd1: begin // Used Slot 1, search 2..3
                if (dec2_valid_w)      begin sel1_r = 2'd2; val1_r = 1'b1; end
                else if (dec3_valid_w) begin sel1_r = 2'd3; val1_r = 1'b1; end
            end
            2'd2: begin // Used Slot 2, search 3
                if (dec3_valid_w)      begin sel1_r = 2'd3; val1_r = 1'b1; end
            end
            2'd3: begin // Used Slot 3, none left
                val1_r = 1'b0;
            end
        endcase
        // If output 0 was invalid, output 1 must be invalid too
        if (!val0_r) val1_r = 1'b0; 
    end

    // Muxing Payload for Outputs
    reg [73:0] mux_out0;
    reg [73:0] mux_out1;
    
    always @* begin
        case (sel0_r)
            2'd0: mux_out0 = payload0_w;
            2'd1: mux_out0 = payload1_w;
            2'd2: mux_out0 = payload2_w;
            2'd3: mux_out0 = payload3_w;
        endcase
    end

    always @* begin
        case (sel1_r)
            2'd0: mux_out1 = payload0_w;
            2'd1: mux_out1 = payload1_w;
            2'd2: mux_out1 = payload2_w;
            2'd3: mux_out1 = payload3_w;
        endcase
    end

    // Back-pressure / Accept Routing
    // Decoder accepts if it was selected and the output port accepted
    assign dec0_accept_w = (val0_r && (sel0_r == 2'd0) && fetch0_accept_i) | (val1_r && (sel1_r == 2'd0) && fetch1_accept_i);
    assign dec1_accept_w = (val0_r && (sel0_r == 2'd1) && fetch0_accept_i) | (val1_r && (sel1_r == 2'd1) && fetch1_accept_i);
    assign dec2_accept_w = (val0_r && (sel0_r == 2'd2) && fetch0_accept_i) | (val1_r && (sel1_r == 2'd2) && fetch1_accept_i);
    assign dec3_accept_w = (val0_r && (sel0_r == 2'd3) && fetch0_accept_i) | (val1_r && (sel1_r == 2'd3) && fetch1_accept_i);

    // Assigning Outputs 0 (Mapped from first valid slot)
    assign fetch0_valid_o = val0_r;
    assign {fetch0_instr_o, fetch0_pc_o, fetch0_fault_fetch_o, fetch0_fault_page_o, fetch0_instr_exec_o, fetch0_instr_lsu_o, fetch0_instr_branch_o, fetch0_instr_mul_o, fetch0_instr_div_o, fetch0_instr_csr_o, fetch0_instr_rd_valid_o, fetch0_instr_invalid_o} = mux_out0;

    // Assigning Outputs 1 (Mapped from second valid slot)
    assign fetch1_valid_o = val1_r;
    assign {fetch1_instr_o, fetch1_pc_o, fetch1_fault_fetch_o, fetch1_fault_page_o, fetch1_instr_exec_o, fetch1_instr_lsu_o, fetch1_instr_branch_o, fetch1_instr_mul_o, fetch1_instr_div_o, fetch1_instr_csr_o, fetch1_instr_rd_valid_o, fetch1_instr_invalid_o} = mux_out1;

    // Assigning Outputs 2 and 3 (Disabled / Zeroed to enforce funneling to 2-issue)
    assign fetch2_valid_o = 1'b0;
    assign fetch2_instr_o = 32'b0;
    assign fetch2_pc_o = 32'b0;
    assign fetch2_fault_fetch_o = 1'b0;
    assign fetch2_fault_page_o = 1'b0;
    assign fetch2_instr_exec_o = 1'b0;
    assign fetch2_instr_lsu_o = 1'b0;
    assign fetch2_instr_branch_o = 1'b0;
    assign fetch2_instr_mul_o = 1'b0;
    assign fetch2_instr_div_o = 1'b0;
    assign fetch2_instr_csr_o = 1'b0;
    assign fetch2_instr_rd_valid_o = 1'b0;
    assign fetch2_instr_invalid_o = 1'b0;

    assign fetch3_valid_o = 1'b0;
    assign fetch3_instr_o = 32'b0;
    assign fetch3_pc_o = 32'b0;
    assign fetch3_fault_fetch_o = 1'b0;
    assign fetch3_fault_page_o = 1'b0;
    assign fetch3_instr_exec_o = 1'b0;
    assign fetch3_instr_lsu_o = 1'b0;
    assign fetch3_instr_branch_o = 1'b0;
    assign fetch3_instr_mul_o = 1'b0;
    assign fetch3_instr_div_o = 1'b0;
    assign fetch3_instr_csr_o = 1'b0;
    assign fetch3_instr_rd_valid_o = 1'b0;
    assign fetch3_instr_invalid_o = 1'b0;

    fetch
    #(
        .SUPPORT_MMU(SUPPORT_MMU)
    )
    u_fetch
    (
        // Inputs
        .clk_i(clk_i),
        .rst_i(rst_i),
        .fetch_accept_i(fetch_accept_w),
        .icache_accept_i(icache_accept_i),
        .icache_valid_i(icache_valid_i),
        .icache_error_i(icache_error_i),
        .icache_inst_i(icache_inst_i),
        .icache_page_fault_i(icache_page_fault_i),
        .fetch_invalidate_i(fetch_invalidate_i),
        .branch_request_i(branch_request_i),
        .branch_pc_i(branch_pc_i),
        .branch_priv_i(branch_priv_i),
        .next_pc_f_i(next_pc_f_w),
        .next_taken_f_i(next_taken_f_w),

        // Outputs
        .fetch_valid_o(fetch_valid_w),
        .fetch_instr_o(fetch_instr_w),
        .fetch_pred_branch_o(fetch_pred_branch_w),
        .fetch_fault_fetch_o(fetch_fault_fetch_w),
        .fetch_fault_page_o(fetch_fault_page_w),
        .fetch_pc_o(fetch_pc_w),
        .icache_rd_o(icache_rd_o),
        .icache_flush_o(icache_flush_o),
        .icache_invalidate_o(icache_invalidate_o),
        .icache_pc_o(icache_pc_o),
        .icache_priv_o(icache_priv_o),
        .pc_f_o(fetch_pc_f_w),
        .pc_accept_o(fetch_pc_accept_w)
    );
endmodule