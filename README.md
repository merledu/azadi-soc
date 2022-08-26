# Azadi RISC-V SoC

[![Join the chat at https://gitter.im/merledu/azadi-new](https://badges.gitter.im/merledu/azadi-new.svg)](https://gitter.im/merledu/azadi-new?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Azadi is an SoC with 32-bit RISC-V single core "[lowrisc/ibex](https://github.com/lowrisc/ibex)", ibex is an in-order core with a 3-stage pipeline that implements the RV32IMBC instruction set architecture. We are only using RV32IMC in Azadi SoC. A [Floating Point Unit (FPU)](https://github.com/pulp-platform/fpnew) designed by pulplatform is integraed with ibex to make it RV32IMFC.

## Verification Status
Ibex+FPU passes all the compliance test of RV32IMFC, here is the [status](https://docs.google.com/spreadsheets/d/1gIzSU5mb4L3pPdiJr7MkdhvupT7p5VF2qy1PzDwq-5I/edit#gid=862473485) of tests.
The status of all the tests can be found [Verification Basic Tests Sheet.](https://docs.google.com/spreadsheets/d/1gIzSU5mb4L3pPdiJr7MkdhvupT7p5VF2qy1PzDwq-5I/edit#gid=1374860298)

## Prerequisite
You need to have:
1. [Verilator](https://verilator.org/guide/latest/install.html) for running the simulation of the SoC.
2. [Fusesoc](https://fusesoc.readthedocs.io/en/stable/user/installation.html) for building the tools to simulate SoC.
3. [GtkWave](https://www.howtoinstall.me/ubuntu/18-04/gtkwave/) for opening the waveform file.

To achive pyhton requirements, Run:

```
cd src/vendor/lowrisc_ibex/
```
```
pip3 install -U -r python-requirements.txt
```

## Quickstart guide
Clone the repositroy.
```
cd azadi-II/
```
Root directory.
```
export AZADI_ROOT=`pwd`
```
We are now ready to do our first exercises with AZADI-II. Following are the options to run the basic tests on the SoC.
1. Run simulation directly using Makefile by executing `make` from the root and get `.vcd` file in `logs`.
2. Run simulation through `FuseSoc`, From root run:
```
fusesoc --cores-root=. run --target=sim merl:azadi-II:azadi-II_sim --cycles=519800 --HEX=$AZADI_ROOT/verif/tests/basic_test/test.hex
```
After simulation is done, you can find the waveform file in `$AZADI_ROOT/build/azadi_1.0/sim-verilator/logs`.

### Block Diagram of SoC
![](docs/images/Azadi%20MicroArchitechtureDiagram-SoC.drawio.png)
### Directory Structure Diagram of SoC
![](docs/AZADI-II%20directory%20structure.jpeg)
