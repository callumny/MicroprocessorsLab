	#include <xc.inc>

psect	code, abs
	
main:
	org	0x0		    ; org sets the assembler location counter
	goto	start		    ; go to an address

	org	0x100		    ; Main code starts here at address 0x100, this is to skip the access bank that stores fundamental variables (e.g. port assignment)
start:
	movlw 	0x0		    ; Moves 0x0 to W repositry
	movwf	TRISC, A	    ; TRISC designates behavour to PORTC: 0x0 = 00000000 implies all pin are outputs
	movlw   0xff		    ; Moves 0xff to W repository
	movwf	TRISD, A	    ; TRISD designates behavour to PORTC: 0xff = 11111111 implies all pin are inputs
	movlw 	0x0
	bra 	test		    
loop:
	movff 	0x06, PORTC	    ; Move contents of address 0x06 to PORTC (port reads the data)
	incf 	0x06, W, A          ; Increment W register, 
test:
	movwf	0x06, A		    ; Upper liit of loop, e.g while i < (value stored in PORTD)
	movf	PORTD, W, A 	    ; reduce number of iterations from 0x63 (99d)
	cpfsgt 	0x06, A		    ; compare value stored at 0x06 to value stored in W and if value greter than that stoired in W then skip next line and exit loop
	bra 	loop		    ; Not yet finished goto start of loop again
	goto 	0x0		    ; Re-run program from start

	end	main
