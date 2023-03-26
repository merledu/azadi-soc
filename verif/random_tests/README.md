# Verification Environment for Azadi SoC
This repository contain tests (in C and assembly both), benchmarks and the test-benches for the verification of Azadi SoC. It also has an extension to the [DV environment](https://github.com/lowRISC/ibex/tree/86084b9d3d4ffb569287aa9ee0869048c5b6b78d/dv/uvm) from lowRISC (commit hash: `86084b9d3d4ffb569287aa9ee0869048c5b6b78d`) which adds support for the "F" and "D" Standard Extension for Single-Precision and Double-Precision Floating-Point respectively.

Repositories and versions to use:

## Azadi RISC-V SoC
Azadi SoC after it's first tapeout in MPW-two.

Please stick to version v0.0.0 release
(commit hash: c4b32375365bf18e352f6ee6c102ca19785f5f42)
```
git clone https://github.com/merledu/azadi-new.git
cd azadi-new
git checkout v0.0.0-c4b32375
```
Note: Until the changes to the trace port for floating-point signals are merged in merledu/azadi-new, use [this fork](https://github.com/zeeshanrafique23/azadi-new) instead.

## riscv-dv
Random instruction generator for RISC-V processor verification
(commit hash: `3da32bbf6080d3bf252a7f71c5e3a32ea4924e49`)
```
git clone https://github.com/google/riscv-dv.git
cd riscv-dv
git checkout 3da32bbf
```
# Setting up the environment
Make sure the environment variables for the instruction set simulator such as [Spike](https://github.com/lowRISC/riscv-isa-sim/tree/ibex) or OVPsim and the [RISC-V GNU compiler toolchain](https://github.com/riscv-collab/riscv-gnu-toolchain) are set. In addition to the `RISCV_GCC` and `RISCV_OBJCOPY` environment variables, you'll also have to set one more with the directory where you'll be cloning the repos.
```
mkdir azadi_regresion
export DV_AZADI=/path/to/azadi_regression
``` 
For csh or its derivatives:
```
setenv DV_AZADI /path/to/azadi_regression
```
## Cloning the repo
All directories need to be created at the root level with the rest of the repos.
```
cd $DV_AZADI
git clone https://github.com/merledu/azadi-verify.git
cd azadi-verify
```
Once inside this directory, you can start the process of cloning the repos mentioned [here](https://github.com/merledu/azadi-verify/blob/6a1f2d5236a49d5fa36503a1024d5b63afe060ea/README.md#L4). Just run:
```
make setup
```
and it will clone the random instruction generator in the `$DV_AZADI/google_riscv-dv` directory and the Azadi RISC-V SoC in the `$DV_AZADI/azadi-new` directory. It will also create a folder `regr` in the same directory and run an arithmetic instruction test (without any load/store/branch instructions) with `ITERATIONS=1` using the Xcelium simulator by default. This is to make sure that the environment has been correctly setup. The steps can also be performed individually by running:
```
make env
```
followed by:
```
make verify
```
# Running the regression
Currently, our extension of the DV environment enables the random instruction generator for generating the assembly for the floating-point instructions and the coverage options for the Xcelium simulator. To run a test, `cd` into your working directory and type:
```
make -f $DV_AZADI/azadi-verify/Makefile \
 > TEST=<testname> \
 > ITERATIONS=<count> \
 > ISA=<risc-v ISA subset> \
 > SEED=<seed> # random, if not provided

# For example to run a regression on the whole
# of the `RV32IMFDC` subset: (with coverage and waveform dump)

make -f $DV_AZADI/azadi-verify ISA=rv32imfdc COV=1 WAVES=1
```
The coverage reports and the waveforms for each test under all can be found in the `rtl_sim` directory and in case of the coverage report can also be merged post-regression to give the aggregated coverage.

## Verification Status
The verifcation is being done by using the azadi-verify repo, the status of all the tests can be found [Verification Basic Tests Sheet.](https://docs.google.com/spreadsheets/d/1gIzSU5mb4L3pPdiJr7MkdhvupT7p5VF2qy1PzDwq-5I/edit#gid=1374860298)

