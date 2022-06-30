TEST         = test.s
INSTALL_DIR = $(abspath $(INSTALL_PATH) )

LINKERFILE = link.ld
NAME       = $(basename $(TEST) )


GCC     = riscv64-unknown-elf-gcc
OBJCOPY = riscv64-unknown-elf-objcopy
OBJDUMP = riscv64-unknown-elf-objdump

# 16b and 32b instructions
GCC_OPT =-nostdlib -nostartfiles -Wl,--no-relax -Wa,-als,-al
GCC_LINK_OPT =-nostdlib -nostartfiles -Wl,--no-relax -Wa,-als,-al

# objdump -D can be used to disassemble all sections
$(NAME).dis: $(NAME).elf $(NAME).hex
	$(OBJDUMP) -M numeric -d --section=.boot --section=.text $(NAME).elf > $(NAME).dis

$(NAME).o: $(NAME).s
	$(GCC) -Wa,-als,-al -c -o $(NAME).o $(NAME).s

$(NAME).elf: $(NAME).o $(LINKERFILE)
	$(GCC) $(GCC_LINK_OPT) -T$(LINKERFILE) -o $(NAME).elf $(NAME).o

$(NAME).hex: $(NAME).elf
	$(OBJCOPY) -O verilog $(NAME).elf $(NAME).hex

.PHONY: clean

clean:
	@rm -f $(NAME).o $(NAME).elf $(NAME).hex $(NAME).dis