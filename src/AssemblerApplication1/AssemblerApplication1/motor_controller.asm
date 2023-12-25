.cseg
step_rotate_anticlockwise:
	; sequence for the motor driver to rotate the motor anticlockwise
	ldi		ctrl, 0b00000001
	out		PORTB, ctrl
	rcall	pause

	ldi		ctrl, 0b00000010
	out		PORTB, ctrl
	rcall	pause

	ldi		ctrl, 0b00000100
	out		PORTB, ctrl
	rcall	pause

	ldi		ctrl, 0b00001000
	out		PORTB, ctrl
	rcall	pause

	rjmp	main_loop



step_rotate_clockwise:
	; sequence for the motor driver to rotate the motor clockwise
	ldi		ctrl, 0b00001000
	out		PORTB, ctrl
	rcall	pause

	ldi		ctrl, 0b00000100
	out		PORTB, ctrl
	rcall	pause

	ldi		ctrl, 0b00000010
	out		PORTB, ctrl
	rcall	pause

	ldi		ctrl, 0b00000001
	out		PORTB, ctrl
	rcall	pause

	rjmp	main_loop

setzero_pos:
	; zero position this is not working
	ldi		ctrl,0b00000000
	out		PORTB, ctrl
	rjmp	main_loop
