;
; Automatic_Tuner.asm
;
; Created: 17/11/2023 6:55:35 PM
; Authors : Buddhi Wijenayake
;			Athulya Ratnayake
;			Thimira Hirushan

.include "m328pdef.inc"
	
	.equ	ldrhigh = 4								; define higher frequency indicating ldr pin 
	.equ	ldrlow  = 5								; define lower frequency indicating ldr pin 
	.equ	ldrok   = 6								; define accepted frequecy indicating ldr pin

	.equ	mot_in1 = 0								; define motor driver input pin1
	.equ	mot_in2 = 1								; define motor driver input pin2
	.equ	mot_in3 = 2								; define motor driver input pin3
	.equ    mot_in4 = 3								; define motor driver input pin4
	
	.def	temp    = r20							; define temporary register
	.def	motctrl	= r16							; define motctrl register to control motor driver
	.def	delayr  = r17							; define delay counter register

	.cseg 
	.org	0x00									; set instruction starting address to 0x00
	ldi 	temp, (1<<PB4) | (1<<PB5) | (1<<PB6)	; set temp register such that it can manage all 3ldrs
	ldi		motctrl, (1<<PD0) | (1<<PD1) | (1<<PD2) | (1<<PD3)
	out		DDRD, motctrl
	out		DDRB, temp
	
setup:
	rcall	lowldron
	ldi		motctrl, (1<<PD0)
	out		PORTD, motctrl
	rcall   delay

	ldi		motctrl, (1<<PD0)
	out		PORTD, motctrl
	cbi		PORTD, 0
	rcall	delay
	
	rjmp	setup

lowldron:
	cbi		PORTB, ldrhigh
	cbi		PORTB, ldrok
	sbi		PORTB, ldrlow
	ret

okldron:
	cbi		PORTB, ldrhigh
	cbi		PORTB, ldrlow
	sbi		PORTB, ldrok
	ret

highldron:
	cbi		PORTB, ldrok
	cbi		PORTB, ldrlow
	sbi		PORTB, ldrhigh
	ret

delay:
	ldi		delayr, 0x08						; load delay register
	rcall	mydelay
	ret

mydelay:
	dec		delayr
	brne	mydelay
	ret
	