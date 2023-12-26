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
	.def	crosscounter = r23						; main register for count the number of times the signal passed 3.3V

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

	clr		crosscounter							; initialize the counter

	wdr
	lds		ctrl, WDTCSR
	ori		ctrl ,(1<<WDE)|(1<<WDCE)				; enable watchdog interrupts
	sts		WDTCSR, ctrl

	ldi		ctrl, (1<<WDIE) | (1<<WDP2) | (1<<WDP1)	; set watchdog timer for one second
	sts		WDTCSR, ctrl

	ldi		ctrl, (1<<2)		
	sts		EICRA, ctrl								; interrupt call for logical change at INT1

	ldi		ctrl, (1<<1)
	out		EIMSK, ctrl								; enable exteranl interrupt request 1

	sei												; enable global interrupts


main_loop:
	sbrc	onesecpassed,0							; if one second timer passed
	rjmp	output_handler							; somethings there in the output
	; controls main loop depending on auto/manual conditions
	in		ctrl, PINB								; take PINB states
	sbrs	ctrl, 6									; check for auto/manual conditions
	rjmp	manual
	rjmp	auto

manual:												; controlling manual controlling
	ldi		r18, (1<<PB4) | (1<<PB5) | (1<<PB6)		; ignore ports controlling the motor driver
	and		ctrl, r18
	sbrc	ctrl, 4									; skip if clockwise button is not pressed
	rjmp	step_rotate_clockwise
	sbrc	ctrl, 5									; skip if anticlockwise button is not pressed
	rjmp	step_rotate_anticlockwise
	rjmp	setzero_pos								; if non of them is pressed set all ports to 0
	rjmp	main_loop


auto:
	rjmp	main_loop

output_handler:
	in		ctrl, PIND
	ori		ctrl, (1<<1)
	out		PORTD, ctrl
	ldi		crosscounter, 0x00						; set crosscounter back to 0
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
	ldi		ctrl, 0x01	
	add		crosscounter, ctrl						; add one to the counter

	in		ctrl, PIND
	ori		ctrl, (1<<0)
	out		PORTD, ctrl

	reti

.include	"led_controller.asm"
.include	"delay.asm"
.include	"motor_controller.asm"
