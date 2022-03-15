OUTPUT_ARCH("riscv")
ENTRY( _start )

MEMORY 
{
ICCM  : ORIGIN = 0x20000000, LENGTH = 4K 
DCCM  : ORIGIN = 0x10000000, LENGTH = 4K
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
