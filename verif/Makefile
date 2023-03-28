# ------------------------------------
# Makefile for Azadi-SoC simulation
# ------------------------------------

# Setting base paths
export AZADI_ROOT := $(PWD)/..
export TB_DIR     := $(PWD)

# QSPI flash include path
INCLUDE_FILES = $(AZADI_ROOT)/flash_model/N25Q128A13E_VG12

# Setting TEST hex path
TEST := basic-test
HEX := $(TB_DIR)/tests/$(TEST)/test.hex

# Enable coverage dump
COV      = 0
# Scopt
SCOPE    = azadi_soc_top
# Setting POST ROM bin path and .vmf file for N25Qxxx flash
ROM_BIN := $(ARM_ROOT)/post-rom/post_rom_verilog.rcf
FLASH_HEX:= $(TB_DIR)/tests/$(TEST)/mem_Q128_bottom.vmf
ROM_BIN_VERILATOR := $(TB_DIR)/tests/post-rom/rom.bin
# Setting boot mode, should be in UpperCase | available options: ICCM, FLASH, QSPI_CONFIG, QSPI
BOOT_MODE := ICCM
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

# Simulation RTL defines (ifdefs)
DEFS  = $(QSPI-DEF)
DEFS += $(SIM-DEF)

# -----------------------
#   Makefile Targets
#------------------------


# Verilator

verilator-run: verilator-build
	./build/verilator/Vazadi_soc_top +HEX="$(HEX)" +ROM_BIN="$(ROM_BIN_VERILATOR)"

verilator-build: hex-build
	mkdir -p build;
	verilator -cc -CFLAGS $(CFLAGS) $(DEFS) \
		-I${AZADI_ROOT}/verif/include -I${AZADI_ROOT}/cvfpu/src/common_cells/include \
		-I$(AZADI_ROOT)/verif/src -I$(TB_DIR) -f flist.azadi \
		-trace --trace-structs --trace-params --threads 4 \
		-Wno-IMPLICIT -Wno-LITENDIAN -Wno-UNSIGNED -Wno-LATCH -Wno-PINMISSING -Wno-WIDTH \
		-Wno-CASEINCOMPLETE -DAZADI -DSIM \
		-Wno-MODDUP -Wno-UNOPTFLAT -Wno-BLKANDNBLK -Wno-UNOPTTHREADS -Wno-ALWCOMBORDER \
	  --top-module azadi_soc_top -exe $(TB_DIR)/src/sim.cpp --Mdir ./build/verilator
		$(MAKE) -C build/verilator -f Vazadi_soc_top.mk $(VERILATOR_MAKE_FLAGS)

veriltor-clean:
	rm -rf ./build/verilator


#  Xcelium

xm-build: hex-build
	cp $(FLASH_HEX) $(TB_DIR);
	mkdir -p build; mkdir -p build/xcelium;
	xrun -sv -64bit -assert +lic_queue -licqueue +incdir+$(INCLUDE_FILES) +incdir+$(AZADI_ROOT)/verif/src \
		-xmlibdirpath ./build/xcelium -xmlibdirname azadi.build $(DEFS) \
		-timescale 1ns/1ps $(SDF) -f flist.azadi -top azadi_top_sim \
		+HEX="$(HEX)" +ROM_BIN="$(ROM_BIN)" $(XM-GUI) -abvrecordcoverall -linedebug -input cmd.tcl \
		-xfile data/xfile.txt +BOOT_MODE="$(BOOT_MODE)" $(COV-ARG)

xm-clean:
	rm -rf xrun.* *.shm


#  Other

hex-build:
	cd $(TB_DIR)/tests;
	make -f $(TB_DIR)/tests/Makefile -C $(TB_DIR)/tests/$(TEST)

.PHONY:
	veriltor-clean verilator-run verilator-build xm-build xm-clean deep-clean hex-build

clean:
	rm -rf build/ xrun.* *.shm
