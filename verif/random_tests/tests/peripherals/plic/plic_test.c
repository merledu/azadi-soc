/***************************************************************************
 * Project           		: shakti devt board
 * Name of the file	     	: interrupt_demo.c
 * Brief Description of file    : A application to demonstrate working of plic
 * Name of Author    	        : Sathya Narayanan N
 * Email ID                     : sathya281@gmail.com

 Copyright (C) 2019  IIT Madras. All rights reserved.

 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <https://www.gnu.org/licenses/>.

 ***************************************************************************/
/**
  @file interrupt_demo.c
  @brief A application to demonstrate working of plic
  @detail Thsi file contains an application to demonstrate the working of plic.
  The interrupts are enabled for a gpio pin. Once the button connected to the gpio
  pin is pressed. An interrupt is generated and it is handled by the isr.
 */

#include "gpio.h"
#include "trap.h"
#include "platform.h"
#include "plic.h"
#include "plic-regs.h"

/** @fn main
 * @brief sets up the environment for plic feature
 * @return int
 */

#define pin 8

int main(void){
	register unsigned int retval;
	int i;

	uint32_t *gpio_intr; 
	gpio_intr = (uint32_t *)(GPIO_START + GPIO_INTR_ENABLE_REG_OFFSET);
	*gpio_intr = 8;
	
	uint32_t *lvlhigh;
	lvlhigh = (uint32_t *)(GPIO_START + GPIO_INTR_CTRL_EN_LVLHIGH_REG_OFFSET);
	*lvlhigh = 8;

	plic_set_threshold(2);
	plic_set_priority(3, 3);
	//1 on third pin
	plic_enable_interrupt(3, 8);
	
	

	// //init plic module
	// plic_init();

	// //configure interrupt id 7
	// configure_interrupt(3);


	//set the corresponding isr for interrupt id 7
	// isr_table[PLIC_INTERRUPT_3] = handle_button_press;

	// // Enable Global (PLIC) interrupts.
	// asm volatile("li      t0, 8\t\n"
	// 	     "csrrs   zero, mstatus, t0\t\n"
	// 	    );

	// // Enable Local (PLIC) interrupts.
	// asm volatile("li      t0, 0x800\t\n"
	// 	     "csrrs   zero, mie, t0\t\n"
	// 	    );
	return 0;
}
