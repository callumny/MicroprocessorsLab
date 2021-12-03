#include <xc.inc>

global  Braille_table_1

psect	code, abs
Braille_table_1:
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
    ;retlw 01010000B;	K
    ;retlw 01110000B;	L
    ;retlw 01010100B;	M
    ;retlw 01010110B;	N
    ;retlw 01010010B;	O
    ;retlw 01110100B;  P
   

