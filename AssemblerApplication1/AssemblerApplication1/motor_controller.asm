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

	ret


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

	ret

setzero_pos:
	; zero position this is not working
	ldi		ctrl,0b00000000						; set all ports to low
	out		PORTB, ctrl
	ret
