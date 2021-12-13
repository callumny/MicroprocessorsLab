#include <xc.inc>
    
global   Initialise_braille,Braille_lookup,Initialise_alphabet,Alphabet_lookup,Create_word,LCD_word_display

extrn	counter,final_alphabet,final_braille,index,read_index,index_counter,LCD_Write_Message,LCD_delay_ms,LCD_Send_Byte_D

psect	udata_bank6
word:	ds  16
psect	udata_bank5 ; reserve data anywhere in RAM (here at 0x400)
myArray_alphabet:   ds	32

psect	data

alphabet_array:    ;need to load these in at the start of the programme in the intialisation stage
    
    db '0','A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','A','B','B','A','J','J'	
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
	
	lfsr	0,myArray_alphabet
	movlw	low highword(alphabet_array)
	movwf	TBLPTRU, A
	movlw	high(alphabet_array)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(alphabet_array)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	movlw	alphabet_array_1	; bytes to read
	addlw	1
	movwf	counter,A
	
	bra	loop_alphabet
	
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
	addlw	1
	movwf	counter,A
	bra	loop_braille
	
loop_braille: 	tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
	movff	TABLAT, POSTINC2; move data from TABLAT to (FSR0), inc FSR0	
	decfsz	counter, A		; count down to zero
	bra	loop_braille		; keep going until finished
    
	return

    
Alphabet_lookup:	;takes the index and converts it into a letter, places in final_alphabet

    lfsr    2, myArray_alphabet
    movf    index,W
    movff   PLUSW2,final_alphabet
    return
    
Create_word:	    ;takes the letter in final_alphabet and puts it in the correction position in the word (word stored at 0x600)
    lfsr    2, word
    movf    index_counter,W
    addlw   -1		;because it starts at 601 for some reason, think its because the index is incremented before we call this
    movff   final_alphabet,PLUSW2
    return
    
    
WriteDisplay:
	movlw	low highword(word)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(word)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(word)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	
	movf	index_counter, W
	addwf	TBLPTRL, F
	movlw	0x0
	addwfc	TBLPTRH, F
	addwfc	TBLPTRU, F		    ;this needs some messing around withy
	
	movlw	index_counter
	call	LCD_Write_Message
	return
	
;LCD_Loop_message:
 ;   tblrd*+			; one byte from PM to TABLAT, increment TBLPRT
  ;  movf    TABLAT, W, A
   ; call    LCD_Send_Byte_D
    ;decfsz  index_counter, A
    ;bra	    LCD_Loop_message
    ;movlw	100
    ;call	LCD_delay_ms
    ;return
    
Braille_lookup:
    ;need to initialise the fsr before doing anything
    lfsr    2, myArray_braille
    movf    read_index,W
    movff   PLUSW2,final_braille

    return
    
