;
; PController.asm
;
; Created: 12/28/2023 11:24:35 PM
; Author : Humble Orbit

.include "m328pdef.inc"

.def p_con = r26
.def comp = r27
.def crosscounterH = r22
.def crosscounterL = r23

.org 0x00
	jmp start

start:
    sbrs crosscounterH, 0 ;0th bit of crosscounterH is set => value read > 255
	rjmp low_freq ; jump to low loop
	rjmp high_freq ; jump to high loop
	rjmp start

low_freq:
	ser comp ; set all bits of comp
	sub comp, crosscounterL ; subtract value read from the desired value
	breq doneL
	mov p_con, comp ; move the difference to p_con register
	lsr p_con
	lsr p_con ; divide difference by 4, kp=1/4
	doneL:
		rjmp start ; kill the loop if equal
	rjmp low_freq


high_freq:
	clr comp ; clear all bits of comp
	sub comp, crosscounterL ; subtract value read from the desired value
	breq doneH
	mov p_con, comp ; move the difference to p_con register
	lsr p_con
	lsr p_con ; divide difference by 4, kp=1/4
	doneH:
		rjmp start ; kill the loop if equal
	rjmp high_freq