.cseg
super_indicator:
	ldi		freq_lowerbound, 0x14					; checking for frequncy of 20
	ldi		freq_upperbound, 0x00

	cp		crosscounterL, freq_lowerbound			; compare low bytes
	cpc		crosscounterH, freq_upperbound			; compare higher bytes

	brlo	sleep_mode

	ldi		freq_lowerbound, 0x28					; checking for frequncy of 40
	ldi		freq_upperbound, 0x00

	cp		crosscounterL, freq_lowerbound			; compare low bytes
	cpc		crosscounterH, freq_upperbound			; compare higher bytes

	brlo	note_3

	ldi		freq_lowerbound, 0x4B					; checking for frequncy of 300/4 =75
	ldi		freq_upperbound, 0x00

	cp		crosscounterL, freq_lowerbound			; compare low bytes
	cpc		crosscounterH, freq_upperbound			; compare higher bytes

	brlo	note_2

	sbrs	r31, 2
	rcall	flag_clear_1

	rcall	indicate_E								; frequency of 330/4 = 83
	ldi		freq_lowerbound, 0x50					; checking for frequncy of 320/4 = 80
	ldi		freq_upperbound, 0x00
	rcall	indicator
	ret

note_3:
	sbrs	r31, 0									; if frequency is changed remap adaptive tuning
	rcall	flag_clear_3

	rcall	indicate_A								; frequency of 82/4 = 21
	ldi		freq_lowerbound, 0x18					; checking for frequncy of 95/4 = 24
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

	rcall	indicate_C								; frequency of 256/4 = 64
	ldi		freq_lowerbound, 0x3C					; checking for frequncy of 240/4 = 60
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

