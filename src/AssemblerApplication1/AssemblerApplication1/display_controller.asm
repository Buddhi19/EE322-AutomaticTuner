.cseg
indicate_F:
	ldi		ctrl, 0b00001111						; corresponding value to represent E
	rcall	display_bcd
	ret

indicate_B:
	ldi		ctrl, 0b000000001
	rcall	display_bcd
	ret

indicate_D:
	ldi		ctrl, 0b00000000
	rcall	display_bcd
	ret

indicate_3:
	ldi		ctrl, 0b00001100						; corresponding value to represent E
	rcall	display_bcd
	ret

indicate_5:
	ldi		ctrl, 0b00001010						; corresponding value to represent E
	rcall	display_bcd
	ret

indicate_1:
	ldi		ctrl, 0b00001000						; corresponding value to represent E
	rcall	display_bcd
	ret

indicate_E:
	ldi		ctrl, 0b00000111						; corresponding value to represent E
	rcall	display_bcd
	ret

indicate_C:
	ldi		ctrl, 0b00000011						; corresponding value to represent E
	rcall	display_bcd
	ret

indicate_6:
	ldi		ctrl, 0b00000110						; corresponding value to represent E
	rcall	display_bcd
	ret

indicate_2:
	ldi		ctrl, 0b00000100						; corresponding value to represent E
	rcall	display_bcd
	ret

indicate_A:
	ldi		ctrl, 0b00000101						; corresponding value to represent E
	rcall	display_bcd
	ret

display_bcd:
	out		PORTC, ctrl
	ret