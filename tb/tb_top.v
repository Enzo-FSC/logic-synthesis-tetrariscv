`timescale 1ns / 1ps

// -----------------------------------------------------------------------------
// Módulo de Memória TCM
// Funcionalidade: Carrega .bin, suporta Fetch 128-bit e Acesso de Dados 32-bit
// -----------------------------------------------------------------------------
module tcm_mem(
    input           clk_i,
    input           rst_i,

    // Interface de Instrução (Fetch - 128 bits)
    input           mem_i_rd_i,
    input           mem_i_flush_i,
    input           mem_i_invalidate_i,
    input  [31:0]   mem_i_pc_i,

    // Interface de Dados (LSU - 32 bits)
    input  [31:0]   mem_d_addr_i,
    input  [31:0]   mem_d_data_wr_i,
    input           mem_d_rd_i,
    input  [ 3:0]   mem_d_wr_i,
    input           mem_d_cacheable_i,
    input  [10:0]   mem_d_req_tag_i,
    input           mem_d_invalidate_i,
    input           mem_d_writeback_i,
    input           mem_d_flush_i,

    // Outputs
    output          mem_i_accept_o,
    output          mem_i_valid_o,
    output          mem_i_error_o,
    output [127:0]  mem_i_inst_o,
    output [31:0]   mem_d_data_rd_o,
    output          mem_d_accept_o,
    output          mem_d_ack_o,
    output          mem_d_error_o,
    output [10:0]   mem_d_resp_tag_o
);
    reg [31:0] memory [0:16383];
    reg [7:0]  bin_buffer [0:65535]; 

    integer fd, count, k;
    wire [13:0] d_idx = mem_d_addr_i[15:2];
    wire [13:0] i_idx = mem_i_pc_i[15:2];

    assign mem_i_accept_o   = 1'b1;
    assign mem_i_valid_o    = 1'b1;
    assign mem_i_error_o    = 1'b0;
    
    assign mem_d_accept_o   = 1'b1;
    assign mem_d_ack_o      = 1'b1;
    assign mem_d_error_o    = 1'b0;
    assign mem_d_resp_tag_o = mem_d_req_tag_i;
    reg [127:0] r_inst_data;
    reg [31:0]  r_data_rd;

    reg [255*8:1] firmware_file;

    initial begin
        for (k = 0; k < 16384; k = k + 1) memory[k] = 32'h00000000;
        if (!$value$plusargs("FIRMWARE=%s", firmware_file)) begin
            firmware_file = "C:/intelFPGA/bubblesort.bin";
        end

        $display("Carregando binario: %s", firmware_file);
        fd = $fopen(firmware_file, "rb");
        if (fd == 0) begin
            $display("ERRO: Nao foi possivel abrir o arquivo .bin");
            $finish;
        end

        count = $fread(bin_buffer, fd);
        $fclose(fd);
        $display("Lidos %0d bytes.", count);
        for (k = 0; k < count; k = k + 4) begin
            memory[k/4] = {bin_buffer[k+3], bin_buffer[k+2], bin_buffer[k+1], bin_buffer[k]};
        end
    end

    always @(posedge clk_i) begin
        if (|mem_d_wr_i) begin
            memory[d_idx] <= mem_d_data_wr_i;
            $display("[MEM WRITE] PC: %08x | Addr: %08x | Data: %d (0x%08x)", 
                     mem_i_pc_i, mem_d_addr_i, $signed(mem_d_data_wr_i), mem_d_data_wr_i);
        end

        r_data_rd <= memory[d_idx];
        r_inst_data <= {
            memory[i_idx + 3],
            memory[i_idx + 2],
            memory[i_idx + 1],
            memory[i_idx]
        };
    end

    assign mem_d_data_rd_o = r_data_rd;
    assign mem_i_inst_o    = r_inst_data;
endmodule

// -----------------------------------------------------------------------------
// Testbench
// -----------------------------------------------------------------------------
module tb_top;
    `define TRACE_SIMULATION
    reg clk;
    reg rst_n;
    wire          mem_i_rd_w;
    wire          mem_i_flush_w;
    wire          mem_i_invalidate_w;
    wire [ 31:0]  mem_i_pc_w;
    wire [ 31:0]  mem_d_addr_w;
    wire [ 31:0]  mem_d_data_wr_w;
    wire          mem_d_rd_w;
    wire [  3:0]  mem_d_wr_w;
    wire          mem_d_cacheable_w;
    wire [ 10:0]  mem_d_req_tag_w;
    wire          mem_d_invalidate_w;
    wire          mem_d_writeback_w;
    wire          mem_d_flush_w;
    wire          mem_i_accept_w;
    wire          mem_i_valid_w;
    wire          mem_i_error_w;
    wire [127:0]  mem_i_inst_w;
    wire [ 31:0]  mem_d_data_rd_w;
    wire          mem_d_accept_w;
    wire          mem_d_ack_w;
    wire          mem_d_error_w;
    wire [ 10:0]  mem_d_resp_tag_w;
    reg [31:0] reset_vector_r;

    // -------------------------------------------------------------------------
    // Setup e Reset
    // -------------------------------------------------------------------------
    initial begin
        $display("-------------------------------------------------------------");
        $display("BENCHMARK START: 4-Issue RISC-V with Binary Loader");
        $display("-------------------------------------------------------------");

        if (!$value$plusargs("RESET_VECTOR=%h", reset_vector_r)) begin
            reset_vector_r = 32'h80000054;
        end
        $display("RESET VECTOR: 0x%08x", reset_vector_r);

        `ifdef TRACE_SIMULATION
            $dumpfile("waveform.vcd");
            $dumpvars(0, tb_top);
        `endif

        clk = 0;
        rst_n = 0;
        repeat (20) @(posedge clk);
        rst_n = 1;
        #500000;
        $display("ERRO: Timeout da simulacao.");
        $finish;
    end

    // Clock gen
    initial begin
        forever #5 clk = ~clk;
    end

    // -------------------------------------------------------------------------
    // DUT (RISC-V Core)
    // -------------------------------------------------------------------------
    core #(
        .SUPPORT_MMU(0),
        .EXTRA_DECODE_STAGE(1)
    ) u_dut (
        .clk(clk),
        .rst_n(rst_n),
        .mem_d_data_rd_i(mem_d_data_rd_w),
        .mem_d_accept_i(mem_d_accept_w),
        .mem_d_ack_i(mem_d_ack_w),
        .mem_d_error_i(mem_d_error_w),
        .mem_d_resp_tag_i(mem_d_resp_tag_w),
        .mem_i_accept_i(mem_i_accept_w),
        .mem_i_valid_i(mem_i_valid_w),
        .mem_i_error_i(mem_i_error_w),
        .mem_i_inst_i(mem_i_inst_w),
        .intr_i(1'b0),
        .reset_vector_i(reset_vector_r), 
        .cpu_id_i('b0),
        .mem_d_addr_o(mem_d_addr_w),
        .mem_d_data_wr_o(mem_d_data_wr_w),
        .mem_d_rd_o(mem_d_rd_w),
        .mem_d_wr_o(mem_d_wr_w),
        .mem_d_cacheable_o(mem_d_cacheable_w),
        .mem_d_req_tag_o(mem_d_req_tag_w),
        .mem_d_invalidate_o(mem_d_invalidate_w),
        .mem_d_writeback_o(mem_d_writeback_w),
        .mem_d_flush_o(mem_d_flush_w),
        .mem_i_rd_o(mem_i_rd_w),
        .mem_i_flush_o(mem_i_flush_w),
        .mem_i_invalidate_o(mem_i_invalidate_w),
        .mem_i_pc_o(mem_i_pc_w)
    );
    // -------------------------------------------------------------------------
    // Memória Instanciada
    // -------------------------------------------------------------------------
    tcm_mem u_mem (
        .clk_i(clk),
        .rst_i(!rst_n),
        .mem_i_rd_i(mem_i_rd_w),
        .mem_i_flush_i(mem_i_flush_w),
        .mem_i_invalidate_i(mem_i_invalidate_w),
        .mem_i_pc_i(mem_i_pc_w),
        .mem_d_addr_i(mem_d_addr_w),
        .mem_d_data_wr_i(mem_d_data_wr_w),
        .mem_d_rd_i(mem_d_rd_w),
        .mem_d_wr_i(mem_d_wr_w),
        .mem_d_cacheable_i(mem_d_cacheable_w),
        .mem_d_req_tag_i(mem_d_req_tag_w),
        .mem_d_invalidate_i(mem_d_invalidate_w),
        .mem_d_writeback_i(mem_d_writeback_w),
        .mem_d_flush_i(mem_d_flush_w),
        .mem_i_accept_o(mem_i_accept_w),
        .mem_i_valid_o(mem_i_valid_w),
        .mem_i_error_o(mem_i_error_w),
        .mem_i_inst_o(mem_i_inst_w),
        .mem_d_data_rd_o(mem_d_data_rd_w),
        .mem_d_accept_o(mem_d_accept_w),
        .mem_d_ack_o(mem_d_ack_w),
        .mem_d_error_o(mem_d_error_w),
        .mem_d_resp_tag_o(mem_d_resp_tag_w)
    );
endmodule