	#include <xc.inc>

psect	code, abs
	
main:
	org	0x0		    ; org sets the assembler location counter
	goto	start		    ; go to an address

	org	0x100		    ; Main code starts here at address 0x100, this is to skip the access bank that stores fundamental variables (e.g. port assignment)
start:
	movlw 	0x0		    ; Moves 0x0 to W repositry
	movwf	TRISC, A	    ; Port C all outputs
	bra 	test		    
loop:
	movff 	0x06, PORTC	    ; Move contents of address 0x06 to PORTC
	incf 	0x06, W, A          ; Increment W register, 
test:
	movwf	0x06, A		    ; Test for end of loop condition
	movlw 	0x63		    ;reduce number of iterations from 0x63 (big number)
	cpfsgt 	0x06, A		    ; compare value stored at 0x06 to value stored in W and if value greter than that stoired in W then skip next line and exit loop
	bra 	loop		    ; Not yet finished goto start of loop again
	goto 	0x0		    ; Re-run program from start

	end	main
