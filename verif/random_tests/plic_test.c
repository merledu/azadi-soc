#include "gpio.h"
#include "trap.h"
#include "timer.h"
#include "platform.h"
#include "plic.h"
#include "plic-regs.h"


// void handle_button_press(__attribute__((unused)) uint32_t num);

// void handle_button_press(__attribute__((unused)) uint32_t num)
// {
//   	uint32_t state = gpio_read_pin(5);
	
// 	if(state == 0)
// 		gpio_direct_write(10, 1); 
// }



int main(void){

	// gpio_intr_enable(3);
	// gpio_intr_type(3);
	
	// plic_init(13);
	


	gpio_direct_write_enable(6);
	gpio_direct_write(6, 1);
		
	delay(11000000);

	gpio_direct_write_enable(7);
	gpio_direct_write(7, 1);

	delay(11000000);

	gpio_direct_write_enable(8);
	gpio_direct_write(8, 1);



	

	// // Enable Global (PLIC) interrupts.
	// asm volatile("li      t0, 8\t\n"
	// 	     "csrrs   zero, mstatus, t0\t\n"
	// 	    );

	// // Enable Local (PLIC) interrupts.
	// asm volatile("li      t0, 0x800\t\n"
	// 	     "csrrs   zero, mie, t0\t\n"
	// 	    );
	// return 0;
}
