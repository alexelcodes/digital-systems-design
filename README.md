# Digital Systems Design (VHDL)

<p align="center">
  <img src="https://img.shields.io/badge/Language-VHDL-blue" />
  <img src="https://img.shields.io/badge/FPGA-PYNQ--Z2-success" />
  <img src="https://img.shields.io/badge/Tool-Vivado%20ML-orange" />
  <img src="https://img.shields.io/badge/Board-Zynq--7000-informational" />
</p>

Personal repository containing project works for the **Digital Systems Design** course.
It focuses on the basic FPGA design flow and VHDL-based digital design: RTL, constraints, simulation (where applicable), synthesis/implementation, and validation on real hardware.

## Scope

- Combinational and sequential VHDL design
- Clock domain considerations
- FSMs and hierarchical design
- Testbenches and simulation
- Timing analysis and real hardware verification

## Hardware / Toolchain

- **Board:** PYNQ-Z2 (Zynq-7000)
- **Toolchain:** AMD/Xilinx Vivado (ML Edition)
- **Language:** VHDL

> Note: Vivado was run on **macOS (Apple Silicon)** using a Docker-based setup with Rosetta for x86_64 compatibility.
> Setup notes: [docs/vivado-macos-docker-setup.md](docs/vivado-macos-docker-setup.md)

## Repository structure

Each project follows the same directory structure:

```text
XX-*/
├── README.md        # project description
└── src/
    ├── rtl/         # synthesizable VHDL
    ├── tb/          # testbenches (if applicable)
    └── xdc/         # constraints (.xdc)
```

Some folders also include `figures/` (oscilloscope screenshots, schematics, etc.).

## Contents

- **[LED bring-up](01-led)**
- **[Combinational logic](02-combinatorial-logic)**
- **[Counters](03-counters)**
- **[Button with repeat / FSM](04-button-with-repeat)**
- **[PWM controller](05-pwm-controller)**