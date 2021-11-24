#include <xc.inc>

global	start, setup
extrn	keyboard_setup, LCD_Setup, keyboard_start, Recombine, Display_key_byte, Check_pressed, Find_index, Display_index, key_byte, Check_pressed  ; external subroutines
;extrn	LCD_Setup, LCD_Write_Message, Display_clear
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    
psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************

setup: 
	call	keyboard_setup	; setup keyboard
	call	LCD_Setup
	goto	start
	
	; ******* Main programme ****************************************
start: 	
	;call clear_check_light
	call keyboard_start
	call Recombine
	call Display_key_byte
	call Check_pressed
	call Find_index
	call Display_index
	call Print
	bra start ; call no_button_pressed    ; no lights on B when no key prssed

end 
 