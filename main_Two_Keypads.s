#include <xc.inc>

global	start, setup
extrn	keyboard_setup_E, LCD_Setup, keyboard_start_E, Recombine_E, Split_NOT_key_byte_E, Display_key_byte_E, Display_NOT_key_byte_E, Check_pressed_E, Find_index_E, Display_index_E, key_byte_E, NOT_key_byte_E, NOT_key_byte_low_E, NOT_key_byte_high_E, index_E, zero_byte, invalid_index  ; external subroutines
;extrn	LCD_Setup, LCD_Write_Message, Display_clear
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************

setup: 
	;;call	Two_keypad_setup	; setup keyboard
	call    two_keyboard_setup
	call	LCD_Setup
	goto	start
	
	; ******* Main programme ****************************************
start: 	
        movlw 0x00
	movwf PORTH, A	;
	movwf PORTC, A
	;;call two_keypad_start   ; identifies which pad is pressed and 
	
	call Keyboard_start_E
	call Recombine_E
	call Keyboard_start_D
	call Recombine_D
	
	;check if button is pressed
	call Check_pressed_E   ; returns 0x00 in Wreg if no buton is pressed
	cpfslt zero_byte, A
	bra start              ; if no button is pressed
	
	
	;;call Recombine_D
	
	;;call Check_pressed_E
	;;cpfslt zero_byte, A 
	;;call Check_pressed_D;if E not pressed
	;;call Check_pressed_D;if E is pressed
	
	;check if button is pressed
	call Check_pressed_E   ; returns 0x00 in Wreg if no buton is pressed
	movf button_on_E_pressed
	cpfslt zero_byte, A
	call Check_pressed_D          ; if no button on E is pressed
	; if button on E is pressed
	
	   
	   
	   ; continue given button is pressed
	call Display_key_byte_E
	;call Display_key_byte_D
	
	call Find_index_E
	call Display_index_E
	goto start ; call no_button_pressed    ; no lights on B when no key prssed

end start


