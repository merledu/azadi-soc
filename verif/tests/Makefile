TEST     = basic-test
TESTNAME = test.s

LINKERFILE = link.ld
LINKERPATH = $(PWD)/tests/$(LINKERFILE)
NAME       = $(abspath $(basename $(TESTNAME)))

GCC     = riscv64-unknown-elf-gcc
OBJCOPY = riscv64-unknown-elf-objcopy
OBJDUMP = riscv64-unknown-elf-objdump

ABI = -mabi=ilp32 -march=rv32imfc

# 16b and 32b instructions
GCC_OPT =-nostdlib -nostartfiles -Wl,--no-relax -Wa,-als,-al
GCC_LINK_OPT =-nostdlib -nostartfiles -Wl,--no-relax -Wa,-als,-al

hex: clean $(NAME).elf $(NAME).dis
	$(OBJCOPY) -O verilog $(NAME).elf $(NAME).hex 
	@echo '00 FF FF 00' >> $(NAME).hex
	python3 $(PWD)/tests/qspi-hex.py $(NAME).hex

# objdump -D can be used to disassemble all sections
$(NAME).dis: $(NAME).elf
	$(OBJDUMP) -M numeric -d --section=.boot --section=.text $(NAME).elf > $(NAME).dis

$(NAME).elf: $(NAME).s
	$(GCC) $(ABI) $(GCC_LINK_OPT) -T$(LINKERPATH) -o $(NAME).elf $(NAME).s

.PHONY: clean hex

clean:
	rm -f *.o *.elf *.hex *.dis
