.cseg
indicator:
;	lsr		crosscounterH							; right shift the counter (divide by two) as there are two counts per cycle
;	ror		crosscounterL							; rotate right through carry

;	shifting is not nescessary

	ldi		freq_lowerbound, 0x32					; checking for frequncy of 50
	ldi		freq_upperbound, 0x00

	cp		crosscounterL, freq_lowerbound			; compare low bytes
	cpc		crosscounterH, freq_upperbound			; compare higher bytes

	brlo	sleep_mode

	ldi		freq_lowerbound, 0xF0					; checking for frequncy of 240
	ldi		freq_upperbound, 0x00

	cp		crosscounterL, freq_lowerbound			; compare low bytes
	cpc		crosscounterH, freq_upperbound			; compare higher bytes with carry from above

	brlo	freq_less_than_240						; branch if frequency less than 240

	ldi		freq_lowerbound, 0x18					; check for frequnecy of 280
	ldi		freq_upperbound, 0x01

	cp		crosscounterL, freq_lowerbound			; compare low bytes
	cpc		crosscounterH, freq_upperbound			; compare higher bytes

	brlo	freq_is_ok								; branch if frequncy is okay

	rcall	high_led_on								; call high led if the frequnecy is greater than 260
	andi	freq_map,(1<<3)|(1<<4)|(1<<5)
	ori		freq_map, (1<<2)

	ret


freq_less_than_240:
	rcall	low_led_on
	andi	freq_map, (1<<3)|(1<<4)|(1<<5)			; donot change bits in 3,4,5
	ori		freq_map, (1<<0)						; need a debugging process
	ret

freq_is_ok:
	rcall	ok_led_on
	andi	freq_map, (1<<3)|(1<<4)|(1<<5)			; do not change bits in 3,4,5
	ori		freq_map, (1<<1)
	ret


