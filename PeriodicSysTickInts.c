// PeriodicSysTickInts.c
// Runs on LM4F120
// Use the SysTick timer to request interrupts at a particular period.
// Daniel Valvano
// October 11, 2012

/* This example accompanies the book
   "Embedded Systems: Real Time Interfacing to Arm Cortex M Microcontrollers",
   ISBN: 978-1463590154, Jonathan Valvano, copyright (c) 2014

   Program 5.12, section 5.7

 Copyright 2014 by Jonathan W. Valvano, valvano@mail.utexas.edu
    You may use, edit, run or distribute this file
    as long as the above copyright notice remains
 THIS SOFTWARE IS PROVIDED "AS IS".  NO WARRANTIES, WHETHER EXPRESS, IMPLIED
 OR STATUTORY, INCLUDING, BUT NOT LIMITED TO, IMPLIED WARRANTIES OF
 MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE APPLY TO THIS SOFTWARE.
 VALVANO SHALL NOT, IN ANY CIRCUMSTANCES, BE LIABLE FOR SPECIAL, INCIDENTAL,
 OR CONSEQUENTIAL DAMAGES, FOR ANY REASON WHATSOEVER.
 For more information about my classes, my research, and my books, see
 http://users.ece.utexas.edu/~valvano/
 */

// oscilloscope or LED connected to PF2 for period measurement
#include <stdint.h>
#include "tm4c123gh6pm.h"

#include "SysTickInts.h"
#include "PLL.h"

#include <stdio.h>
#include "utils/uartstdio.h"
//#include "ECE251_util.h"


#define PF2     (*((volatile uint32_t *)0x40025018))

void output(int length, int time);
extern void setup(void);
extern void next(void);
extern int loop1(void);
void DisableInterrupts(void); // Disable interrupts
void EnableInterrupts(void);  // Enable interrupts
long StartCritical (void);    // previous I bit, disable interrupts
void EndCritical(long sr);    // restore I bit to previous value
void WaitForInterrupt(void);  // low power mode
volatile uint32_t Counts = 0;

int main(void){
//  PLL_Init();                 // bus clock at 80 MHz
  SYSCTL_RCGCGPIO_R |= 0x20;  // activate port F
  Counts = 0;
  GPIO_PORTF_DIR_R |= 0x06;   // make PF2,1 outputs (PF2,1 built-in LEDs)
  GPIO_PORTF_AFSEL_R &= ~0x06;// disable alt funct on PF2,1
  GPIO_PORTF_DEN_R |= 0x06;   // enable digital I/O on PF2,1
                              // configure PF2,1 as GPIO
//  GPIO_PORTF_PCTL_R = (GPIO_PORTF_PCTL_R&0xFFFFF00F)+0x00000000;
  GPIO_PORTF_AMSEL_R = 0;     // disable analog functionality on PF
  SysTick_Init(8000000);        // initialize SysTick timer
  EnableInterrupts();
	PF2 = 0x02;		// Turn on PF1 (Red)
	
	int lengthOfRod = 5000000; //5cm
	int countAtTrigger = 0;
	int totalCount;
	
	
	SystemInit();
	ConfigureUART();
	setup();
	
  while(1){                   // interrupts every 1ms, 500 Hz flash
    WaitForInterrupt();
		if(loop1() == 0xE){
			countAtTrigger = Counts;
			next();
		}
		if(loop1() == 0xF && countAtTrigger != 0){
					totalCount = Counts - countAtTrigger;
					output(lengthOfRod, totalCount);
		}
			
  }
}

// Interrupt service routine
// Executed every 12.5ns*(period)
void SysTick_Handler(void){
  PF2 ^= 0x04;                // toggle PF2 (Blue)
  PF2 ^= 0x02;                // toggle PF1 (Red)
  Counts = Counts + 1;
}

void output(int length, int time){
		double speed = ((double)length / 100000000) / (time * 12.5 * 1000000000);
		UARTprintf("Speed of projectile is: %f",speed);
}
