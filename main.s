#include <xc.inc>

global	start, setup
extrn	keyboard_setup, keyboard_start, Recombine, Find_index,Place_index, LCD_Setup, check_light,clear_check_light, key_byte  ; external subroutines
;extrn	LCD_Setup, LCD_Write_Message, Display_clear
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    
psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************

setup: 
	call	keyboard_setup	; setup keyboard
	;call	LCD_Setup
	goto	start
	
	; ******* Main programme ****************************************
start: 	
	;call clear_check_light
	call keyboard_start
	call Recombine
	
	movlw	0xFF
	cpfsgt	key_byte
	goto	rest
	bra	start
	
rest:
	;call check_light
	call Find_index
	call Place_index
	goto start
		
end 
 