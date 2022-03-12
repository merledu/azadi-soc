# Directory
AZADI_ROOT = $(realpath ./)
TBDIR = ${AZADI_ROOT}/dv/verilator

# Try later (see usage in /home/zain/Documents/Code/tf)
#RTLSRC=../src

# Define test name
TEST = add

# Constants
RISCV_PREFIX = riscv32-unknown-elf-
GCC_PREFIX = $(RISCV_PREFIX)gcc
GCC_FLAGS = -march=rv32i -mabi=ilp32 -mcmodel=medany -std=gnu99 -g
LINK_FLAGS = -march=rv32i -mabi=ilp32 -static -nostdlib -nostartfiles -T $(TEST_DIR)/common/link.ld
OBJDUMP_PREFIX = $(RISCV_PREFIX)objdump
OBJDUMP_FLAGS = --disassemble-all --disassemble-zeroes --section=.text --section=.text.startup --section=.text.init --section=.data
VERILATOR = verilator

TOP_HDL = $(AZADI_ROOT)/hw/azadi/rtl/azadi_top_verilator.sv

# CFLAGS for verilator generated Makefiles. Without -std=c++11 it
# complains for `auto` variables
CFLAGS += "-std=c++11"

# Optimization for better performance; alternative is nothing for
# slower runtime (faster compiles) -O2 for faster runtime (slower
# compiles), or -O for balance.
VERILATOR_MAKE_FLAGS = OPT_FAST="-O2"

# Targets
all: clean verilator

clean:
	rm -rf logs *.log *.s *.hex *.dis *.tbl irun* vcs* simv* snapshots \
	verilator* *.exe obj* *.o ucli.key vc_hdrs.h csrc *.csv work


verilator-build: ${TOP_HDL} 
	$(VERILATOR) --cc -CFLAGS ${CFLAGS} -I${AZADI_ROOT}/hw/ip/prim/rtl \
	  -I${AZADI_ROOT}/hw/ip/prim \
	  -I${AZADI_ROOT}/hw/vendor/pulp_fpnew/src/common_cells/include \
	  -I${AZADI_ROOT}/hw/vendor/pulp_fpnew/src/fpu_div_sqrt_mvp/hdl \
	  -I${AZADI_ROOT}/tests -f flist \
	  --trace --trace-structs --trace-params --threads 4 \
		-Wno-IMPLICIT -Wno-LITENDIAN -Wno-UNSIGNED -Wno-LATCH -Wno-PINMISSING -Wno-WIDTH \
		-Wno-MODDUP -Wno-UNOPTFLAT -Wno-BLKANDNBLK -Wno-UNOPTTHREADS -Wno-ALWCOMBORDER \
	  ${TOP_HDL} --top-module azadi_top_verilator \
	  -exe $(TBDIR)/sim.cpp
	$(MAKE) -C obj_dir/ -f Vazadi_top_verilator.mk $(VERILATOR_MAKE_FLAGS)
	touch verilator-build

verilator: verilator-build
	./obj_dir/Vazadi_top_verilator

help:
	@echo Possible targets: verilator help clean all verilator-build

.PHONY: help clean verilator

#riscv32-unknown-elf-elf2hex --bit-width 32 --input test --output prog.hex
