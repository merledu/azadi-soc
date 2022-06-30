#ifndef TRAPS_H
#define TRAPS_H
#include <stdint.h>
#define MAX_MCAUSE_VALUE    2


#define MAX_INTERRUPT_VALUE 1
#define MACH_EXTERNAL_INTERRUPT 0

#define MAX_TRAP_VALUE                 1
#define INSTRUCTION_ADDRESS_MISALIGNED  0

typedef void (*mtrap_fptr_t) (uintptr_t trap_cause, uintptr_t epc);
extern mtrap_fptr_t mcause_trap_table[MAX_TRAP_VALUE];
extern mtrap_fptr_t mcause_interrupt_table[MAX_INTERRUPT_VALUE];
void default_handler(uintptr_t cause, uintptr_t epc);
unsigned int extract_ie_code(unsigned int num);
uintptr_t handle_trap(uintptr_t cause, uintptr_t epc);

#endif
