# Lab 2 — Combinatorial Logic

## Goal

Design and implement basic combinational logic structures in VHDL, including a
2-to-4 decoder, simple multiplexing, and logic gate–based functions, without
using sequential logic or processes.

## Hardware / Tools

- PYNQ-Z2 FPGA development board
- AMD/Xilinx Vivado (ML Edition)
- VHDL

## Design Overview

This lab extends the basic LED control from Lab 1 and introduces simple
combinational logic structures:

- **2-to-4 decoder**  
  Two button inputs are decoded into a one-hot output controlling LEDs 0–3.

- **Output selection (mux)**  
  Switch inputs are used to select how RGB LED5 behaves:
  - disabled
  - mirrors RGB LED4
  - forced white (override)

- **Logic gate–based LED control**  
  An alternative logic block is implemented for LEDs 0–3 using basic logic
  operators (`and`, `or`, `nand`, etc.), and selected via a switch input.

The design is purely combinational and reuses parts of the Lab 1 structure.

## Implementation Notes

- No clocks, registers, or sequential logic are used
- No VHDL `process` blocks are used, as required by the assignment
- Conditional signal assignments and simple logic operators are used
- The design was synthesized and implemented in Vivado

## Synthesis Results

- **LUTs used:** 5  
- **Registers used:** 0  
- **Entity ports:** 14  
  - Matches the reported I/O count (14 bonded IOBs)

## Design Analysis

- The elaborated schematic reflects the VHDL structure (decoder, mux, logic)
- The synthesized schematic shows the same functionality mapped to FPGA
  primitives (LUTs and I/O buffers)
- The design meets all timing requirements; no timing constraints are required
  due to the absence of clocks

## Result

The design was successfully synthesized, implemented, and verified on hardware.
All required combinational behaviors function as intended.