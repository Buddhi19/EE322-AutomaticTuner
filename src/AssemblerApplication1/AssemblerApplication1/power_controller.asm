.cseg
sleep_mode:
	clr		ctrl
	out		PORTB, ctrl								; set all other outputs to low
	out		PORTD, ctrl
	ldi		ctrl, (1<<0)							; set power saver indicator high
	out		PORTC, ctrl

;	ldi		ctrl,(1<<3)								; interrupt call for a Falling edge		
;	sts		EICRA, ctrl								; interrupt call for logical change at INT1

;	ldi		ctrl, (1<<1)
;	out		EIMSK, ctrl								; enable exteranl interrupt request 1
	
	rcall	WDT_off									; turn off watchdog timer

	ldi		ctrl, (1<<0)
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
