<div align="center"> <h1> Computer Organization and Architecture III  </h1>
</div>

This project is part of the Computer Organization and Architecture III (2025.2) course. The objective of the project was to modify the http://github.com/ultraembedded/biriscv to implement a 32-bit superscalar four-issue fetch in-order RISC-V core, run logic synthesis using GPDK45, and perform a gate-level simulation.


1. [biRISC-V](#biriscv)
2. [Logic Synthesis](#logic-synthesis)
3. [Generating Applications](#generating-applications)
4. [Gate Level Simulation](#gate-level-simulation)

<hr />

## TetraRISC-V <a name="biriscv"></a>

biRISC-V is a 32-bit dual issue RISC-V CPU made by [Ultraembedded](http://github.com/ultraembedded).


![biRISC-V](docs/TetraRISCV.png)

### Features
* 32-bit RISC-V ISA CPU core.
* Superscalar (four-issue fetch) in-order 7 stage pipeline.
* Support RISC-V’s integer (I), multiplication and division (M), and CSR instructions (Z) extensions (RV32IMZicsr).
* Branch prediction (bimodel/gshare) with configurable depth branch target buffer (BTB) and return address stack (RAS).
* 128-bit instruction fetch, 32-bit data access.
* 2 x integer ALU (arithmetic, shifters and branch units).
* 1 x load store unit, 1 x out-of-pipeline divider.
* Fetch and decode up to 4 independent instructions per cycle.
* Issue and complete up to 2 independent instructions per cycle.
* Supports user, supervisor and machine mode privilege levels.
* Basic MMU support - capable of booting Linux with atomics (RV-A) SW emulation.
* Implements base ISA spec [v2.1](docs/riscv_isa_spec.pdf) and privileged ISA spec [v1.11](docs/riscv_privileged_spec.pdf).
* Verified using [Google's RISCV-DV](https://github.com/google/riscv-dv) random instruction sequences using cosimulation against [C++ ISA model](https://github.com/ultraembedded/exactstep).
* Support for instruction / data cache, AXI bus interfaces or tightly coupled memories.
* Configurable number of pipeline stages, result forwarding options, and branch prediction resources.
* Synthesizable Verilog 2001, Verilator and FPGA friendly.

*A sequence showing execution of 2 instructions per cycle;*
![Dual-Issue](docs/dual_issue.png)

## Logic Synthesis <a name="logic-synthesis"></a>

The synsthesis was performed with <i> Cadence RTL Compiler</i> , the execution scripts and the PDK (IBM 180) were provided by professor Mateus Beck.

The core modules that must be included in the synthesis filelist are:

```
src
│   
│
└───core
    │ defs.v
    │ alu.v
    │ csr_regfile.v
    │ csr.v
    │ decoder.v
    │ decode.v
    │ divider.v
    │ exec.v
    │ fetch.v
    │ frontend.v
    │ issue.v
    │ lsu.v
    │ mmu.v
    │ multiplier.v
    │ npc.v
    │ pipe_ctrl.v
    │ regfile.v
    │ trace_sim.v
    │ xilinx_2r1w.v
    │ core.v
```

The non-synthesizable testbench modules are:

```
tb
   └───tb_core_icarus
        │   tcm_mem_ram.v
        │   tcm_mem.v
        │   biriscv_trace_sim_gls.sv
        │   tb_top.v
    
```

## Generating Applications <a name="generating-applications"></a>

On `riscv-app-gen` you can find some risc-v applications (C, bin, elf) in the subdirectories. Also, you can generate your own program file by executing the `make` command specifying the C code e.g `make SRC=main.c`. 

You must have [riscv-gnu-toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain) installed with Linux multilib and available in your `PATH` environment variable.

The linker script `riscv-app-gen/link.ld` was obtained from [Google's RISCV-DV](https://github.com/google/riscv-dv).

The entry point specified in the linker command is the main function, therefore, you must check the entry point address code with the comand `make info` e.g `make info ELF=main.elf`. This entry point is required to execute the testbench and need to be passed to the `reset_vector_i` input in `src/riscv_core.v` .


## Gate Level Simulation <a name="gate-level-simulation"></a>

Post-synthesis Simulation using Cadence SimVision. Bubble sort execution.

![Dual-Issue](docs/gls_sim_vision_bubble.png)