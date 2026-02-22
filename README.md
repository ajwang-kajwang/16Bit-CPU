# 16-Bit Soft-Core Microcontroller

This repository contains the VHDL implementation of a custom 16-bit multi-cycle soft-core processor. The system features a custom Instruction Set Architecture (ISA), a centralized routing bus, memory-mapped I/O, and peripheral drivers for 7-segment displays and LEDs.

This project is designed to be synthesized and run on Intel/Altera Cyclone series FPGAs, specifically targeting the DE0 and DE10 development boards.

## Prerequisites

- **Intel Quartus Prime** (Lite Edition is sufficient for Cyclone IV/V).
    
- **Target Hardware:** Terasic DE0 (Cyclone III/IV) or DE10 (Cyclone V) development board.
    
- **USB Blaster Cable** for FPGA programming.
    

## Structure

- `microcontroller.vhd`: The top-level system wrapper containing the CPU, Memory, and I/O.
    
- `CPU.vhd`: The main microprocessor core.
    
- `ctrl_unit.vhd`: The FSM handling instruction fetch, decode, and execution.
    
- `Buses.vhd`: Centralized multiplexed datapath routing.
    
- `ALU.vhd` / `Register.vhd` / `pc_unit.vhd`: Core datapath components.
    
- `intel_rom.vhd` / `ram.vhd`: Memory components.
    
- `rom_file.mif`: Memory Initialization File containing the assembled machine code.
    
- `seg_output.vhd`: Driver for the 7-segment displays.
    
- `microcontroller_tb.vhd`: Testbench for simulation.
    
