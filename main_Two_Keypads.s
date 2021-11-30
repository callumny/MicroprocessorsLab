#include <xc.inc>

global	start, setup
;extrn  Two_keypad_setup, button_pressed_state, Display_E_and_D_press_state, E_and_D_press_state, Is_button_D_pressed, Check_pressed_2_D, Is_button_E_pressed, button_pressed_E,button_pressed_D, Check_pressed_2_E, Keypad_start_E, Keypad_start_D, Recombine_E, Recombine_D, Split_NOT_key_byte_E, Display_key_byte_E, Display_NOT_key_byte_E, Check_pressed_E, Find_index_E, Display_index_E, key_byte_E, NOT_key_byte_E, NOT_key_byte_low_E, NOT_key_byte_high_E, index_E, zero_byte, invalid_index  ; external subroutines

    
extrn    Two_keypad_setup, button_pressed_state, \
    Display_E_and_D_press_state, E_and_D_press_state, Is_button_D_pressed, Check_pressed_2_D, Is_button_E_pressed, Check_pressed_2_E, \
    Keypad_start_E, Keypad_start_D, \
    Recombine_E, Split_NOT_key_byte_E, Display_key_byte_E, Display_NOT_key_byte_E, Check_pressed_E,\
    Find_index_E, Display_index_E, key_byte_E, NOT_key_byte_E, NOT_key_byte_low_E, NOT_key_byte_high_E, index_E,\
    Recombine_D, Split_NOT_key_byte_D, Display_key_byte_D, Display_NOT_key_byte_D, Check_pressed_D,\
    Find_index_D, Display_index_D, key_byte_D, NOT_key_byte_D, NOT_key_byte_low_D, NOT_key_byte_high_D, index_D,\
    Display_E_press_state, Display_D_press_state,\
    zero_byte, invalid_index  ; external subroutines;extrn	LCD_Setup, LCD_Write_Message, Display_clear
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************

setup: 
	;;call	Two_keypad_setup	; setup keyboard
	call    Two_keypad_setup
	;call	LCD_Setup
	goto	start
	
	; ******* Main programme ****************************************
start: 	
        movlw 0x00
	;movwf PORTH, A	;
	;movwf PORTC, A
	;;call two_keypad_start   ; identifies which pad is pressed and 
	
	call Keypad_start_E
	call Recombine_E
	call Keypad_start_D
	call Recombine_D
	;call Display_key_byte_E
	;call Display_key_byte_D
	;check if button is pressed
	;call Check_pressed_E   ; returns 0x00 in Wreg if no buton is pressed
	;cpfslt zero_byte, A
	;bra start              ; if no button is pressed
	

	
	
	; if button on E is pressed
	call Is_button_E_pressed
	call Is_button_D_pressed
	call Display_E_press_state
	call Display_D_press_state
	call E_and_D_press_state
	call Display_E_and_D_press_state
	;call Display_E_and_D_press_state
	

	goto start ; call no_button_pressed    ; no lights on B when no key prssed

end start


