;
; Automatic_Tuner.asm
;
; Created: 17/11/2023 6:55:35 PM
; Authors : Buddhi Wijenayake
;			Athulya Ratnayake
;			Thimira Hirushan

.include "m328pdef.inc"
	
	.equ	ldrhigh = 0								; define higher frequency indicating ldr pin 
	.equ	ldrlow  = 1								; define lower frequency indicating ldr pin 
	.equ	ldrok   = 2								; define accepted frequecy indicating ldr pin
	.equ	ledP	= PORTB							; define led PORT

	.equ	mot_in1 = 0								; define motor driver input pin1
	.equ	mot_in2 = 1								; define motor driver input pin2
	.equ	mot_in3 = 2								; define motor driver input pin3
	.equ    mot_in4 = 3								; define motor driver input pin4
	
	.def	ledctrl = r20							; define temporary register
	.def	motctrl	= r16							; define motctrl register to control motor driver
	.def	delayr  = r17							; define delay counter register

	.cseg 
	.org	0x00									; set instruction starting address to 0x00
	ldi 	ledctrl, (1<<PD0) | (1<<PD1) | (1<<PD2)	; set temp register such that it can manage all 3ldrs

	ldi		motctrl, (1<<PB0) | (1<<PB1) | (1<<PB2) | (1<<PB3)
	out		DDRB, motctrl
	out		DDRD, ledctrl
	
setup:
	ldi		motctrl, (1<<PB2)
	out		PORTB, motctrl
	rcall   delay

	ldi		motctrl, (0<<PB2) 
	out		PORTB, motctrl
	rcall	delay

	
	rjmp	setup

lowldron:
	cbi		ledP, ldrhigh
	cbi		ledP, ldrok
	sbi		ledP, ldrlow
	ret

okldron:
	cbi		ledP, ldrhigh
	cbi		ledP, ldrlow
	sbi		ledP, ldrok
	ret

highldron:
	cbi		ledP, ldrok
	cbi		ledP, ldrlow
	sbi		ledP, ldrhigh
	ret

delay:
	ldi		delayr, 0xff						; load delay register
	rcall	mydelay
	ret

mydelay:
	dec		delayr
	brne	mydelay
	ret
	