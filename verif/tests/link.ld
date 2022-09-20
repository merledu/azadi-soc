OUTPUT_ARCH("riscv")
ENTRY( _start )

MEMORY 
{
ICCM  : ORIGIN = 0x10000000, LENGTH = 8K 
DCCM  : ORIGIN = 0x20000000, LENGTH = 8K
}

SECTIONS
{
.text :
 {
     _stext = .;
     *(.text) 
     _etext = .;
 }>ICCM

.data :
 {
    _sdata = .;
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
