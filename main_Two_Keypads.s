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
    button_pressed_state,\
    Invalid_button_press,\
    Display_two_keypad_index,\
    zero_byte, FF_byte, invalid_index,\
    index, Two_keypad_find_index,\
    Invalid_button_press_on_port_D,\
    Invalid_button_press_on_port_E,\
    Invalid_button_press_two,\
    LCD_delay_ms; external subroutines
; external subroutines	LCD_Setup, LCD_Write_Message, Display_clear
	
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
	movwf PORTH, A	;
	movwf PORTJ, A	;
	movwf PORTB, A	;	
	;movwf PORTC, A
	;;call two_keypad_start   ; identifies which pad is pressed and 
	
	call Keypad_start_E
	call Recombine_E
	call Keypad_start_D
	call Recombine_D
	
	; if button on E is pressed
	call Is_button_E_pressed
	call Is_button_D_pressed
	;call Display_E_press_state
	;call Display_D_press_state
	call E_and_D_press_state
	call Display_E_and_D_press_state
	;call Display_E_and_D_press_state
	
	; call find_index_e or d doesnt work here before he button_pressed_state comparison
        call Find_index_E
	call Find_index_D
	
	
	movf button_pressed_state, 0, 0 ; 0x00 for no button pressed,0x0F for E pressed only, 0xF0 for D pressed only, 0xFF for E and D button is pressed 
	cpfslt zero_byte, A    ;   skip if f less than w, i.e skip if zero byte is less than button_pressed , which occurs whenever a button is pressed
	bra start     
	
        ;call Find_index_E
	;call Find_index_D
	
	;check the buttons pressed are on only one port
	movf button_pressed_state, 0, 0 ; 0x00 for no button pressed,0x0F for E pressed only, 0xF0 for D pressed only, 0xFF for E and D button is pressed       ; 
	cpfsgt FF_byte, A    ;   skip if f greater than w, i.e skip if FF byte is greater than button_pressed , which occurs whenever only one button on D or E is pressed, i.e valid press
	call Invalid_button_press ;bra start  ;invalid
	
	movf button_pressed_state, 0, 0
	cpfsgt FF_byte, A      ; for some reason isnt going to next line when button_pressed_state is FF, although it does for the above test
	bra start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;checks that only one button pressed on a given port
        ;movf index_E, 0, 0
	;cpfsgt invalid_index, A            ;   skip if f greater than w, i.e skip if FF byte is greater than button_pressed , which occurs whenever only on button on D or E is pressed, i.e valid press
	;call Invalid_button_press_on_port_E
	
	;movf index_E, 0, 0
	;cpfsgt invalid_index, A
	;bra start
	
        ;movf index_D, 0, 0
	;cpfsgt invalid_index, A            ;   skip if f greater than w, i.e skip if FF byte is greater than button_pressed , which occurs whenever only on button on D or E is pressed, i.e valid press
	;call Invalid_button_press_on_port_D
	
	;movf index_D, 0, 0
	;cpfsgt invalid_index, A
	;bra start
;;;;;;;;;;;;;;;;;;;
	
	;better version of check for if the press is an invalid press on just one ports keypad
	call Two_keypad_find_index
	
	movf index, 0, 0
	cpfsgt invalid_index, A            ;   skip if f greater than w, i.e skip if FF byte is greater than button_pressed , which occurs whenever only on button on D or E is pressed, i.e valid press
	call Invalid_button_press_two         ; calls same invalid button pres function as if it was for two buttons pressed with one button on each keypad 
	
	movf index, 0, 0
	cpfsgt invalid_index, A
	bra start
	
        movlw 0xFF
	movwf PORTJ, A

	
	;call Display_key_byte_D
	call Display_two_keypad_index   ; displays index on portH
	;movlw 3
	;movwf PORTB, A

	;check if e or d is chosen
	movlw 100000000000
	call LCD_delay_ms; external subroutines
	nop
	

	goto start ; call no_button_pressed    ; no lights on B when no key prssed

end start


