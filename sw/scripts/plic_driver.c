
#include "plic_driver.h"
#include "utils.h"


plic_fptr_t isr_table[PLIC_MAX_INTERRUPT_SRC];
interrupt_data_t hart0_interrupt_matrix[PLIC_MAX_INTERRUPT_SRC];

void interrupt_complete(uint32_t interrupt_id)
{

	uint32_t *claim_addr =  (uint32_t *) (PLIC_BASE_ADDRESS +
					      PLIC_CLAIM_OFFSET);

	*claim_addr = interrupt_id;
	hart0_interrupt_matrix[interrupt_id].state = SERVICED;
	hart0_interrupt_matrix[interrupt_id].count++;
}

uint32_t interrupt_claim_request()
{
	uint32_t *interrupt_claim_address = NULL;
	uint32_t interrupt_id;
	interrupt_claim_address = (uint32_t *)(PLIC_BASE_ADDRESS +
					       PLIC_CLAIM_OFFSET);
	interrupt_id = *interrupt_claim_address;
	return interrupt_id;
}

void mach_plic_handler( __attribute__((unused)) uintptr_t int_id, __attribute__((unused)) uintptr_t epc)
{
	uint32_t  interrupt_id;

	interrupt_id = interrupt_claim_request();

		hart0_interrupt_matrix[interrupt_id].state = ACTIVE;


	isr_table[interrupt_id](interrupt_id);

	interrupt_complete(interrupt_id);
}
void interrupt_enable(uint32_t interrupt_id)
{
	uint8_t *interrupt_enable_addr;
	uint8_t current_value = 0x00, new_value;

	interrupt_enable_addr = (uint8_t *) (PLIC_BASE_ADDRESS +
			PLIC_ENABLE_OFFSET +
			((interrupt_id) >> 3));

	current_value = *interrupt_enable_addr;

	/*set the bit corresponding to the interrupt src*/
	new_value = current_value | (0x1 << (interrupt_id % 8));

	*((uint8_t*)interrupt_enable_addr) = new_value;
}
void interrupt_disable(uint32_t interrupt_id)
{
	uint8_t *interrupt_disable_addr = 0;
	uint8_t current_value = 0x00, new_value;


	interrupt_disable_addr = (uint8_t *) (PLIC_BASE_ADDRESS +
					      PLIC_ENABLE_OFFSET +
					      (interrupt_id >> 3));

	current_value = *interrupt_disable_addr;


	/*unset the bit corresponding to the interrupt src*/
	new_value = current_value & (~(0x1 << (interrupt_id % 8)));

	*interrupt_disable_addr = new_value;

	hart0_interrupt_matrix[interrupt_id].state = INACTIVE;
}
void set_interrupt_threshold(uint32_t priority_value)
{

	uint32_t *interrupt_threshold_priority = NULL;

	interrupt_threshold_priority = (uint32_t *) (PLIC_BASE_ADDRESS +
						     PLIC_THRESHOLD_OFFSET);

	*interrupt_threshold_priority = priority_value;

}
void set_interrupt_priority(uint32_t priority_value, uint32_t int_id)
{
	log_trace("\n set interrupt priority entered %x\n", priority_value);

	uint32_t * interrupt_priority_address;

	/*
	   base address + priority offset + 4*interruptId
	 */

	interrupt_priority_address = (uint32_t *) (PLIC_BASE_ADDRESS +
						   PLIC_PRIORITY_OFFSET +
						   (int_id <<
						    PLIC_PRIORITY_SHIFT_PER_INT));

	log_debug("interrupt_priority_address = %x\n", interrupt_priority_address);

	log_debug("current data at interrupt_priority_address = %x\n", *interrupt_priority_address);

	*interrupt_priority_address = priority_value;

}



void plic_init()
{
	uint32_t int_id = 0;


	mcause_interrupt_table[MACH_EXTERNAL_INTERRUPT] = mach_plic_handler;

	hart0_interrupt_matrix[0].state = INACTIVE;
	hart0_interrupt_matrix[0].id = 0;
	hart0_interrupt_matrix[0].priority = 0;
	hart0_interrupt_matrix[0].count = 0;

	for(int_id = 1; int_id < PLIC_MAX_INTERRUPT_SRC; int_id++)
	{
		hart0_interrupt_matrix[int_id].state = INACTIVE;
		hart0_interrupt_matrix[int_id].id = int_id;
		hart0_interrupt_matrix[int_id].priority = PLIC_PRIORITY_3;
		hart0_interrupt_matrix[int_id].count = 0;

		interrupt_disable(int_id);

		/*assign a default isr for all interrupts*/
		isr_table[int_id] = isr_default;

		/*set priority for all interrupts*/

		set_interrupt_priority(PLIC_PRIORITY_3, int_id);
	}

	set_interrupt_threshold(PLIC_PRIORITY_2);

}


void configure_interrupt(uint32_t int_id)
{
	log_trace("\nconfigure_interrupt entered \n");

	/*
	   Call only for GPIO pins
	 */
	if(int_id >6 && int_id < 22)
	{
		configure_interrupt_pin(int_id);
	}

	interrupt_enable(int_id);

}

