# ------------------------------------
# Makefile for Azadi-SoC simulation
# ------------------------------------

# Set RTL_VERSION here
# export RTL_VERSION := rtl-v1.4

# Setting base paths
export AZADI_ROOT := $(PWD)
export ARM_ROOT := $(AZADI_ROOT)/arm
export TB_DIR := $(AZADI_ROOT)/verif

# QSPI flash include path
INCLUDE_FILES = $(AZADI_ROOT)/verif/src/flash_model/N25Q128A13E_VG12

TOP_HDL = $(AZADI_ROOT)/src/top/azadi_top_sim.sv
# Verilator simulation CLI variables
TIMEOUT ?= 5000000
CYCLES ?= 519800

# Setting TEST hex path
TEST := basic-test
HEX := $(TB_DIR)/tests/$(TEST)/test.hex
# Setting POST ROM bin path
ROM_BIN := $(AZADI_ROOT)/post_rom_verilog.rcf

# CFLAGS for verilator generated Makefiles. Without -std=c++11 it
# complains for `auto` variables
CFLAGS += "-std=c++11"

# Optimization for better performance; alternative is nothing for
# slower runtime (faster compiles) -O2 for faster runtime (slower
# compiles), or -O for balance.
VERILATOR_MAKE_FLAGS = OPT_FAST="-O3"

# Simulation RTL defines (ifdefs)
QSPI = 0
ifeq ($(QSPI),1)
  # add more defines like: DEFS = -Ddef1 -Ddef2 -Ddef3
	DEFS = -DQSPI
endif

# To enable to disable GUI, default is enabled
# pass GUI=0 with make command to turn off GUI
GUI = 1
ifeq ($(GUI),1)
	XM-GUI = -gui -access +rwc
endif

all:
	@echo ${value AZADI_ROOT}

flist.azadi:
	@echo ${value RTL_VERSION}

# ----------------------
#       Verilator
# ----------------------
verilator-build: flist.azadi
	mkdir -p build;
	verilator -cc -CFLAGS $(CFLAGS) $(DEFS) \
	    -I${AZADI_ROOT}/src/ip/prim/rtl \
	    -I${AZADI_ROOT}/src/ip/prim \
	    -I${AZADI_ROOT}/src/vendor/pulp_fpnew/src/common_cells/include \
	    -I${AZADI_ROOT}/src/vendor/pulp_fpnew/src/fpu_div_sqrt_mvp/hdl \
		-I$(AZADI_ROOT) -I$(TB_DIR) -timescale 1ns/1ps  -f flist.azadi \
		--trace --trace-structs --trace-params --threads 4 \
		-Wno-IMPLICIT -Wno-LITENDIAN -Wno-UNSIGNED -Wno-LATCH -Wno-PINMISSING -Wno-WIDTH \
		-Wno-MODDUP -Wno-UNOPTFLAT -Wno-BLKANDNBLK -Wno-UNOPTTHREADS -Wno-ALWCOMBORDER \
	  	${TOP_HDL} --top-module azadi_top_sim --Mdir ./build/verilator \
		-exe $(TB_DIR)/src/sim.cpp
		$(MAKE) -C ./build/verilator/ -f Vazadi_top_sim.mk $(VERILATOR_MAKE_FLAGS)

verilator-run: verilator-build #hex-build
	./build/verilator/Vazadi_top_sim +HEX="${HEX}" +ROM_BIN="${ROM_BIN}" +cycles=${CYCLES} +timeout=${TIMEOUT}

veriltor-clean:
	rm -rf ./build/verilator

# ---------------------
#       Xcelium
# ---------------------
xm-build: flist.azadi hex-build
	@echo $(value HEX)
	mkdir -p build; mkdir -p build/xcelium;
	xrun -sv -64bit  +lic_queue -licqueue +incdir+$(INCLUDE_FILES) \
		-xmlibdirpath ./build/xcelium -xmlibdirname azadi.build $(DEFS) \
		-timescale 1ns/1ps -f ../rtl/flist.azadi -top azadi_top_sim \
		+HEX="${HEX}" +ROM_BIN="${ROM_BIN}" $(XM-GUI)

xm-clean:
	rm -rf xrun.* *.shm

# ---------------------
#       Other
# ---------------------
hex-build:
	cd $(TB_DIR)/tests;
	make -f $(TB_DIR)/tests/Makefile -C $(TB_DIR)/tests/$(TEST)

.PHONY:
	veriltor-clean verilator-run verilator-build xm-build xm-clean deep-clean hex-build

deep-clean:
	rm -rf build xrun.* *.shm
