#include <xc.inc>

global	start, setup
extrn	Is_button_pressed, button_pressed, keyboard_setup, LCD_Setup, keyboard_start, Recombine, Split_NOT_key_byte, Display_key_byte, Display_NOT_key_byte, Check_pressed, Find_index, Display_index, key_byte, NOT_key_byte, NOT_key_byte_low, NOT_key_byte_high, Print, index, zero_byte, invalid_index  ; external subroutines
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
        ;movlw 0x0F ; only if no button is pressed
	;movwf PORTC, A
	;call clear_check_light
	call keyboard_start
	
	movlw 0x00
	movwf PORTH, A	;
	movwf PORTC, A
	call Recombine
	
	;call Is_button_pressed
	movf button_pressed
	movwf PORTD
	cpfslt zero_byte, A
	bra start            ; if no button is pressed
	
	
	;movf button_pressed
	;movwf PORTH
	;check if button is pressed
	;call Check_pressed   ; returns 0x00 in Wreg if no buton is pressed
	;cpfslt zero_byte, A
	;bra start            ; if no button is pressed
	
	; continue given button is pressed
	call Display_key_byte
	call Find_index
	call Display_index
	;call Print
	goto start ; call no_button_pressed    ; no lights on B when no key prssed

    
end start
 