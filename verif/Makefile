# ------------------------------------
# Makefile for Azadi-SoC simulation
# ------------------------------------

# Set RTL_VERSION here
export RTL_VERSION := rtl-v1.7

# Setting base paths
export AZADI_SDK  := $(PWD)/../../azadi-sdk
export AZADI_ROOT := $(PWD)/..
export ARM_ROOT   := $(AZADI_ROOT)/arm
export APR_ROOT   := $(AZADI_ROOT)/apr
export TB_DIR     := $(PWD)

# QSPI flash include path
INCLUDE_FILES = $(AZADI_ROOT)/flash_model/N25Q128A13E_VG12
# INCLUDE_FILES += $(AZADI_ROOT)/verif/src

# Verilator simulation CLI variables
TIMEOUT ?=
CYCLES ?= 519800

# Setting TEST hex path
TEST := basic-test
HEX := $(TB_DIR)/tests/$(TEST)/test.hex
#HEX := $(AZADI_SDK)/build/test.hex
# Enable coverage dump
COV      = 0
# Scopt
SCOPE    = azadi_soc_top
# Setting POST ROM bin path and .vmf file for N25Qxxx flash
ROM_BIN := $(ARM_ROOT)/post-rom/post_rom_verilog.rcf
FLASH_HEX:= $(TB_DIR)/tests/$(TEST)/mem_Q128_bottom.vmf
# Setting boot mode, should be in UpperCase | available options: ICCM, FLASH, QSPI_CONFIG, QSPI
BOOT_MODE := QSPI
# Coverage options
COV_OPTS = -covwork cov_work -covscope $(SCOPE) -covtest $(TEST)-$(BOOT_MODE) -covoverwrite

# CFLAGS for verilator generated Makefiles. Without -std=c++11 it
# complains for `auto` variables
CFLAGS += "-std=c++11"

# Optimization for better performance; alternative is nothing for
# slower runtime (faster compiles) -O2 for faster runtime (slower
# compiles), or -O for balance.
VERILATOR_MAKE_FLAGS = OPT_FAST="-O3"

# Defining QSPI if BOOT_MODE is QSPI
ifeq ($(BOOT_MODE),QSPI)
	QSPI-DEF = +define+QSPI
endif

# To enable to enable GUI, default is disabled
# pass GUI=1 with make command to turn-on GUI
GUI = 0
ifeq ($(GUI),1)
	XM-GUI = -gui -access +rwc
endif

ifeq ($(COV),1)
	COV-ARG = -coverage all -covdut azadi_soc_top $(COV_OPTS)
endif

# To run netlist simulation
NETLIST = 0
CORE_NETLIST = 0

ifeq ($(NETLIST),1)
	FLIST = $(APR_ROOT)/flist.azadi
	NETLIST-DEF = +define+NETLIST
	SDF = -nonotifier -sdf_cmd_file $(AZADI_ROOT)/apr/scripts/ibex.sdf_cmd -ntc_verbose -sdf_verbose
else
ifeq ($(CORE_NETLIST),1)
	FLIST = $(APR_ROOT)/flist_psynth.azadi
	SIM-DEF = +define+SIM
	SIM-DEF += +define+CORE_NETLIST
	SDF = -nospecify
else
	FLIST = ../rtl/flist.azadi
	SIM-DEF = +define+SIM
	SDF = -nospecify
endif
endif

# Simulation RTL defines (ifdefs)
DEFS  = $(QSPI-DEF)
DEFS += $(SIM-DEF)
DEFS += $(NETLIST-DEF)

# ++++++++++++++++++++++
#   Makefile Targets
# ++++++++++++++++++++++

all:
	@echo ${value AZADI_ROOT}

flist.azadi:
	@echo ${value RTL_VERSION}

flist_psynth.azadi:
	@echo ${value RTL_VERSION}

# ----------------------
#       Verilator
# ----------------------
verilator-build: flist.azadi
	mkdir -p build;
	verilator -cc -CFLAGS $(CFLAGS) $(DEFS) \
		-I${AZADI_ROOT}/verif/src \
		-I$(AZADI_ROOT) -I$(TB_DIR) -f ../rtl/flist.azadi \
		-trace --trace-structs --trace-params --threads 4 \
		-Wno-IMPLICIT -Wno-LITENDIAN -Wno-UNSIGNED -Wno-LATCH -Wno-PINMISSING -Wno-WIDTH \
		-Wno-CASEINCOMPLETE -DAZADI \
		-Wno-MODDUP -Wno-UNOPTFLAT -Wno-BLKANDNBLK -Wno-UNOPTTHREADS -Wno-ALWCOMBORDER \
	  	--top-module azadi_soc_top -exe $(TB_DIR)/src/sim.cpp --Mdir ./build/verilator
		$(MAKE) -C build/verilator -f Vazadi_soc_top.mk $(VERILATOR_MAKE_FLAGS)

verilator-run: verilator-build hex-build
	./build/verilator/Vazadi_soc_top +HEX="$(HEX)" +ROM_BIN="$(ROM_BIN)"

veriltor-clean:
	rm -rf ./build/verilator

# ---------------------
#       Xcelium
# ---------------------
xm-build: flist.azadi hex-build
	cp $(FLASH_HEX) $(TB_DIR);
	mkdir -p build; mkdir -p build/xcelium;
	xrun -sv -64bit -assert +lic_queue -licqueue +incdir+$(INCLUDE_FILES) +incdir+$(AZADI_ROOT)/verif/src \
		-xmlibdirpath ./build/xcelium -xmlibdirname azadi.build $(DEFS) \
		-timescale 1ns/1ps $(SDF) -f $(FLIST) -top azadi_top_sim \
		+HEX="$(HEX)" +ROM_BIN="$(ROM_BIN)" $(XM-GUI) -abvrecordcoverall -linedebug -input cmd.tcl \
		-xfile data/xfile.txt +BOOT_MODE="$(BOOT_MODE)" $(COV-ARG)

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

clean:
	rm -rf build/ xrun.* *.shm
