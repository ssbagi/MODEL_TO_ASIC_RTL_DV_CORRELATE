# Performance Model to ASIC Co-Relation

## Credits

- Based on standard cache principles and ARM-style presentation.
- Reference: https://developer.arm.com/documentation/den0042/0100/Caches
- Author: Shreyas S Bagi
- Generated and assisted by GitHub Copilot

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

Iteration 1 : Version 1 : Needs still more Validation and addition of the Waveforms and Proof of Concept to tell

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



## Improving Modelling Quality, Validation, and Correlation
Going Stage by Stage : Proper order lets it take time for the completion since it is at Iteration1 or Iteration2 stage only.

## Objective
Strengthen the modelling workflow by introducing structured validation, architecture‑intent‑aware testing, and early DV–Model correlation.
This improves correctness, reduces debug time, and increases confidence before PD.

## Roles & Responsibilities

### Senior / Lead Modelling Engineers
- Own architecture model design
- Define modelling boundaries (architectural vs microarchitectural)
- Specify timing intent, arbitration, replacement rules
- Provide test categories, TG patterns, and validation strategy
- Guide juniors on correctness and behaviour

### Junior Modelling Engineers (That is me)
- Understand architecture
- Read and understand model code
- Validate behaviour
- Run traces and analyze mismatches
- Write helper functions, tests, checkers
- Add TG patterns
- Ensure correlation with RTL
- Not expected: deciding architecture, modelling boundaries, timing intent, arbitration, replacement policies.

### Why Structured Validation Is Needed
- Current validation is functional but not systematic.
- Adding structure improves:
- Behavioural correctness
- Debug clarity
- Architecture‑intent coverage
- Repeatability
- Early mismatch detection

### Proposed Validation Enhancements
- Traffic Generator (TG) Scenarios
  - Use TGs to exercise:
  - Load/store patterns
  - Bank conflicts
  - Arbitration
  - Pipeline corner cases

- Categorized Test Suites
  - Basic functionality
  - Corner cases
  - Stress/random
  - Performance loops
  - Ordering/consistency tests

- Architecture‑Intent‑Aware Checkers
  - Checkers that validate
    - Ordering rules
    - Bank behaviour
    - Latency expectations
    - Protocol correctness

### DV–Modelling Correlation (Early‑Stage)
- DV already runs 20M–40M trace workloads. The same Testcases can be used to validate or pipeline behaviour check the golden model is working accordingly as per the Specifications or Intended improvemnets proposed one.
- **Proposal:** add a lightweight correlation stage in modelling.
- What to compare
  - Event counts
  - Cycle counts
  - Bank conflicts
  - Pipeline stalls
  - Throughput metrics

### Acceptable correlation target
- 70–75% correlation is sufficient for early modelling stages.
- This provides confidence before synthesis/PD and reduces late‑stage surprises.

### Prototype C++ Model for Early Validation
A small, abstract C++ model can be used to:
- Validate pipeline behaviour
- Count events
- Compare against DV
- Avoid huge VCD/log dumps
- Print only summary counters (heartbeat‑style)

### Useful at:
- Post‑RTL freeze
- Pre‑synthesis
- GLS
- Pre‑PD signoff

### Expected Outcomes
- Cleaner modelling
- Faster debug cycles
- Higher correctness confidence
- Early detection of mismatches
- Better alignment with RTL/DV
- Predictable performance modelling accuracy

### Final Summary
**This proposal introduces a structured, scalable, and architecture‑aligned validation flow for modelling teams.**
**It clarifies junior vs senior responsibilities, improves test quality, and adds early DV correlation to ensure correctness before PD.**

### Results
- They are matching : The number of hits, misses, hit and miss ratio. -------------> These are basic ones. The DCache Model which is developed is a short Direct Mapped Cache with only small FSM state logic one.
- Now let us compare the Logs just for cross verifying things for a few basic Unit level Transactions : I mean like the Behaviour wise Standalone Test Cases and stuff.
- Based on reading and working this method like everyday or everytime we know where are the issues at least which to unit to modify or improve the things. It’s just a perspective gives for improvements just like showed in GEM5 simulators also. 

## Why ? 
- To have basic behaviour is to do the same or not. The Performance Modelling team comes up with the Models and the RTL and DV do the work. Just how much it is accuray done even if we have done >75% meeting is also fine.
- Standalone behaviour is merely telling the unit wise they are working fine and stuff. Short Traces the behaviour wise they are correct. (Kind of subunit or IPs)
- Now when we integrate into the whole CPU pipeline or Main block there might be numerous reasons not matching ---------------> from pipe_viewer(vcd dump) we come to know. The DV stats do not match the Golden Model developed by the Performance Modelling team.
- Like how seniors teaching the debugging basics since we run  more workloads or something. Basic one is stats comparison.  
Basic Few Unit level transactions between the SystemC/C++ to RTL/DV for a few of them. It gives us the confidence that it is working as per the specification and stuff. 



