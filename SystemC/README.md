# SystemC Direct-Mapped Cache Model

This folder contains a SystemC model of the RTL direct-mapped cache and a traffic generator to stress-test it.

## Files

- `DcacheSystemC.h` / `DcacheSystemC.cpp` - SystemC cache model matching the RTL interface.
- `TrafficGenerator.h` / `TrafficGenerator.cpp` - CPU traffic generator and simple memory model.
- `SystemCMain.cpp` - Top-level instantiation and simulation control.
- `CMakeLists.txt` - Build script for SystemC.

## Build

Assuming SystemC is installed and `find_package(SystemC REQUIRED)` works:

```bash
mkdir build
cd build
cmake ../systemc
cmake --build .
```

## Run

```bash
./dcache_systemc
```
