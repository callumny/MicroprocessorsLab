#include <xc.inc>

global  index

    
psect	udata_acs   ; named variables in access ram
LCD_cnt_l:	ds 1   ; reserve 1 byte for variable LCD_cnt_l
LCD_cnt_h:	ds 1   ; reserve 1 byte for variable LCD_cnt_h
LCD_cnt_ms:	ds 1   ; reserve 1 byte for ms counter
LCD_tmp:	ds 1   ; reserve 1 byte for temporary use
LCD_counter:	ds 1   ; reserve 1 byte for counting through nessage

	LCD_E	EQU 5	; LCD enable bit
    	LCD_RS	EQU 4	; LCD register select bit
    
    
Braille_table addwf index
    retlw b'00000000';  shouldn't be an index thta corresponds to this, just a space to make the indices correct
    retlw b'01000000';  A
    retlw b'01100000';  B
    retlw b'01000100';	C
    retlw b'01000110';	D
    retlw b'01000010';	E
    retlw b'01100100';	F
    retlw b'01100110';	G
    retlw b'01100010';	H
    retlw b'00100100';	I
    retlw b'00100110';	J
    retlw b'01010000';	K
    retlw b'01110000';	L
    retlw b'01010100';	M
    retlw b'01010110';	N
    retlw b'01010010';	O
    retlw b'01110100';  P
    
psect	udata_acs   ; named variables in access ram
LCD_cnt_l:	ds 1   ; reserve 1 byte for variable LCD_cnt_l
LCD_cnt_h:	ds 1   ; reserve 1 byte for variable LCD_cnt_h
LCD_cnt_ms:	ds 1   ; reserve 1 byte for ms counter
LCD_tmp:	ds 1   ; reserve 1 byte for temporary use
LCD_counter:	ds 1   ; reserve 1 byte for counting through nessage

	LCD_E	EQU 5	; LCD enable bit
    	LCD_RS	EQU 4	; LCD register select bit

psect	lcd_code,class=CODE
    
LCD_Setup:
	clrf    LATB, A
	movlw   11000000B	    ; RB0:5 all outputs
	movwf	TRISB, A
	movlw   40
	call	LCD_delay_ms	; wait 40ms for LCD to start up properly
	movlw	00110000B	; Function set 4-bit
	call	LCD_Send_Byte_I
	movlw	10		; wait 40us
	call	LCD_delay_x


