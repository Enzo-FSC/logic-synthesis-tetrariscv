module tcm_mem
(
    // Inputs
     input           clk_i
    ,input           rst_i
    ,input           mem_i_rd_i
    ,input           mem_i_flush_i
    ,input           mem_i_invalidate_i
    ,input  [ 31:0]  mem_i_pc_i
    ,input  [ 31:0]  mem_d_addr_i
    ,input  [ 31:0]  mem_d_data_wr_i
    ,input           mem_d_rd_i
    ,input  [  3:0]  mem_d_wr_i
    ,input           mem_d_cacheable_i
    ,input  [ 10:0]  mem_d_req_tag_i
    ,input           mem_d_invalidate_i
    ,input           mem_d_writeback_i
    ,input           mem_d_flush_i

    // Outputs
    ,output          mem_i_accept_o
    ,output          mem_i_valid_o
    ,output          mem_i_error_o
    ,output [127:0]  mem_i_inst_o
    ,output [ 31:0]  mem_d_data_rd_o
    ,output          mem_d_accept_o
    ,output          mem_d_ack_o
    ,output          mem_d_error_o
    ,output [ 10:0]  mem_d_resp_tag_o
);
//-------------------------------------------------------------
// Dual Port RAM
//-------------------------------------------------------------
wire [1:0]   word_sel_w   = mem_d_addr_i[3:2];
wire [127:0] data_r_w;

// Expand write data to all slots
wire [127:0] data_w_expanded = {mem_d_data_wr_i, mem_d_data_wr_i, mem_d_data_wr_i, mem_d_data_wr_i};

// Generate write mask based on address
reg [15:0] wr_mask_w;
always @* begin
    case (word_sel_w)
        2'b00: wr_mask_w = {12'b0, mem_d_wr_i};
        2'b01: wr_mask_w = {8'b0, mem_d_wr_i, 4'b0};
        2'b10: wr_mask_w = {4'b0, mem_d_wr_i, 8'b0};
        2'b11: wr_mask_w = {mem_d_wr_i, 12'b0};
    endcase
end

tcm_mem_ram
u_ram
(
    // Instruction fetch
     .clk0_i(clk_i)
    ,.rst0_i(rst_i)
    ,.addr0_i(mem_i_pc_i[16:4])
    ,.data0_i(128'b0)
    ,.wr0_i(16'b0)

    // External access / Data access
    ,.clk1_i(clk_i)
    ,.rst1_i(rst_i)
    ,.addr1_i(mem_d_addr_i[16:4])
    ,.data1_i(data_w_expanded)
    ,.wr1_i(wr_mask_w)

    // Outputs
    ,.data0_o(mem_i_inst_o)
    ,.data1_o(data_r_w)
);
reg [1:0] word_sel_q;

always @ (posedge clk_i )
if (rst_i)
    word_sel_q <= 2'b0;
else
    word_sel_q <= word_sel_w;

//-------------------------------------------------------------
// Instruction Fetch
//-------------------------------------------------------------
reg        mem_i_valid_q;
always @ (posedge clk_i )
if (rst_i)
    mem_i_valid_q <= 1'b0;
else
    mem_i_valid_q <= mem_i_rd_i;

assign mem_i_accept_o  = 1'b1;
assign mem_i_valid_o   = mem_i_valid_q;
assign mem_i_error_o   = 1'b0;
//-------------------------------------------------------------
// Data Access / Incoming external access
//-------------------------------------------------------------
reg        mem_d_accept_q;
reg        mem_d_ack_q;
reg [10:0] mem_d_tag_q;

always @ (posedge clk_i )
if (rst_i)
begin
    mem_d_ack_q    <= 1'b0;
    mem_d_tag_q    <= 11'b0;
end
else if ((mem_d_rd_i || mem_d_wr_i != 4'b0 || mem_d_flush_i || mem_d_invalidate_i || mem_d_writeback_i) && mem_d_accept_o)
begin
    mem_d_ack_q    <= 1'b1;
    mem_d_tag_q    <= mem_d_req_tag_i;
end
else
    mem_d_ack_q    <= 1'b0;

assign mem_d_ack_o          = mem_d_ack_q;
assign mem_d_resp_tag_o     = mem_d_tag_q;

// Read Data Mux
reg [31:0] rdata_mux;
always @* begin
    case (word_sel_q)
        2'b00: rdata_mux = data_r_w[31:0];
        2'b01: rdata_mux = data_r_w[63:32];
        2'b10: rdata_mux = data_r_w[95:64];
        2'b11: rdata_mux = data_r_w[127:96];
    endcase
end
assign mem_d_data_rd_o      = rdata_mux;

assign mem_d_error_o        = 1'b0;
assign mem_d_accept_o       = 1'b1;

//-------------------------------------------------------------
// write: Write byte into memory
//-------------------------------------------------------------
task write;
/*verilator public*/
    input [31:0] addr;
    input [7:0]  data;
begin
    case (addr[3:0])
    4'd0:  u_ram.ram[addr/16][7:0]    = data;
    4'd1:  u_ram.ram[addr/16][15:8]   = data;
    4'd2:  u_ram.ram[addr/16][23:16]  = data;
    4'd3:  u_ram.ram[addr/16][31:24]  = data;
    4'd4:  u_ram.ram[addr/16][39:32]  = data;
    4'd5:  u_ram.ram[addr/16][47:40]  = data;
    4'd6:  u_ram.ram[addr/16][55:48]  = data;
    4'd7:  u_ram.ram[addr/16][63:56]  = data;
    4'd8:  u_ram.ram[addr/16][71:64]  = data;
    4'd9:  u_ram.ram[addr/16][79:72]  = data;
    4'd10: u_ram.ram[addr/16][87:80]  = data;
    4'd11: u_ram.ram[addr/16][95:88]  = data;
    4'd12: u_ram.ram[addr/16][103:96] = data;
    4'd13: u_ram.ram[addr/16][111:104]= data;
    4'd14: u_ram.ram[addr/16][119:112]= data;
    4'd15: u_ram.ram[addr/16][127:120]= data;
    endcase
end
endtask

endmodule