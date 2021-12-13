#include <xc.inc>
; given read_index returns braille byte
global Get_braille_byte; in to out

extrn read_index; out to in
    

psect	Braille_code,class=CODE
    
Get_braille_byte:
    ; multiply index by two?; rlncf W, 0, 0  ; moves 2 x index to W, no carr bit has two most significant bits are zero anyways
    movlw    high(Braille_table)
    movwf    PCLATH, A      ; set the upper address bits
    movf     read_index, 0, 0     ; get the value back
    addlw    low(Braille_table)  ; offset into table
    	
    btfsc    STATUS, 0;  bit 3 is the status register skpnc                ; an overflow?
    incf     PCLATH, f, A   ; yes, bump to next 'page'
    movwf    PCL, A         ; do the jump
    
Braille_table:
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
    retlw 00000001B; SF1
    retlw 00000010B; SF2
    retlw 00000100B; SF3
    retlw 00001000B; SF4
    retlw 00010000B; SF5
    retlw 11111111B; SF6


