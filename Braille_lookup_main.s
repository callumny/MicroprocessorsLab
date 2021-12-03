#include <xc.inc>

global	start, setup
    
extrn    Braille_table; external subroutines
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
psect	udata_acs   ; named variables in access ram
index:	ds 1   ; reserve 1 byte for variable LCD_cnt_l

psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************

setup: 
	;call    Braille_setup
	movlw 2
	movwf index, A
	movlw 0x00
	movwf TRISJ, A
	movwf TRISB, A
	goto	start
	
	; ******* Main programme ****************************************
start: 	
	movf index, 0, 0   ; moves value to w
	movwf PORTJ, A
	call Braille_table
        ;call Braille_start
	movwf PORTB, A
	goto start ; call no_button_pressed    ; no lights on B when no key prssed

end start


