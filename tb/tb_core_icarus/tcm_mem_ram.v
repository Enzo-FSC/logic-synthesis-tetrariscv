module tcm_mem_ram
(
    // Inputs
     input           clk0_i
    ,input           rst0_i
    ,input  [ 12:0]  addr0_i
    ,input  [127:0]  data0_i
    ,input  [ 15:0]  wr0_i
    ,input           clk1_i
    ,input           rst1_i
    ,input  [ 12:0]  addr1_i
    ,input  [127:0]  data1_i
    ,input  [ 15:0]  wr1_i

    // Outputs
    ,output [127:0]  data0_o
    ,output [127:0]  data1_o
);
//-----------------------------------------------------------------
// Dual Port RAM 128KB
// Mode: Read First
//-----------------------------------------------------------------
/* verilator lint_off MULTIDRIVEN */
reg [127:0]   ram [8191:0] /*verilator public*/;
/* verilator lint_on MULTIDRIVEN */

reg [127:0] ram_read0_q;
reg [127:0] ram_read1_q;
// Synchronous write
always @ (posedge clk0_i)
begin
    if (wr0_i[0])
        ram[addr0_i][7:0] <= data0_i[7:0];
    if (wr0_i[1])
        ram[addr0_i][15:8] <= data0_i[15:8];
    if (wr0_i[2])
        ram[addr0_i][23:16] <= data0_i[23:16];
    if (wr0_i[3])
        ram[addr0_i][31:24] <= data0_i[31:24];
    if (wr0_i[4])
        ram[addr0_i][39:32] <= data0_i[39:32];
    if (wr0_i[5])
        ram[addr0_i][47:40] <= data0_i[47:40];
    if (wr0_i[6])
        ram[addr0_i][55:48] <= data0_i[55:48];
    if (wr0_i[7])
        ram[addr0_i][63:56] <= data0_i[63:56];
    if (wr0_i[8])
        ram[addr0_i][71:64] <= data0_i[71:64];
    if (wr0_i[9])
        ram[addr0_i][79:72] <= data0_i[79:72];
    if (wr0_i[10])
        ram[addr0_i][87:80] <= data0_i[87:80];
    if (wr0_i[11])
        ram[addr0_i][95:88] <= data0_i[95:88];
    if (wr0_i[12])
        ram[addr0_i][103:96] <= data0_i[103:96];
    if (wr0_i[13])
        ram[addr0_i][111:104] <= data0_i[111:104];
    if (wr0_i[14])
        ram[addr0_i][119:112] <= data0_i[119:112];
    if (wr0_i[15])
        ram[addr0_i][127:120] <= data0_i[127:120];

    ram_read0_q <= ram[addr0_i];
end

always @ (posedge clk1_i)
begin
    if (wr1_i[0])
        ram[addr1_i][7:0] <= data1_i[7:0];
    if (wr1_i[1])
        ram[addr1_i][15:8] <= data1_i[15:8];
    if (wr1_i[2])
        ram[addr1_i][23:16] <= data1_i[23:16];
    if (wr1_i[3])
        ram[addr1_i][31:24] <= data1_i[31:24];
    if (wr1_i[4])
        ram[addr1_i][39:32] <= data1_i[39:32];
    if (wr1_i[5])
        ram[addr1_i][47:40] <= data1_i[47:40];
    if (wr1_i[6])
        ram[addr1_i][55:48] <= data1_i[55:48];
    if (wr1_i[7])
        ram[addr1_i][63:56] <= data1_i[63:56];
    if (wr1_i[8])
        ram[addr1_i][71:64] <= data1_i[71:64];
    if (wr1_i[9])
        ram[addr1_i][79:72] <= data1_i[79:72];
    if (wr1_i[10])
        ram[addr1_i][87:80] <= data1_i[87:80];
    if (wr1_i[11])
        ram[addr1_i][95:88] <= data1_i[95:88];
    if (wr1_i[12])
        ram[addr1_i][103:96] <= data1_i[103:96];
    if (wr1_i[13])
        ram[addr1_i][111:104] <= data1_i[111:104];
    if (wr1_i[14])
        ram[addr1_i][119:112] <= data1_i[119:112];
    if (wr1_i[15])
        ram[addr1_i][127:120] <= data1_i[127:120];

    ram_read1_q <= ram[addr1_i];
end

assign data0_o = ram_read0_q;
assign data1_o = ram_read1_q;

endmodule