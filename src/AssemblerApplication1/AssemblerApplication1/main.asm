;
; Automatic_Tuner.asm
;
; Created: 17/11/2023 6:55:35 PM
; Authors : Buddhi Wijenayake
;			Athulya Ratnayake
;			Thimira Hirushan

.include "m328pdef.inc"
	
	.equ	ledhigh = 0								; define higher frequency indicating ldr pin 
	.equ	ledlow  = 1								; define lower frequency indicating ldr pin 
	.equ	ledok   = 2								; define accepted frequecy indicating ldr pin
	.equ	ledP	= PORTB							; define led PORT

	.equ	mot_in1 = 0								; define motor driver input pin1
	.equ	mot_in2 = 1								; define motor driver input pin2
	.equ	mot_in3 = 2								; define motor driver input pin3
	.equ    mot_in4 = 3								; define motor driver input pin4
	
	.def	ctrl = r16								; define temporary register to controlling
	.def	delayr  = r17							; define delay counter register

	.cseg 
	.org	0x00									; set instruction starting address to 0x00
		rjmp	setup
	.org	0x02									; interrupt call for zero crossing
	
setup:
	ldi 	ctrl, (1<<PD0) | (1<<PD1) | (1<<PD2)
	out		DDRD, ctrl								; set output ports in PORTD
	ldi		ctrl, (1<<PB0) | (1<<PB1) | (1<<PB2) | (1<<PB3)
	out		DDRB, ctrl								; set output ports in PORTB

loop:
	in		ctrl, PINB
	ldi		r18, (1<<PB4) | (1<<PB5) | (1<<PB6)
	and		ctrl, r18
	sbrc	ctrl, 4
	rjmp	step_rotate_clockwise
	sbrc	ctrl, 5
	rjmp	step_rotate_anticlockwise
	
	sbrc	ctrl, 6
	rjmp	setzero_pos

	rjmp	loop


low_led_on:
	; indicating frequency is low
	cbi		ledP, ledhigh		
	cbi		ledP, ledok
	sbi		ledP, ledlow
	ret

ok_led_on:
	; indicating frequnecy is okay
	cbi		ledP, ledhigh
	cbi		ledP, ledlow
	sbi		ledP, ledok
	ret

high_led_on:
	; indicating frequency is high
	cbi		ledP, ledok
	cbi		ledP, ledlow
	sbi		ledP, ledhigh
	ret


step_rotate_anticlockwise:
	; sequence for the motor driver to rotate the motor anticlockwise
	ldi		ctrl, 0b00000001
	out		PORTB, ctrl
	rcall	pause

	ldi		ctrl, 0b00000010
	out		PORTB, ctrl
	rcall	pause

	ldi		ctrl, 0b00000100
	out		PORTB, ctrl
	rcall	pause

	ldi		ctrl, 0b00001000
	out		PORTB, ctrl
	rcall	pause

	rjmp	loop



step_rotate_clockwise:
	; sequence for the motor driver to rotate the motor clockwise
	ldi		ctrl, 0b00001000
	out		PORTB, ctrl
	rcall	pause

	ldi		ctrl, 0b00000100
	out		PORTB, ctrl
	rcall	pause

	ldi		ctrl, 0b00000010
	out		PORTB, ctrl
	rcall	pause

	ldi		ctrl, 0b00000001
	out		PORTB, ctrl
	rcall	pause

	rjmp	loop

setzero_pos:
	; zero position this is not working
	ldi		ctrl,0b00000100
	out		PORTB, ctrl
	rcall	pause

	ldi		ctrl, 0b00000000
	out		PORTB, ctrl
	rcall	pause
	rjmp	loop

.include"delay.asm"
