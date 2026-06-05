# Performance Model to ASIC Co-Relation

This repository documents my direct-mapped cache work with proof of concept artifacts so the design, verification, and SystemC modeling are clearly attributed and preserved. The reason people take my work without credit or something so hence if I push in GitHub I have proof of concept and I did the work and stuff. At least people can add source or credit name just like in college projects and acknowledge the author and contributions.

# Direct-Mapped Cache Verification and SystemC Modeling

This repository contains a direct-mapped cache RTL design, UVM-based verification environment, and a companion SystemC model for architecture-level stress testing.

## Repository structure

- `RTL/`
  - `directmap_cache.v` — direct-mapped cache RTL design.

- `Verification/`
  - UVM testbench files including agent, driver, monitor, scoreboard, sequencer, sequences, and top-level tests.
  - `directmap_cache_intf.sv` — cache interface definition used by the UVM environment.
  - `dcache_pkg.sv` — shared transaction and sequence item definitions.
  - `directmap_cache_tb_top.sv` and related tests for simulation.

- `SystemC/`
  - `DcacheSystemC.h` / `DcacheSystemC.cpp` — SystemC cache model matching the RTL interface.
  - `TrafficGenerator.h` / `TrafficGenerator.cpp` — traffic generator and simple memory model for stress testing.
  - `SystemCMain.cpp` — top-level SystemC simulation entry point.
  - `Makefile` — build script for the SystemC model.

- Root files
  - `README.md` — repository overview and usage notes.
  - `dcache_block_diagram.mmd`, `dcache_block_diagram.svg`, `dcache_block_diagram_rtl.svg` — block diagram sources and generated images.

## Usage

### RTL and Verification

Simulation of the SystemVerilog testbench requires a compatible simulator that supports UVM and SystemVerilog.

### SystemC model

Build the SystemC model from the `SystemC/` folder:

```bash
cd SystemC
make SYSTEMC_HOME=/path/to/systemc
```

Run the model:

```bash
./dcache_systemc
```

## Notes

- The RTL source is stored in `RTL/`.
- Verification files are stored in `Verification/`.
- The `SystemC/` folder contains a standalone model and generator for cross-checking and performance stress.
- Diagram assets remain in the repository root and are not part of the source tree.

