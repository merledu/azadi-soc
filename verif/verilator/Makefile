# Directory
TBDIR = ${AZADI_ROOT}/tests
TEST_DIR = ${TBDIR}/asm
HEX_DIR = ${TBDIR}/hex

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


TBFILES = $(AZADI_ROOT)/src/azadi_soc/rtl/Azadi_top_verilator.sv
# Package imports


defines =  $(AZADI_ROOT)/src/brq_core/rtl/brq_pkg.sv
defines += $(AZADI_ROOT)/src/TileLink/rtl/tlul_pkg.sv
defines += $(AZADI_ROOT)/src/TileLink/rtl/tl_periph_pkg.sv
defines += $(AZADI_ROOT)/src/TileLink/rtl/tl_main_pkg.sv
defines += $(AZADI_ROOT)/src/GPIO/rtl/gpio_reg_pkg.sv
defines += $(AZADI_ROOT)/src/rv_dm/rtl/jtag_pkg.sv
defines += $(AZADI_ROOT)/src/pulp_riscv_dbg/src/dm_pkg.sv
defines += $(AZADI_ROOT)/src/rv_plic/rtl/rv_plic_reg_pkg.sv
defines += $(AZADI_ROOT)/src/uart/rtl/uart_reg_pkg.sv
defines += $(AZADI_ROOT)/src/i2c/rtl/i2c_reg_pkg.sv
defines += $(AZADI_ROOT)/src/rv_timer/rtl/rv_timer_reg_pkg.sv
defines += $(AZADI_ROOT)/src/brq_core/rtl/prim_pkg.sv
defines += $(AZADI_ROOT)/src/primitives/rtl/prim_util_pkg.sv
defines += $(AZADI_ROOT)/src/spi_host/rtl/spi_defines.v

defines += $(AZADI_ROOT)/src/fpnew/src/fpnew_pkg.sv
defines += $(AZADI_ROOT)/src/fpnew/src/common_cells/src/cb_filter_pkg.sv
defines += $(AZADI_ROOT)/src/fpnew/src/common_cells/src/ecc_pkg.sv
defines += $(AZADI_ROOT)/src/fpnew/src/common_cells/src/cf_math_pkg.sv
defines += $(AZADI_ROOT)/src/fpnew/src/fpu_div_sqrt_mvp/hdl/defs_div_sqrt_mvp.sv
defines += $(AZADI_ROOT)/src/fpnew/src/common_cells/include/common_cells/registers.svh


# CFLAGS for verilator generated Makefiles. Without -std=c++11 it
# complains for `auto` variables
CFLAGS += "-std=c++11"

# Optimization for better performance; alternative is nothing for
# slower runtime (faster compiles) -O2 for faster runtime (slower
# compiles), or -O for balance.
VERILATOR_MAKE_FLAGS = OPT_FAST="-O2"

# Targets
all: clean build verilator

clean:
	rm -rf logs *.log *.s *.hex *.dis *.tbl irun* vcs* simv* snapshots \
	verilator* *.exe obj* *.o ucli.key vc_hdrs.h csrc *.csv work


verilator-build: ${TBFILES} sim_main.cpp
	$(VERILATOR) --cc -CFLAGS ${CFLAGS} $(defines) \
	  -I${AZADI_ROOT}/tests -f ${AZADI_ROOT}/tests/flist \
	  --trace --trace-structs --trace-fst --trace-params --trace-max-array 1024 -CFLAGS -DVL_DEBUG -Wno-IMPLICIT -Wno-LITENDIAN -Wno-UNSIGNED -Wno-PINMISSING -Wno-UNOPTTHREADS -Wno-MODDUP -Wno-WIDTH -Wno-UNOPTFLAT -Wno-BLKANDNBLK --threads 4 -Wno-ALWCOMBORDER ${TBFILES} -LDFLAGS -lpthread --top-module Azadi_top_verilator \
	  -exe sim_main.cpp dmidpi.c jtagdpi.c tcp_server.c --autoflush --trace -DSYNTHESIS
#	cp ${AZADI_ROOT}/tests/sim_main.cpp obj_dir/
	$(MAKE) -C obj_dir/ -f VAzadi_top_verilator.mk $(VERILATOR_MAKE_FLAGS)
	touch verilator-build

verilator: verilator-build
	./obj_dir/VAzadi_top_verilator

build:
	@rm -rf $(TEST_DIR)/output 
	@mkdir $(TEST_DIR)/output
	$(GCC_PREFIX) $(GCC_FLAGS) -c $(TEST_DIR)/$(TEST).c -o $(TEST_DIR)/output/$(TEST) -lm -lgcc
	$(GCC_PREFIX) $(GCC_FLAGS) -c $(TEST_DIR)/common/plic_driver.c -o $(TEST_DIR)/output/plic -lm -lgcc
	$(GCC_PREFIX) $(GCC_FLAGS) -c $(TEST_DIR)/common/init.c -o $(TEST_DIR)/output/init -lm -lgcc
	$(GCC_PREFIX) $(GCC_FLAGS) -c $(TEST_DIR)/common/traps.c -o $(TEST_DIR)/output/traps -lm -lgcc
	$(GCC_PREFIX) $(LINK_FLAGS) $(TEST_DIR)/common/start.S $(TEST_DIR)/common/trap.S $(TEST_DIR)/output/$(TEST) $(TEST_DIR)/output/plic $(TEST_DIR)/output/traps $(TEST_DIR)/output/init -o $(TEST_DIR)/output/$(TEST).merl -lgcc
	$(OBJDUMP_PREFIX) $(OBJDUMP_FLAGS) $(TEST_DIR)/output/$(TEST).merl > $(TEST_DIR)/output/$(TEST).dump
	$(RISCV_PREFIX)elf2hex --bit-width 32 --input $(TEST_DIR)/output/$(TEST).merl --output $(TEST_DIR)/output/program.hex

help:
	@echo Make sure the environment variable AZADI_ROOT is set.
	@echo Possible targets: verilator vcs irun vlog help clean all verilator-build irun-build vcs-build program.hex

.PHONY: help build clean verilator

#riscv32-unknown-elf-elf2hex --bit-width 32 --input test --output prog.hex