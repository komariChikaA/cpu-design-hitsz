/*
	File : core_portme.c
*/
#include <stdio.h>
#include <stdlib.h>
#include "coremark.h"
#include "core_portme.h"
//#include "sc_test.h"

#if VALIDATION_RUN
	volatile ee_s32 seed1_volatile=0x3415;
	volatile ee_s32 seed2_volatile=0x3415;
	volatile ee_s32 seed3_volatile=0x66;
#endif
#if PERFORMANCE_RUN
	volatile ee_s32 seed1_volatile=0x0;
	volatile ee_s32 seed2_volatile=0x0;
	volatile ee_s32 seed3_volatile=0x66;
#endif
#if PROFILE_RUN
	volatile ee_s32 seed1_volatile=0x8;
	volatile ee_s32 seed2_volatile=0x8;
	volatile ee_s32 seed3_volatile=0x8;
#endif

	volatile ee_s32 seed4_volatile=ITERATIONS;
	volatile ee_s32 seed5_volatile=0;

/* Porting : Timing functions
	How to capture time and convert to seconds must be ported to whatever is supported by the platform.
	e.g. Read value from on board RTC, read value from cpu clock cycles performance counter etc.
	Sample implementation for standard time.h and windows.h definitions included.
*/
#if 1

#define MHZ 50     // CPU Clock Frequency
#define CLOCKS_PER_SEC (1000000 * MHZ)

#define TIMER_BASE  0xFFFF4000
#define LED_BASE    0xFFFF1000
#define DIG_BASE    0xFFFF2000

#ifndef STUDENT_ID
#define STUDENT_ID "2024311081_2024311453"
#endif

/*  | offset | read op               | write op      |
    |--------+-----------------------+---------------|
    | 0x00   | read timer (low 32b)  | undefined     |
    | 0x08   | read timer (high 32b) | undefined     |
*/

// read op
volatile unsigned int *timer_low  = (volatile unsigned int*) TIMER_BASE;
volatile unsigned int *timer_high = (volatile unsigned int*)(TIMER_BASE + 8);
volatile unsigned int *board_led  = (volatile unsigned int*) LED_BASE;
volatile unsigned int *board_dig  = (volatile unsigned int*) DIG_BASE;

time_l get_time(void)
{
    time_l t_h_before;
    time_l t_l;
    time_l t_h_after;

    do {
        t_h_before = *timer_high;
        t_l = *timer_low;
        t_h_after = *timer_high;
    } while (t_h_before != t_h_after);

    return (t_h_after << 32) | (t_l & 0x00000000FFFFFFFFLL);
}

// #define INSNC ((unsigned int volatile *)0x20000060) //trace and debug unit

/* Define : TIMER_RES_DIVIDER
	Divider to trade off timer resolution and total time that can be measured.

	Use lower values to increase resolution, but make sure that overflow does not occur.
	If there are issues with the return value overflowing, increase this value.
	*/
/* #define NSECS_PER_SEC CLOCKS_PER_SEC */
/* #define CORETIMETYPE clock_t */
#define MYTIMEDIFF(fin,ini) ((fin)-(ini))
#define TIMER_RES_DIVIDER 1
#define SAMPLE_TIME_IMPLEMENTATION 1
#define EE_TICKS_PER_SEC (CLOCKS_PER_SEC / TIMER_RES_DIVIDER)
#else

#endif
/** Define Host specific (POSIX), or target specific global time variables. */
static CORETIMETYPE start_time_val, stop_time_val;

/* Function : start_time
	This function will be called right before starting the timed portion of the benchmark.

	Implementation may be capturing a system timer (as implemented in the example code)
	or zeroing some system parameters - e.g. setting the cpu clocks cycles to 0.
*/
void start_time(void) {	start_time_val = get_time(); }
/* Function : stop_time
	This function will be called right after ending the timed portion of the benchmark.

	Implementation may be capturing a system timer (as implemented in the example code)
	or other system parameters - e.g. reading the current value of cpu cycles counter.
*/
void stop_time(void) { stop_time_val = get_time(); }

/* Function : get_time_elasped
	Return an abstract "ticks" number that signifies time on the system.

	Actual value returned may be cpu cycles, milliseconds or any other value,
	as long as it can be converted to seconds by <time_in_secs>.
	This methodology is taken to accomodate any hardware or simulated platform.
	The sample implementation returns millisecs by default,
	and the resolution is controlled by <TIMER_RES_DIVIDER>
*/
CORE_TICKS get_time_elasped(void) {
	CORE_TICKS elapsed = (CORE_TICKS)(MYTIMEDIFF(stop_time_val, start_time_val));
	return elapsed;
}
/* Function : time_in_secs
	Convert the value returned by get_time_elasped to seconds.

	The <secs_ret> type is used to accomodate systems with no support for floating point.
	Default implementation implemented by the EE_TICKS_PER_SEC macro above.
*/
secs_ret time_in_secs(CORE_TICKS ticks) {
	secs_ret retval=((secs_ret)ticks) / (secs_ret)EE_TICKS_PER_SEC;
	return retval;
}

ee_u32 default_num_contexts=1;

/* Function : portable_init
	Target specific initialization code
	Test for some common mistakes.
*/
void delay_ms(int ms){
	time_l t0 = get_time();
	time_l delay_ticks = ((time_l)ms * CLOCKS_PER_SEC) / 1000;
	while ((get_time() - t0) < delay_ticks)
		;
}

void portable_init(core_portable *p, int *argc, char *argv[])
{
	*board_led = 0xC001u;
	*board_dig = 0xC0010000u;
	delay_ms(100);
	ee_printf("miniRV Pipeline AXI EGO1 CoreMark\n");
	ee_printf("Student IDs: %s\n", STUDENT_ID);
	ee_printf("CPU clock: %d MHz\n", MHZ);
	ee_printf("CoreMark 1.0\n");

	if (sizeof(ee_ptr_int) != sizeof(ee_u8 *))
		ee_printf("ERROR! Please define ee_ptr_int to a type that holds a pointer! (%u != %u)\n", sizeof(ee_ptr_int), sizeof(ee_u8 *));
	if (sizeof(ee_u32) != 4)
		ee_printf("ERROR! Please define ee_u32 to a 32b unsigned type! (%u)\n", sizeof(ee_u32));

	p->portable_id=1;
}

void board_result(ee_s16 total_errors)
{
	if (total_errors == 0) {
		*board_led = 0xC0A5u;
		*board_dig = 0xC0DE600Du;
	} else if (total_errors > 0) {
		*board_led = 0xE000u | ((unsigned int)total_errors & 0xFFu);
		*board_dig = 0xE0000000u | ((unsigned int)total_errors & 0xFFFFu);
	} else {
		*board_led = 0xE0FFu;
		*board_dig = 0xE0FF0000u;
	}
}
/* Function : portable_fini
	Target specific final code
*/


void portable_fini(core_portable *p)
{
	 //
	CORE_TICKS total_time = get_time_elasped();

	// float Cycles_Per_Instruction = ((float) total_time)/((float) INSNC[2]);
	float CoreMark_Per_MHZ = ((float)(ITERATIONS*1000000)) / ((float)total_time);
	float CoreMark = CoreMark_Per_MHZ * MHZ;
	// ee_printf("Cycles_Per_Instruction: %f\n",Cycles_Per_Instruction);
	ee_printf("CoreMark 1.0 : %f\n", CoreMark);
	ee_printf("CoreMark/MHz : %f\n", CoreMark_Per_MHZ);

	ee_printf("FINISH\n");

}
