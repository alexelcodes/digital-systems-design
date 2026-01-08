# Lab 1 — LED Controller (PYNQ-Z2)

## Goal

Implement a simple combinational VHDL design to verify the FPGA toolchain and
basic I/O functionality of the PYNQ-Z2 board.

## Hardware / Tools

- PYNQ-Z2 FPGA development board
- AMD/Xilinx Vivado (ML Edition)
- VHDL

## Design Overview

The design is purely combinational and directly maps push-button inputs to LEDs:

- **Green LEDs (0–3)** directly follow buttons (0–3)
- **RGB LED4**:
  - Only button 0 pressed → red
  - Only button 1 pressed → green
  - Only button 2 pressed → blue
  - Any other button combination → off
- **RGB LED5**:
  - No buttons pressed → white (R+G+B)
  - All buttons pressed → off
  - Any other button combination → white

## Implementation Notes

- The design is implemented as a single top-level VHDL entity
- `with ... select` statements are used for RGB LED control
- No clock, reset, or sequential logic is used
- The design was synthesized, implemented, and programmed to the FPGA

## Result

The LED behavior matches the specification and was verified on the PYNQ-Z2
hardware.