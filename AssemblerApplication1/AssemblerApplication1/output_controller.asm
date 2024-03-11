.cseg
indicator:
;	lsr		crosscounterH							; right shift the counter (divide by two) as there are two counts per cycle
;	ror		crosscounterL							; rotate right through carry

;	shifting is not nescessary

	cp		crosscounterL, freq_lowerbound			; compare low bytes
	cpc		crosscounterH, freq_upperbound			; compare higher bytes with carry from above

	brlo	freq_less_than_low						; branch if frequency less than 

	ldi		ctrl, 0x06								; add 24/4 = 6 range
	ldi		r17, 0x00

	add		freq_lowerbound, ctrl
	adc		freq_upperbound, r17

	cp		crosscounterL, freq_lowerbound			; compare low bytes
	cpc		crosscounterH, freq_upperbound			; compare higher bytes

	brlo	freq_is_ok								; branch if frequncy is okay

	rcall	high_led_on								; call high led if the frequnecy is greater than 260
	andi	freq_map,(1<<3)|(1<<4)|(1<<5)
	ori		freq_map, (1<<2)

	mov		ctrl, crosscounterL
	mov		r17, crosscounterH

	sub		ctrl, freq_lowerbound
	sbc		r17, freq_upperbound

	mov		freq_lowerbound, ctrl
	mov		freq_upperbound, r17

	rcall	P_controller

	ret


freq_less_than_low:
	rcall	low_led_on
	andi	freq_map, (1<<3)|(1<<4)|(1<<5)			; donot change bits in 3,4,5
	ori		freq_map, (1<<0)						; need a debugging process

	sub		freq_lowerbound, crosscounterL
	sbc		freq_upperbound, crosscounterH

	rcall	P_controller

	ret

freq_is_ok:
	rcall	ok_led_on
	andi	freq_map, (1<<3)|(1<<4)|(1<<5)			; do not change bits in 3,4,5
	ori		freq_map, (1<<1)
	ret

P_controller:
	lsr		freq_lowerbound
	lsr		freq_lowerbound
	lsr		freq_lowerbound
	
	breq	rotate_once

	ldi		ctrl, 0x04
	cp		freq_lowerbound,ctrl

	brlo	done
	ldi		freq_lowerbound, 0x04
	ret

done:
	ret

rotate_once:
	ldi		freq_lowerbound,0x01
	ret
