# Azadi Verification Environment
Azadi verification environment is capable of running directed assembly and constrained random tests which are generated through Google DV.  

## Verif directory structure
**google_riscv_dv:** Instruction Set Generator (ISS) to generate constrained random tests using UVM.  
**random_tests:** Contains a verification environment that runs Google DV random tests on the core.  
**src:** SystemVerilog/C++ test benches used to run Xcelium, verilator, and FPGA simulation/emulation.  
**tests:** Contains directed tests written in assembly for core and peripherals.  
**waves:** Saved waveforms snapshot to reuse and save debugging time.

## How to run directed tests?
Azadi uses a Makefile based environment to run directed tests. Makefile can be used to run Xcelium and verilator based simulation. Below are the available Makefile targets. 

**Note:** Switch to verif directory in order to run Makefile.

### Xcelium
To run simulation on Xcelium, run:  
``` 
make xm-build 
```  
This will run `basic-test` present in the verif/tests folder. To run a particular test pass TEST=$TEST_NAME flag, along with test name. for example to run `gpio` test, run:  
```
make xm-build TEST=gpio
```  
Below are the other flags that can be passed with this command:  
**GUI:** Enables waveform GUI; 1: enable, 0: disable - default: 0  
**COV:** Enables code coverages if set to 1.  

### Verilator
To build simulation model for Verilator, run:  
```
make verilator-build
```
To run verilator executable model:  
```
make verilator-run
```

## How to build directed assembly tests?  
To build existing assembly test, run:  
```
make hex-build TEST=$TEST_NAME
```  
To add new test:  
1. Create a new folder under verif/test with a proper test name.
2. Create a file `test.s` inside the recently created folder.
3. Use `basic-test/test.s` file as a template to write your own assembly code.

## How to run constrained random tests?

1. Relocate to the verification directory
```    
cd <path_to_azadi-tsmc>/verif
```  
2. Set environment variables (for csh shell)
```
source setenv
```  
3. Execute the tests. 
```
make ITERATIONS=1 TEST=riscv_arithmetic_basic_test SEED=123
```  
The above command will run a single test `riscv_arithmetic_basic_test` with SEED value 123. Same seed value can be used to regenerate the same randomized test again.  
**Note:** Testlist is present at path `<path_to_azadi-tsmc>/verif/random_tests/env/core/vendor/core_ibex`
