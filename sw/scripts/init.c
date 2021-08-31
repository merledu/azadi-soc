#include "Trap.h"
#include "plic_driver.h"
static void trap_init(void)
{
	mcause_interrupt_table[MACH_EXTERNAL_INTERRUPT]  = mach_plic_handler;

    mcause_trap_table[INSTRUCTION_ADDRESS_MISALIGNED] = default_handler;
}

void init(void)
{
	trap_init();

	main();
}
