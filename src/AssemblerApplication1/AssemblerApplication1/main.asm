;
; Automatic_Tuner.asm
;
; Created: 17/11/2023 6:55:35 PM
; Authors : Buddhi Wijenayake
;			Athulya Ratnayake
;			Thimira Hirushan

.include "m328pdef.inc"
	
	.equ	mot_in1 = 0								; define motor driver input pin1
	.equ	mot_in2 = 1								; define motor driver input pin2
	.equ	mot_in3 = 2								; define motor driver input pin3
	.equ    mot_in4 = 3								; define motor driver input pin4
	
	.def	ctrl = r16								; define temporary register to controlling
	.def	delayr  = r17							; define delay counter register

	.def	onesecpassed = r21						; check one second passed

	.def	freq_map = r18							; controls motor in automatic mode 
	; 0th bit -> LOW
	; 1st bit -> OK
	; 2nd bit -> HIGH

	.def	crosscounterL = r23						; low register for count the number of times the signal passed 3.3V
	.def	crosscounterH = r22						; high register for crosscounter

	.def	freq_lowerbound = r19					; lower register used to compare results
	.def	freq_upperbound = r20					; upper register used to compare the results

	.cseg 
	.org	0x00									; set instruction starting address to 0x00
		jmp	setup
	.org	0x004									; interrupt call for zero crossing
		jmp		isr_int1
	.org	0x000C									; for watchdog interrupt
		jmp		WDT
	
setup:
	ldi 	ctrl, (1<<PD0) | (1<<PD1) | (1<<PD2)
	out		DDRD, ctrl								; set output ports in PORTD
	ldi		ctrl, (1<<PB0) | (1<<PB1) | (1<<PB2) | (1<<PB3)
	out		DDRB, ctrl								; set output ports in PORTB

	clr		crosscounterL							; initialize the counter
	clr		crosscounterH

	wdr
	lds		ctrl, WDTCSR
	ori		ctrl ,(1<<WDE)|(1<<WDCE)				; enable watchdog interrupts
	sts		WDTCSR, ctrl

	ldi		ctrl, (1<<WDIE) | (1<<WDP2) | (1<<WDP1)	; set watchdog timer for one second
	sts		WDTCSR, ctrl

	ldi		ctrl, (1<<2)|(1<<3)						; interrupt call for a rising edge		
	sts		EICRA, ctrl								; interrupt call for logical change at INT1

	ldi		ctrl, (1<<1)
	out		EIMSK, ctrl								; enable exteranl interrupt request 1

	sei												; enable global interrupts

	ldi		ctrl, (1<<0)|(1<<2)
	out		SMCR, ctrl								; enable power off when there's nothing on INT1


main_loop:
	sbrc	onesecpassed,0							; if one second timer passed
	rjmp	output_handler							; somethings there in the output
	; controls main loop depending on auto/manual conditions
	in		ctrl, PINB								; take PINB states
	sbrs	ctrl, 6									; check for auto/manual conditions
	rjmp	manual
	rjmp	auto

manual:												; controlling manual controlling
	sbrc	ctrl, 4									; skip if clockwise button is not pressed
	rcall	step_rotate_clockwise
	sbrc	ctrl, 5									; skip if anticlockwise button is not pressed
	rcall	step_rotate_anticlockwise
	rcall	setzero_pos								; if non of them is pressed set all ports to 0
	rjmp	main_loop


auto:
	sbrc	freq_map, 0								; skip if 0th bit is 0
	rcall	step_rotate_clockwise					; tune up
	
	sbrc	freq_map, 1								; skip if 1th bit is 0
	rcall	setzero_pos								; tuning is stopped

	sbrc	freq_map, 2								; skip if 2nd bit is 0
	rcall	step_rotate_anticlockwise				; tune down

	rjmp	main_loop

output_handler:
;	in		ctrl, PIND								; Debugger code
;	ori		ctrl, (1<<1)
	;out		PORTD, ctrl
	
	rcall	indicator

	ldi		crosscounterL, 0x00						; set crosscounter back to 0
	ldi		crosscounterH, 0x00

	ldi		onesecpassed, 0x00						; set onesecpassed back to 0	
										
	wdr												; start timed sequence
	lds		ctrl, WDTCSR
	ori		ctrl ,(1<<WDE)|(1<<WDCE)				; enable watchdog interrupts
	sts		WDTCSR, ctrl

	ldi		ctrl, (1<<WDIE) | (1<<WDP2) | (1<<WDP1)	; set watchdog timer for one second
	sts		WDTCSR, ctrl

	sei												; enable global interrupts
	rjmp	main_loop

WDT:												; interrupt handler for watchdog timers
	cli												; disable interrupts
	ldi		onesecpassed, 0x01
	reti


isr_int1:
;	in		ctrl, PIND								; Debugger code 
;	ori		ctrl, (1<<0)
;	out		PORTD, ctrl

	inc		crosscounterL							; increment the lower register
	brne	no_overflow								; branch if no overflow i.e (0x00)

	inc		crosscounterH							; increment the higher register at an overflow

	reti

no_overflow:
	reti											; close the interrupt routine at no overflow


.include	"led_controller.asm"
.include	"delay.asm"
.include	"motor_controller.asm"
.include	"output_controller.asm"
