.cseg
indicator:
;	lsr		crosscounterH							; right shift the counter (divide by two) as there are two counts per cycle
;	ror		crosscounterL							; rotate right through carry

;	shifting is not nescessary

	ldi		freq_lowerbound, 0x32					; checking for frequncy of 50
	ldi		freq_upperbound, 0x00

	cp		crosscounterL, freq_lowerbound			; compare low bytes
	cpc		crosscounterH, freq_upperbound			; compare higher bytes

	brlo	sleepmode

	ldi		freq_lowerbound, 0xF0					; checking for frequncy of 240
	ldi		freq_upperbound, 0x00

	cp		crosscounterL, freq_lowerbound			; compare low bytes
	cpc		crosscounterH, freq_upperbound			; compare higher bytes with carry from above

	brlo	freq_less_than_240						; branch if frequency less than 240

	ldi		freq_lowerbound, 0x04					; check for frequnecy of 260
	ldi		freq_upperbound, 0x01

	cp		crosscounterL, freq_lowerbound			; compare low bytes
	cpc		crosscounterH, freq_upperbound			; compare higher bytes

	brlo	freq_is_ok								; branch if frequncy is okay

	rcall	high_led_on								; call high led if the frequnecy is greater than 260
	ldi		freq_map, 0x04

	ret


freq_less_than_240:
	rcall	low_led_on
	ldi		freq_map, 0x01							
	ret

freq_is_ok:
	rcall	ok_led_on
	ldi		freq_map, 0x02
	ret

sleepmode:
	clr		ctrl
	out		PORTB, ctrl
	out		PORTD, ctrl
	ldi		ctrl, (1<<0)
	out		PORTC, ctrl

	ldi		ctrl,(1<<3)								; interrupt call for a Falling edge		
	sts		EICRA, ctrl								; interrupt call for logical change at INT1

	ldi		ctrl, (1<<1)
	out		EIMSK, ctrl								; enable exteranl interrupt request 1
	
	rcall	WDT_off

	ldi		ctrl, (1<<0)|(1<<2)
	out		SMCR, ctrl								; enable sleep mode

	lds		ctrl, MCUCR
	ori		ctrl, (1<<6)|(1<<5)						; set BODS and BODSE

	out		MCUCR, ctrl

	cbr		ctrl, (1<<5)	
	out		MCUCR, ctrl								; set only BODS bit

	sei

	sleep											; sleep mode enabled

	cli												; wake up at external interrupt

	clr		ctrl									; switch off power save button
	out		PORTC, ctrl

	out		SMCR, ctrl								; clear sleep bit

	ret

