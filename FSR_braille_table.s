#include <xc.inc>
    
global   Initialise_alphabet,Initialise_braille,Alphabet_lookup,Braille_lookup

extrn	current_index, counter

psect	udata_bank5 ; reserve data anywhere in RAM (here at 0x400)
myArray_alphabet:   ds	32

psect	data

alphabet_array:    ;need to load these in at the start of the programme in the intialisation stage
    
    db '0','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','!','£','$','%','&','*'	
    alphabet_array_1 EQU 32
    align 2

psect	udata_bank3
    
myArray_braille:   ds	32	;reserve 32 bytes in bank3

psect	data
	
braille_array:
    
    db	00000000B, 01000000B,01100000B,01000100B,01000110B,01000010B,01100100B,01100110B,01100010B,00100100B,00100110B,01010000B,01110000B,01010100B,01010110B,01010010B,01110100B,01110110B,01110010B,00110100B,00110110B,01010001B,01110001B,00100111B,01010101B,01010111B,01010011B,00000001B,00000010B,00000100B,00001000B,00010000B,11111111B	
    braille_array_1 EQU 32
    align 2
	
psect	FSR_braille_table_code,class=CODE

Initialise_alphabet:
	lfsr	0,myArray_braille
	movlw	low highword(alphabet_array)
	movwf	TBLPTRU, A
	movlw	high(alphabet_array)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(alphabet_array)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	alphabet_array_1	; bytes to read
	movwf	counter,A
loop_alphabet: 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC0; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter, A		; count down to zero
	bra	loop_alphabet		; keep going until finished
    
    return
    
Initialise_braille:
	lfsr	2,myArray_braille
	movlw	low highword(braille_array)
	movwf	TBLPTRU, A
	movlw	high(braille_array)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(braille_array)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	braille_array_1	; bytes to read
	movwf	counter,A
loop_braille: 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC2; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter, A		; count down to zero
	bra	loop_braille		; keep going until finished
    
    return

    
Alphabet_lookup:
    movf   FSR0,0,0
    movf   INDF0,0,0
    return
    
Braille_lookup:
    movff   current_index, INDF2
    movf   FSR2,0,0
    return
    


