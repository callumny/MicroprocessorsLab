	#include <xc.inc>

psect	code, abs
	
main:
	org	0x0
	goto	start

	org	0x100		    ; Main code starts here at address 0x100
start:
	movlw 	0x0
	movwf	TRISB, A	    ; Port C all outputs
	bra 	test
	
movlw 	high(0xDEAD)	; load 16bit number into 
		movfw 	0x10, A			; FR 0x10 
		movlw 	low(0xDEAD)
		movwf 	0x11, A			; and FR 0x11
		call	bigdelay
		.
		.
		.

Bigdelay:		
		movlw 	0x00			; W=0
Dloop: 	decf 	0x11, f, A		; no carry when 0x00 -> 0xff
		subwfb 	0x10, f, A		; no carry when 0x00 -> 0xff
		bc 	dloop				; if carry, then loop again
		return					; carry not set so return

loop:
	movff 	0x06, PORTB
	incf 	0x06, W, A
test:
	movwf	0x06, A	    ; Test for end of loop condition
	movlw 	0x63
	cpfsgt 	0x06, A
	bra 	loop		    ; Not yet finished goto start of loop again
	goto 	0x0		    ; Re-run program from start

	end	main

