OUTPUT_FORMAT("elf32-littleriscv", "elf32-littleriscv",
	      "elf32-littleriscv")
OUTPUT_ARCH(riscv)

MEMORY 
{
ICCM  : ORIGIN = 0x20000000, LENGTH = 4K 
DCCM  : ORIGIN = 0x10000000, LENGTH = 4K
}

ENTRY(_start)
SECTIONS
{
PROVIDE( __stack_top = ORIGIN(DCCM) + LENGTH(DCCM));
.init :
{
  KEEP (*(SORT_NONE(.init)))
}>ICCM
.text :
 {
     _stext = .;
     *(.text) 
     _etext = .;
 }>ICCM
.data :
 {
    _sdata = .;
   __global_pointer$ = _sdata + 0x000;
    *(.data)
    _edata = .;
 }>DCCM
.bss :
 {
    _sbss = .;
    *(.bss)
    _ebss = .;
 }>DCCM
}
