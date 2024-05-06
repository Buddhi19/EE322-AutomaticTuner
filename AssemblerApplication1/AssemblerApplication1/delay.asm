.def	delayLoopHi = r25
.def	delayLoopLo = r24
.cseg

pause:
	ldi		r17,0xAF
	rcall	delay
	ret

delaylong:
;you need to load the value to be delayed in r17
	ldi		delayLoopHi, 0xff
	ldi		delayLoopLo, 0xff
	call	delay
	dec		r17
	brne	delaylong
	ret

delay:
	;load the 16 bit delay value to r25 and r24
	;initial call takes 4 clock cycles
	sbiw		delayLoopHi:delayLoopLo,1				;takes 2 clock cycles
	brne		delay									;takes 2  clock cycles
	ret													;takes 4 clock cycles
	;in total takes 4+(2+2)+4*delay = 4*delay+8 clock cycles
