.equ	ledhigh = 0								; define higher frequency indicating ldr pin 
.equ	ledlow  = 1								; define lower frequency indicating ldr pin 
.equ	ledok   = 2								; define accepted frequecy indicating ldr pin
.equ	ledP	= PORTB							; define led PORT
.cseg
low_led_on:
	; indicating frequency is low
	cbi		ledP, ledhigh		
	cbi		ledP, ledok
	sbi		ledP, ledlow
	ret

ok_led_on:
	; indicating frequnecy is okay
	cbi		ledP, ledhigh
	cbi		ledP, ledlow
	sbi		ledP, ledok
	ret

high_led_on:
	; indicating frequency is high
	cbi		ledP, ledok
	cbi		ledP, ledlow
	sbi		ledP, ledhigh
	ret