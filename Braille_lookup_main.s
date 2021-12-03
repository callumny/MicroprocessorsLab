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
	movlw 6
	
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
	;call Braille_table_1
        call Braille_table
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
    retlw 01110100B;    P
    retlw 01110110B;    Q
    retlw 01110010B;    R
    retlw 00110100B;    S
    retlw 00110110B;    T
    retlw 01010001B;    U
    retlw 01110001B;    V
    retlw 00100111B;    W
    retlw 01010101B;    X
    retlw 01010111B;    Y
    retlw 01010011B;    Z
    retlw 00000000B; SF1
    retlw 00000000B; SF2
    retlw 00000000B; SF3
    retlw 00000000B; SF4
    retlw 00000000B; SF5
    retlw 00000000B; SF6

