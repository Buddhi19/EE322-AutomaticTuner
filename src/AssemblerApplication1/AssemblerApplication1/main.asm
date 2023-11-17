;
; Automatic_Tuner.asm
;
; Created: 17/11/2023 6:55:35 PM
; Authors : Buddhi Wijenayake
;			Athulya Ratnayake
;			Thimira Hirushan

.include "m328pdef.inc"
	
	.def	ldrhigh = r17							; define higher frequency indicating ldr
	.def	ldrlow  = r18							; define lower frequency indicating ldr
	.def	ldrok   = r19							; define accepted frequecy indicating ldr
	.def	temp    = r20							; define temporary register

	.cseg 
	.org	0x00									; set instruction starting address to 0x00
	ldi 	temp, (1<<PB0) | (1<<PB1) | (1<<PB2)	; set temp register such that it can manage all 3ldrs
	out		DDRB, temp
	
setup:
	rcall	lowldron
	rjmp	setup

lowldron:
	cbi		PORTB, 0
	cbi		PORTB, 1
	sbi		PORTB, 2
	ret

okldron:
	cbi		PORTB, 0
	cbi		PORTB, 2
	sbi		PORTB, 1
	ret

highldron:
	cbi		PORTB, 1
	cbi		PORTB, 2
	sbi		PORTB, 0
	ret

	