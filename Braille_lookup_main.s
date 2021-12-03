#include <xc.inc>

global	start, setup
    
;extrn    Braille_table_1; external subroutines
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
psect	udata_acs   ; named variables in access ram
index:	ds 1   ; reserve 1 byte for variable LCD_cnt_l

psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************

setup: 
	;call    Braille_setup
	movlw 1
	
	movwf index, A
	movlw 0x00
	movwf TRISJ, A
	movwf TRISC, A
	movwf TRISH, A
	goto	start
	
	; ******* Main programme ****************************************
start: 	
	movf index, 0, 0   ; moves value to w
	movwf PORTH, A
	rlncf index, 0, 0  ; moves 2 x index to W, no carr bit has two most significant bits are zero anyways
	movwf PORTJ, A
	call Braille_table
        ;call Braille_start
	movwf PORTC, A
	goto start ; call no_button_pressed    ; no lights on B when no key prssed
	
	
Braille_table:
    addwf PCL
    retlw 00000000B;  shouldn't be an index thta corresponds to this, just a space to make the indices correct
    retlw 01000000B;    A
    retlw 01100000B;    B
    retlw 01000100B;	C
    retlw 01000110B;	D
    retlw 01000010B;	E
    retlw 01100100B;	F
    retlw 01100110B;	G
    retlw 01100010B;	H
    retlw 00100100B;	I
    retlw 00100110B;	J
    retlw 01010000B;	K
    retlw 01110000B;	L
    retlw 01010100B;	M
    retlw 01010110B;	N
    retlw 01010010B;	O
    retlw 01110100B;  P



