#include <xc.inc>

global	start, setup
extrn	keyboard_setup, keyboard_start, Recombine, Find_index,Place_index, LCD_Setup, check_light,clear_check_light, key_byte, Check_button_pressed  ; external subroutines
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
	call Find_index
	call Check_button_pressed
	
	;clrf PORTB, A
	movlw 0xFF
	cpfseq key_byte
	return;call yes_button_pressed    ; show lights on port b if key has been pressed
	bra start; call no_button_pressed    ; no lights on B when no key prssed
    
	
	
	;movff key_byte, PORTC, A
	call Place_index
	;movlw 0xaa
	;movwf 0x01, A
	
	;movlw	0xFF
	;cpfsgt	key_byte        ; if keybyte is 0xFF, i.e. no button pressed, then we skip the next line and branch to the start
	;goto	rest
	;movlw   0xFF
	;movwf   0x01, A        ; show 0F on portA if no button is pressed
	;bra	start
	
rest:
	;call check_light
	call Find_index
	call Place_index
	goto start
		
end 
 