	#include <xc.inc>

psect	code, abs
	
main:
	org	0x0		    ; org sets the assembler location counter
	goto	start		    ; go to an address

	org	0x100		    ; Main code starts here at address 0x100, this is to skip the access bank that stores fundamental variables (e.g. port assignment)


start:
    
        call SPI_MasterInit
	movlw 0x40
	call SPI_MasterTransmit
	goto $
	
    
SPI_MasterInit:	; Set Clock edge to negative
	bcf	CKE2	; CKE bit in SSP2STAT,          WHAT IS SSP2STAT BIT?
	; MSSP enable; CKP=1; SPI master, clock=Fosc/64 (1MHz)
	movlw 	(SSP2CON1_SSPEN_MASK)|(SSP2CON1_CKP_MASK)|(SSP2CON1_SSPM1_MASK)
	movwf 	SSP2CON1, A
	; SDO2 output; SCK2 output
	bcf	TRISD, PORTD_SDO2_POSN, A	; SDO2 output
	bcf	TRISD, PORTD_SCK2_POSN, A	; SCK2 output
	return
	
SPI_MasterTransmit:  ; Start transmission of data (held in W)
        movwf 	SSP2BUF, A 	; write data to output buffer
	
Wait_Transmit:	; Wait for transmission to complete 
        btfss 	SSP2IF		; check interrupt flag to see if data has been sent	
	bra 	Wait_Transmit
	bcf 	SSP2IF		; clear interrupt flag	
	return 	
	

end main	
	