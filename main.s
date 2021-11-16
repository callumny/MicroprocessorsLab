#include <xc.inc>

extrn	keyboard_setup, keyboard_start  ; external subroutines
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
	goto	start
	
	; ******* Main programme ****************************************
start: 	
	call keyboard_start
	
	
end start
 