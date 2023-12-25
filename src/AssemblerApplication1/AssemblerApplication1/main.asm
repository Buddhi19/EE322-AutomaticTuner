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

	.cseg 
	.org	0x00									; set instruction starting address to 0x00
		jmp	setup
	.org	0x02									; interrupt call for zero crossing
	
	.org	0x000C									; for watchdog interrupt
		jmp	times_up
	
setup:
	ldi 	ctrl, (1<<PD0) | (1<<PD1) | (1<<PD2)
	out		DDRD, ctrl								; set output ports in PORTD
	ldi		ctrl, (1<<PB0) | (1<<PB1) | (1<<PB2) | (1<<PB3)
	out		DDRB, ctrl								; set output ports in PORTB

	ldi		ctrl, (1<<6)
	sts		WDTCSR, ctrl			; enable watchdog interrupt

	sei		; enable global interrupts

	wdr		; start watchdog timer


main_loop:
	sbrc	onesecpassed,0			; if one second timer passed
	rjmp	output_handler			; somethings there in the output
	; controls main loop depending on auto/manual conditions
	in		ctrl, PINB						; take PINB states
	sbrs	ctrl, 6							; check for auto/manual conditions
	rjmp	manual
	rjmp	auto

manual:
	; controlling manual controlling
	ldi		r18, (1<<PB4) | (1<<PB5) | (1<<PB6)		; ignore ports controlling the motor driver
	and		ctrl, r18
	sbrc	ctrl, 4
	rjmp	step_rotate_clockwise
	sbrc	ctrl, 5
	rjmp	step_rotate_anticlockwise
	rjmp	setzero_pos
	rjmp	main_loop


auto:
	rjmp	main_loop

output_handler:
	rcall	low_led_on
	ldi		onesecpassed, 0x00		; set onesecpassed back to 0
	ldi		ctrl, (1<<6)			; enable watchdog intterupt again
	sts		WDTCSR, ctrl

	sei								; enable global interuptts again
	wdr

times_up:
	; interrupt handler for watchdog timer
	cli
	ldi		onesecpassed, 0x01
	reti


.include	"led_controller.asm"
.include	"delay.asm"
.include	"motor_controller.asm"
