# Azadi RISC-V SoC

[![Join the chat at https://gitter.im/merledu/azadi-new](https://badges.gitter.im/merledu/azadi-new.svg)](https://gitter.im/merledu/azadi-new?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)  

Azadi is an SoC with 32-bit RISC-V single core "[lowrisc/ibex](https://github.com/lowrisc/ibex)", ibex is an in-order core with a 3-stage pipeline that implements the RV32IMBC instruction set architecture. We are only using RV32IMC in Azadi SoC. A [Floating Point Unit (FPU)](https://github.com/pulp-platform/fpnew) designed by pulplatform is integraed with ibex to make it RV32IMFC. 

## Verification Status
Ibex+FPU passes all the compliance test of RV32IMFC, here is the [status](https://docs.google.com/spreadsheets/d/1gIzSU5mb4L3pPdiJr7MkdhvupT7p5VF2qy1PzDwq-5I/edit#gid=862473485) of tests.
The status of all the tests can be found [Verification Basic Tests Sheet.](https://docs.google.com/spreadsheets/d/1gIzSU5mb4L3pPdiJr7MkdhvupT7p5VF2qy1PzDwq-5I/edit#gid=1374860298)

## Quickstart guide
Prerequisite ==> You need to have the `verilator` installed for simulation.
1. Clone the repository.
2. `export AZADI_ROOT= `pwd` `
3. Set the `LOCATION` variable to your repo's root path in `fusesoc.conf` file.
4. For direct simulation through verilator simply execute `make` from the root of this repo. OR To use fusesoc then execute `fusesoc run --target=sim azadi --cycles=519800 --HEX=$AZADI_ROOT/verif/tests/basic_test/test.hex`
5. After successful make you can find the waveform file in `logs` folder on root of this repo. To see the waves you should have `gtkwave` installed.

### Block Diagram of SoC
![](docs/images/Azadi%20MicroArchitechtureDiagram-SoC.drawio.png)
### Directory Structure Diagram of SoC
![](docs/AZADI-II%20directory%20structure.png)

## Issues and Solutions
1. If you encountered with `Key 'cores' not found in GAPI structure. Install a compatible version with 'pip3 install --user -r python-requirements.txt'` then run from the root of the repo:
`cd src/vendor/lowrisc_ibex/`
`pip3 install -U -r python-requirements.txt`
then the required version should be installed and you can try to run the core again.
