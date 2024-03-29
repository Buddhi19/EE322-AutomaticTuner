.cseg
super_indicator:
	ldi		freq_lowerbound, 0x46					; checking for frequncy of 50
	ldi		freq_upperbound, 0x00

	cp		crosscounterL, freq_lowerbound			; compare low bytes
	cpc		crosscounterH, freq_upperbound			; compare higher bytes

	brlo	sleep_mode

	ldi		freq_lowerbound, 0x96					; checking for frequncy of 150
	ldi		freq_upperbound, 0x00

	cp		crosscounterL, freq_lowerbound			; compare low bytes
	cpc		crosscounterH, freq_upperbound			; compare higher bytes

	brlo	note_3

	ldi		freq_lowerbound, 0x2C					; checking for frequncy of 300
	ldi		freq_upperbound, 0x01

	cp		crosscounterL, freq_lowerbound			; compare low bytes
	cpc		crosscounterH, freq_upperbound			; compare higher bytes

	brlo	note_2

	sbrs	r31, 2
	rcall	flag_clear_1

	rcall	indicate_E								; frequency of 330
	ldi		freq_lowerbound, 0x40					; checking for frequncy of 320
	ldi		freq_upperbound, 0x01
	rcall	indicator
	ret

note_3:
	sbrs	r31, 0									; if frequency is changed remap adaptive tuning
	rcall	flag_clear_3

	rcall	indicate_A								; frequency of 82
	ldi		freq_lowerbound, 0x5F					; checking for frequncy of 95
	ldi		freq_upperbound, 0x00
	rcall	indicator
	ret

flag_clear_3:
	clr		r30
	ldi		r31, 0x01
	ret

note_2:
	sbrs	r31, 1									; if frequency is changed remap adaptive tuning
	rcall	flag_clear_2

	rcall	indicate_C								; frequency of 256
	ldi		freq_lowerbound, 0xF0					; checking for frequncy of 240
	ldi		freq_upperbound, 0x00
	rcall	indicator
	ret

flag_clear_2:
	clr		r30
	ldi		r31, 0x02
	ret

flag_clear_1:
	clr		r30
	ldi		r31, 0x04
	ret

;note_4:	
;	rcall	indicate_D								; frequency of 146
;	ldi		freq_lowerbound, 0x8C					; checking for frequncy of 140
;	ldi		freq_upperbound, 0x00
;	rcall	indicator
;	ret

;note_3:
;	rcall	indicate_3								; frequency if 196
;	ldi		freq_lowerbound, 0xBC					; checking for frequncy of 188
;	ldi		freq_upperbound, 0x00
;	rcall	indicator
;	ret

;note_2:
;	rcall	indicate_2								; frequency of 246
;	ldi		freq_lowerbound, 0xEE					; checking for frequncy of 238
;	ldi		freq_upperbound, 0x00
;	rcall	indicator
;	ret

