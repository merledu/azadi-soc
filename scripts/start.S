.section .init, "ax"
.global _start
_start:
la t0 , trap_entry
csrw mtvec, t0

li  x1, 0
li  x2, 0
li  x3, 0
li  x4, 0
li  x5, 0
li  x6, 0
li  x7, 0
li  x8, 0
li  x9, 0
li  x10,0
li  x11,0
li  x12,0
li  x13,0
li  x14,0
li  x15,0
li  x16,0
li  x17,0
li  x18,0
li  x19,0
li  x20,0
li  x21,0
li  x22,0
li  x23,0
li  x24,0
li  x25,0
li  x26,0
li  x27,0
li  x28,0
li  x29,0
li  x30,0
li  x31,0
    .cfi_startproc
    .cfi_undefined ra
    .option push
    .option norelax
    la gp, __global_pointer$ 
    .option pop
    la sp, __stack_top
    add s0, sp, zero
    jal zero, main
    .cfi_endproc
    .end
