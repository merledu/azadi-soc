Third-Party/External Code
=========================

This directory contains "vendored" code, i.e. code which copied into this repository from external sources.
Directory names generally follow the scheme `<vendor>`_`<library>`.

## Run ibex with fpu

To run ibex with FPU, first install fusesoc  

    pip install fusesoc

Add `ibex` and `fpnew` as FuseSoC library, run this command from the root of the repository.

    fusesoc library add ibex ./hw/vendor/lowrisc_ibex
For fpnew

    fusesoc library add fpnew ./hw/vendor/pulp_fpnew

Now you can check the list of core files by running

    fusesoc core list

Finally you can run the following command to build the verilator model for risc-v compliance

    fusesoc run --target=sim --setup --build lowrisc:ibex:ibex_riscv_compliance --RV32E=0 --RV32M=ibex_pkg::RV32MSlow --RVF=ibex_pkg::RV32FSingle

You can find the verilator model in the build folder which is created at the root of the directory.  
`build/lowrisc_ibex_ibex_riscv_compliance_0.1/sim-verilator/Vibex_riscv_compliance`  

Run `./Vibex_riscv_compliance -h` in `sim-verilator` folder to see the further options.
