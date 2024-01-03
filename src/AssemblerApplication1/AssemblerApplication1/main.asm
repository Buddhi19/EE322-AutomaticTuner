;
; Automatic_Tuner.asm
;
; Created: 17/11/2023 6:55:35 PM
; Authors : Buddhi Wijenayake
;			Athulya Ratnayake
;			Thimira Hirushan

.include "m328pdef.inc"
	
	.equ	mot_in1 = 0								; define motor driver input pin1
	.equ	mot_in2 = 1								; define motor driver input pin2
	.equ	mot_in3 = 2								; define motor driver input pin3
	.equ    mot_in4 = 3								; define motor driver input pin4
	
	.def	ctrl = r16								; define temporary register to controlling
	.def	delayr  = r17							; define delay counter register

	.def	onesecpassed = r21						; check one second passed
	; 0th bit -> onesec passed
	; 1st bit -> 0 means manual mode, 1 means auto

	.def	freq_map = r18							; controls motor in automatic mode 
	; 0th bit -> LOW
	; 1st bit -> OK
	; 2nd bit -> HIGH

	;  r30
	; 0th bit -> Adaptive tuning on going
	; 1st bit -> 1 means Adaptive tuning done
	; 2nd bit -> 1 means clockwise turning--> increase frequency, 0 means anticlockwise turning--> increase frequency

	;r31
	; stores current frequency
	; 0 th bit = 1 for A
	; 1 st bit = 1 for C
	; 2 nd bit = 1 for E

	.def	crosscounterL = r23						; low register for count the number of times the signal passed 3.3V
	.def	crosscounterH = r22						; high register for crosscounter

	.def	freq_lowerbound = r19					; lower register used to compare results
	.def	freq_upperbound = r20					; upper register used to compare the results

	.cseg 
	.org	0x00									; set instruction starting address to 0x00
		jmp	setup
	.org	0x004									; interrupt call for zero crossing
		jmp		isr_int1
	.org	0x000C									; for watchdog interrupt
		jmp		WDT
	
setup:
	ldi 	ctrl, (1<<PD0) | (1<<PD1) | (1<<PD2)|(1<<PD5)
	out		DDRD, ctrl								; set output ports in PORTD
	ldi		ctrl, (1<<PB0) | (1<<PB1) | (1<<PB2) | (1<<PB3)
	out		DDRB, ctrl								; set output ports in PORTB

	ldi		ctrl,(1<<PC0)|(1<<PC1)|(1<<PC2)|(1<<PC3)
	out		DDRC, ctrl								; set-up seven segment display
	;out		PORTC, ctrl

	clr		crosscounterL							; initialize the counter
	clr		crosscounterH

	wdr
	lds		ctrl, WDTCSR
	ori		ctrl ,(1<<WDE)|(1<<WDCE)				; enable watchdog interrupts
	sts		WDTCSR, ctrl

	ldi		ctrl, (1<<WDIE) | (1<<WDP2) | (1<<WDP1)	; set watchdog timer for one second
	sts		WDTCSR, ctrl

	ldi		ctrl, (1<<2)|(1<<3)						; interrupt call for a rising edge		
	sts		EICRA, ctrl								; interrupt call for logical change at INT1

	ldi		ctrl, (1<<1)
	out		EIMSK, ctrl								; enable exteranl interrupt request 1

	sei												; enable global interrupts


main_loop:
	sbrc	onesecpassed,0							; if one second timer passed
	rjmp	output_handler							; somethings there in the output
	; controls main loop depending on auto/manual conditions
	in		ctrl, PINB								; take PINB states

	andi	onesecpassed, (1<<0)					; put auto/manual state in the register

	sbrs	ctrl, 6									; check for auto/manual conditions
	rjmp	manual
	
	ori		onesecpassed, (1<<1)
	rjmp	auto



manual:												; controlling manual controlling
	sbrc	ctrl, 4									; skip if clockwise button is not pressed
	rcall	step_rotate_clockwise
	sbrc	ctrl, 5									; skip if anticlockwise button is not pressed
	rcall	step_rotate_anticlockwise
	rcall	setzero_pos								; if non of them is pressed set all ports to 0
	rjmp	main_loop


auto:
	sbrc	freq_map, 0								; skip if 0th bit is 0
	rjmp	tune_up									; tune up
	
	sbrc	freq_map, 1								; skip if 1th bit is 0
	rcall	setzero_pos								; tuning is stopped

	sbrc	freq_map, 2								; skip if 2nd bit is 0
	rcall	tune_down								; tune down

	rjmp	main_loop

tune_up:
	sbrs	r30, 1
	rjmp	clockwise

	sbrc	r30, 2									; if bit 1 is cleared rotate anticlockwise to increase f
	rjmp	clockwise_loop
	rjmp	anticlockwise_loop

tune_down:
	sbrs	r30, 1
	rjmp	clockwise

	sbrs	r30, 2									; if bit 1 is set rotate anticlockwise to decrease f
	rjmp	clockwise_loop
	rjmp	anticlockwise_loop
	ret

clockwise:
	rcall	step_rotate_clockwise
	rjmp	main_loop

clockwise_loop:
	dec		freq_lowerbound
	rcall	step_rotate_clockwise
	brne	clockwise_loop
	rjmp	main_loop

anticlockwise_loop:
	dec		freq_lowerbound
	rcall	step_rotate_anticlockwise
	brne	anticlockwise_loop
	rjmp	main_loop

output_handler:
	rcall	super_indicator

	sbrc	onesecpassed, 1							; if auto mode, check for the initialization
	rcall	init

	ldi		crosscounterL, 0x00						; set crosscounter back to 0
	ldi		crosscounterH, 0x00

	andi	onesecpassed, (1<<1)					; set onesecpassed back to 0	
					
	lds		ctrl, WDTCSR
	sbrc	ctrl, 6									; skip if WDT is already cleared					
	rcall	WDT_off

	wdr
	lds		ctrl, WDTCSR
	ori		ctrl ,(1<<WDE)|(1<<WDCE)				; enable watchdog interrupts
	sts		WDTCSR, ctrl
	ldi		ctrl, (1<<WDIE) | (1<<WDP2) | (1<<WDP1)	; set watchdog timer for one second
	sts		WDTCSR, ctrl

	sei												; enable global interrupts
	;cbi		PORTD, 4						

	rjmp	main_loop

init:
	sbrs	r30, 1									; if initialization is done skip
	rcall	initializer
	ret

initializer:
	sbrs	r30, 0									; if adaptive initialization is in process skip
	rjmp	store_current

	cp		crosscounterL, r28
	cpc		crosscounterH, r29

	brlo	freq_decreased
	ori		r30, (1<<1)|(1<<2)						; frequency is increased when rotated in clockwise
	ret

freq_decreased:
	andi	r30,(0<<2)								; frequency is decresed when rotated clockwise
	ori		r30,(1<<1)
	ret

store_current:
	mov		r28, crosscounterL						; store the initial frequency to compare
	mov		r29, crosscounterH

	ori		r30, (1<<0)						
	ret

WDT:												; interrupt handler for watchdog timers
	;sbi		PORTD, 4								; debugger
	cli												; disable interrupts
	ori		onesecpassed, (1<<0)
	reti


isr_int1:
	inc		crosscounterL							; increment the lower register
	brne	no_overflow								; branch if no overflow i.e (0x00)

	inc		crosscounterH							; increment the higher register at an overflow

	reti

no_overflow:
	reti											; close the interrupt routine at no overflow

WDT_off:
	wdr												; start timed sequence
	lds		r16, WDTCSR
	ori		r16, (1<<WDCE) | (1<<WDE)	
	sts		WDTCSR, r16
	ldi		r16, 0x00								; disbale Watchdog to enable after
	sts		WDTCSR, r16
	ret
	
.include	"led_controller.asm"
.include	"delay.asm"
.include	"motor_controller.asm"
.include	"output_controller.asm"
.include	"power_controller.asm"
.include	"display_controller.asm"
.include	"super_controller.asm"
