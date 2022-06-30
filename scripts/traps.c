#include "Trap.h"
mtrap_fptr_t mcause_trap_table[MAX_TRAP_VALUE];
mtrap_fptr_t mcause_interrupt_table[MAX_INTERRUPT_VALUE];

unsigned int extract_ie_code(unsigned int num)
{
	unsigned int exception_code;
	exception_code = (num & 0X7FFFFFFF);
	return exception_code;
}
void default_handler(__attribute__((unused)) uintptr_t mcause, __attribute__((unused)) uintptr_t epc)
{
	while(1);
}

uintptr_t handle_trap(uintptr_t mcause, uintptr_t epc)
{
	unsigned int ie_entry = 0;;
	uint32_t shift_length = 0;

	shift_length = __riscv_xlen - 1;

	 /* checking for type of trap */
	if (mcause & (1 << (shift_length))){

		ie_entry = extract_ie_code(mcause);


		mcause_interrupt_table[ie_entry](mcause, epc);
	}
	else{
		

		mcause_trap_table[mcause](mcause, epc);
	}
return epc;
}
