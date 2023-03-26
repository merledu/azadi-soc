RISCV_DV_COMMIT ?= 3da32bbf6080d3bf252a7f71c5e3a32ea4924e49
AZADI_COMMIT ?= c4b32375365bf18e352f6ee6c102ca19785f5f42
REGR := regr
REGR-DIR := $(dir $(DV_AZADI_TSMC)/$(REGR)/)
gen-regr := $(REGR-DIR)

all: simulate

.PHONY: all

$(gen-regr): %:
	mkdir -p $@

setup: env verify

env: google_riscv-dv azadi-new

$(DV_AZADI_TSMC)/google_riscv-dv:
	git clone https://github.com/google/riscv-dv.git $(DV_AZADI_TSMC)/google_riscv-dv

google_riscv-dv: check-env $(DV_AZADI_TSMC)/google_riscv-dv
	cd $(DV_AZADI_TSMC)/google_riscv-dv && \
		git checkout master && git pull && \
		git checkout -qf $(RISCV_DV_COMMIT)


$(DV_AZADI_TSMC)/azadi-new:
	git clone https://github.com/merledu/azadi-new.git $(DV_AZADI_TSMC)/azadi-new

azadi-new: check-env $(DV_AZADI_TSMC)/azadi-new
	cd $(DV_AZADI_TSMC)/azadi-new && \
		git checkout main && git pull && \
		git checkout -qf $(AZADI_COMMIT)

verify: $(gen-regr)
	cd $(DV_AZADI_TSMC)/regr && \
	make -f $(DV_AZADI_TSMC)/random_tests/env/core/vendor/core_ibex/Makefile TEST=riscv_arithmetic_basic_test ITERATIONS=1

simulate:
	make -f $(DV_AZADI_TSMC)/random_tests/env/core/vendor/core_ibex/Makefile


check-env:
ifndef DV_AZADI_TSMC
	$(error DV_AZADI_TSMC is undefined, please export it before running make)
endif