	#include <xc.inc>

psect	code, abs
	
main:
	org	0x0		    ; org sets the assembler location counter
	goto	start		    ; go to an address

	org	0x100		    ; Main code starts here at address 0x100, this is to skip the access bank that stores fundamental variables (e.g. port assignment)
start:
 
	movlw 	0x0		    ; Moves 0x0 to W repositry
 	movwf	TRISD, A	    ; TRISC designates behavour to PORTC: 0x0 = 00000000 implies all pin are outputs
	movwf	TRISE, A	    ; TRISD designates behavour to PORTC: 0xff = 11111111 implies all pin are inputs
	
	movlw 	0x0		    ; move 0x0 to W repositry
	movwf	LATD, A		    ;move 0x0 to port D

	bsf	LATD, 0x0, 1	    ;sets the first bit in port D as a 1, to set the OE* as high, allowing writing to the external chip
	bsf	LATD, 0x1, 1	    ;sets the 2nd bit in port D as a 1, to set clock high allowing us to change it later
	
	movlw	0xAA		    ;sets the w repositry at 10101010
	movwf	LATE, A		    ;moves the w repositry to port E (what is the significance of A?)
	
	bsf	LATD, 0x1, 0	    ;sets clock low
	bsf	LATD, 0x1, 1	    ;sets clock high (transition from low to high tells external chip to read from data pins connected to port E)
	bsf	LATD, 0x0, 0	    ; while this is low this outputs saved data from the external chip
	goto	start		    ; this loops back to the previous command and keeps the pointer there, in theory continously outputing the signal
end	main
	
	