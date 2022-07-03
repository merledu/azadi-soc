# Directory
AZADI_ROOT := $(realpath ./)
TBDIR = ${AZADI_ROOT}/verif/verilator
TESTDIR = ${AZADI_ROOT}/verif/tests

# Try later (see usage in /home/zain/Documents/Code/tf)
#RTLSRC=../src

# Define plus arguments
TIMEOUT ?=
M_TIMEOUT= +timeout=${TIMEOUT}
CYCLES ?= 519800
M_CYCLES= +cycles=${CYCLES}
TEST ?= tests/basic_test
HEX= ${TESTDIR}/${TEST}/test.hex

# Constants
RISCV_PREFIX = riscv32-unknown-elf-
GCC_PREFIX = $(RISCV_PREFIX)gcc
GCC_FLAGS = -march=rv32i -mabi=ilp32 -mcmodel=medany -std=gnu99 -g
LINK_FLAGS = -march=rv32i -mabi=ilp32 -static -nostdlib -nostartfiles -T $(TEST_DIR)/common/link.ld
OBJDUMP_PREFIX = $(RISCV_PREFIX)objdump
OBJDUMP_FLAGS = --disassemble-all --disassemble-zeroes --section=.text --section=.text.startup --section=.text.init --section=.data
VERILATOR = verilator

TOP_HDL = $(AZADI_ROOT)/src/top/azadi_top_verilator.sv

# CFLAGS for verilator generated Makefiles. Without -std=c++11 it
# complains for `auto` variables
CFLAGS += "-std=c++11"

# Optimization for better performance; alternative is nothing for
# slower runtime (faster compiles) -O2 for faster runtime (slower
# compiles), or -O for balance.
VERILATOR_MAKE_FLAGS = OPT_FAST="-O2"

# Targets
all: run

clean:
	rm -rf obj_dir

verilator-build: ${TOP_HDL} 
	$(VERILATOR) --cc -CFLAGS ${CFLAGS} -DAZADI \
	  -I${AZADI_ROOT}/src/periph/prim/rtl \
	  -I${AZADI_ROOT}/src/periph/prim \
	  -I${AZADI_ROOT}/src/vendor/pulp_fpnew/src/common_cells/include \
	  -I${AZADI_ROOT}/src/vendor/pulp_fpnew/src/fpu_div_sqrt_mvp/hdl \
	  -I${AZADI_ROOT}/verif/tests -f flist \
	  --trace --trace-structs --trace-params --threads 4 \
		-Wno-IMPLICIT -Wno-LITENDIAN -Wno-UNSIGNED -Wno-LATCH -Wno-PINMISSING -Wno-WIDTH \
		-Wno-MODDUP -Wno-UNOPTFLAT -Wno-BLKANDNBLK -Wno-UNOPTTHREADS -Wno-ALWCOMBORDER \
	  ${TOP_HDL} --top-module azadi_top_verilator \
	  -exe $(TBDIR)/sim.cpp
	$(MAKE) -C obj_dir/ -f Vazadi_top_verilator.mk $(VERILATOR_MAKE_FLAGS)

run: verilator-build
	./obj_dir/Vazadi_top_verilator +HEX="${HEX}" ${M_CYCLES} ${M_TIMEOUT}

help:
	@echo Possible targets: verilator help clean all verilator-build

.PHONY: help clean verilator

#riscv32-unknown-elf-elf2hex --bit-width 32 --input test --output prog.hex
