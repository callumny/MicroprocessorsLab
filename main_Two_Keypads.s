#include <xc.inc>

global	start, setup
;extrn  Two_keypad_setup, button_pressed_state, Display_E_and_D_press_state, E_and_D_press_state, Is_button_D_pressed, Check_pressed_2_D, Is_button_E_pressed, button_pressed_E,button_pressed_D, Check_pressed_2_E, Keypad_start_E, Keypad_start_D, Recombine_E, Recombine_D, Split_NOT_key_byte_E, Display_key_byte_E, Display_NOT_key_byte_E, Check_pressed_E, Find_index_E, Display_index_E, key_byte_E, NOT_key_byte_E, NOT_key_byte_low_E, NOT_key_byte_high_E, index_E, zero_byte, invalid_index  ; external subroutines

    
extrn    Two_keypad_setup, button_pressed_state, \
    Display_E_and_D_press_state, E_and_D_press_state, Is_button_D_pressed, Check_pressed_2_D, Is_button_E_pressed, Check_pressed_2_E, \
    Keypad_start_E, Keypad_start_D, \
    Recombine_E, Split_NOT_key_byte_E, Display_key_byte_E, Display_NOT_key_byte_E,\
    Find_index_E, Display_index_E, key_byte_E, NOT_key_byte_E, NOT_key_byte_low_E, NOT_key_byte_high_E, index_E,\
    Recombine_D, Split_NOT_key_byte_D, Display_key_byte_D, Display_NOT_key_byte_D,\
    Find_index_D, Display_index_D, key_byte_D, NOT_key_byte_D, NOT_key_byte_low_D, NOT_key_byte_high_D, index_D,\
    Display_E_press_state, Display_D_press_state,\
    button_pressed_state,\
    Invalid_button_press_one,\
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
	movwf TRISB, A	;
	movwf PORTH, A	;
	movwf PORTJ, A	;
	movwf PORTB, A	;	
	
	call Keypad_start_E
	call Recombine_E
	call Keypad_start_D
	call Recombine_D
	
	call Is_button_E_pressed
	call Is_button_D_pressed
	;call Display_E_press_state
	;call Display_D_press_state
	call E_and_D_press_state
	call Display_E_and_D_press_state ; F0 for portD, 0F for port E, FF for both pressed, 00 for neither pressed

        call Find_index_E   ; as for one keypad
	call Find_index_D   ; as for one keypad 
	
	
	movf button_pressed_state, 0, 0 ; 0x00 for no button pressed,0x0F for E pressed only, 0xF0 for D pressed only, 0xFF for E and D button is pressed 
	cpfslt zero_byte, A    ;   skip if f less than w, i.e skip if zero byte is less than button_pressed , which occurs whenever a button is pressed
	bra start    
	
	;check the buttons pressed are on only one port, i.e. check buttons on both ports keypads havent been pressed simultaneously
	movf button_pressed_state, 0, 0 ; 0x00 for no button pressed,0x0F for E pressed only, 0xF0 for D pressed only, 0xFF for E and D button is pressed       ; 
	cpfsgt FF_byte, A    ;   skip if f greater than w, i.e skip if FF byte is greater than button_pressed , which occurs whenever only one button on D or E is pressed, i.e valid press
	call Invalid_button_press_one ; shows 0x11, error light for if two buttons have been pressed, one on each keypad
	
	movf button_pressed_state, 0, 0 ; same check as above but now branches to start
	cpfsgt FF_byte, A
	bra start

	; retrieves index by identifying whether keypad E or D is pressed and then using single keypad indices
	call Two_keypad_find_index
	
	;check only one button is pressed on a given keypad, e.g if two buttons are pressed on keypad E then show error
	movf index, 0, 0
	cpfsgt invalid_index, A            ;   skip if f greater than w, i.e skip if FF byte is greater than button_pressed , which occurs whenever only on button on D or E is pressed, i.e valid press
	call Invalid_button_press_two      ; shows 0x22, error light for if two buttons have been pressed on one keypad
	movf index, 0, 0
	cpfsgt invalid_index, A
	bra start
	
	; lights to show if checks have been passed
        ;movlw 0xFF
	;movwf PORTJ, A
	
	call Display_two_keypad_index   ; displays index on portH

	movlw 100000000000
	call LCD_delay_ms; external subroutines
	nop
	
	movf index, 0, 0   ; moves value to w
	rlncf index, 0, 0  ; moves 2 x index to W, no carr bit has two most significant bits are zero anyways
        call Braille_table
	movwf PORTF, A
	goto start ; call no_button_pressed    ; no lights on B when no key prssed
	
Braille_table:
    addwf PCL, A
    retlw 00000000B;  shouldn't be an index thta corresponds to this, just a space to make the indices correct
    retlw 01000000B;    A
    retlw 01100000B;    B
    retlw 01000100B;	C
    retlw 01000110B;	D
    retlw 01000010B;	E
    retlw 01100100B;	F
    retlw 01100110B;	G
    retlw 01100010B;	H
    retlw 00100100B;	I
    retlw 00100110B;	J
    retlw 01010000B;	K
    retlw 01110000B;	L
    retlw 01010100B;	M
    retlw 01010110B;	N
    retlw 01010010B;	O
    retlw 01110100B;    P
    retlw 01110110B;    Q
    retlw 01110010B;    R
    retlw 00110100B;    S
    retlw 00110110B;    T
    retlw 01010001B;    U
    retlw 01110001B;    V
    retlw 00100111B;    W
    retlw 01010101B;    X
    retlw 01010111B;    Y
    retlw 01010011B;    Z
    retlw 00000000B; SF1
    retlw 00000000B; SF2
    retlw 00000000B; SF3
    retlw 00000000B; SF4
    retlw 00000000B; SF5
    retlw 00000000B; SF6

end start


