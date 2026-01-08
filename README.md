# Digital Systems Design (VHDL)

<p align="center">
  <img src="https://img.shields.io/badge/Language-VHDL-blue" />
  <img src="https://img.shields.io/badge/FPGA-PYNQ--Z2-success" />
  <img src="https://img.shields.io/badge/Tool-Vivado%20ML-orange" />
  <img src="https://img.shields.io/badge/Board-Zynq--7000-informational" />
</p>

Personal repository containing laboratory works for the **Digital Systems Design** course.
The labs focus on basic FPGA design flow and VHDL-based digital design: RTL, constraints, simulation (where applicable), synthesis/implementation, and running designs on real hardware.

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

> Note: I worked on **macOS (Apple Silicon)**, so Vivado was run via Docker + Rosetta.  
> Setup notes: [docs/vivado-macos-docker-setup.md](docs/vivado-macos-docker-setup.md)

## Repository structure

Each lab follows the same directory structure:

```text
lab-X-*/
├── README.md        # lab report
└── src/
    ├── rtl/         # synthesizable VHDL
    ├── tb/          # testbenches (if applicable)
    └── xdc/         # constraints (.xdc)
```

Some labs also include `figures/` (oscilloscope screenshots, schematics, etc.).

## Labs

- **Lab 1 — LED bring-up** — [lab-1-led](lab-1-led)