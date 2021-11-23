#include <xc.inc>

global	start
extrn	keyboard_setup, keyboard_start, Recombine, Keys_setup, Zero_check, Invert, Reset_bit_counter, Index_row, Index_column, Add_index,Print, LCD_Setup  ; external subroutines
;extrn	LCD_Setup, LCD_Write_Message, Display_clear
	 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    
psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************
setup: 
	; in the keyboard setup we select the correct bank register
	; clears port E 
	; makes B and C outputs 
	call	keyboard_setup	; setup keyboard
	call	LCD_Setup
	goto	start
	
	; ******* Main programme ****************************************
start: 	
	call keyboard_start
	call Recombine
	call Keys_setup
	;call Zero_check
	call Invert
	call Reset_bit_counter
	call Index_row
	call Reset_bit_counter
	call Index_column
	call Add_index
	call Print
	goto start
		
end start
 