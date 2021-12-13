#include <xc.inc>

global	start, setup, index_counter, read_index, counter,final_braille,final_alphabet
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
    LCD_delay_ms,\
    Display_index_counter,\
    Check_enter, Check_length,\
    Enter_state, Length_state,\
    Display_index_counter_word,\
    Save_current_index, Set_saving_lfsr, Set_reading_lfsr,\
    Read_each_index,\
    Initialise_braille,\
    Braille_lookup; external subroutines
; external subroutines	LCD_Setup, LCD_Write_Message, Display_clear
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
psect     udata_acs
index_counter:  ds  1  
read_index: ds 1  
counter:    ds 1
final_braille: ds 1
final_alphabet: ds 1
    
    
psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************

setup: 
	;movlw 0xFF
	;movwf PORTH
	movlw 0x00
	movwf index_counter, A ; tells you what index we are at
	;;call	Two_keypad_setup	; setup keyboard
	call    Two_keypad_setup
	
	call	Initialise_braille
	;call	Initialise_alphabet
	
	call    Set_saving_lfsr
	call    Set_reading_lfsr
	
	;call	LCD_Setup
	goto	start
	
	; ******* Main programme ****************************************
start: 	
    
	
        movlw 0x00
	movwf TRISB, A	;
	movwf TRISF, A	;
	
	movwf PORTH, A	;
	movwf PORTJ, A	;
	;movwf PORTB, A	; when this line is commented out the correct braille displays on portB
	; but i only want it to show braille when im holding the keypress down, cant seem to gte that to work
	
	call Keypad_start_E
	call Recombine_E
	call Keypad_start_D
	call Recombine_D
	
	call Is_button_E_pressed
	call Is_button_D_pressed
	;call Display_E_press_state
	;call Display_D_press_state
	call E_and_D_press_state
	;call Display_E_and_D_press_state ; F0 for portD, 0F for port E, FF for both pressed, 00 for neither pressed

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

	;;;;;; we have index !!!!
	;increment index_counter
	movlw 1
	addwf index_counter, A
	
	call Check_enter ; writes the state to enter_length_check_byte
	call Check_length
	
	movf Enter_state, 0, 0 ; same check as above but now branches to start
	cpfsgt FF_byte, A ; no enter pressed
	decf index_counter, 1  ; decrements word length by one to not include enter key press as an extra leter count in the word
	
	movf Enter_state, 0, 0 ; same check as above but now branches to start
	cpfsgt FF_byte, A ; no enter pressed
	bra Display       ;enter pressed
	;continue to check length

	movf Length_state, 0, 0 ; 0x00 for no button pressed,0x0F for E pressed only, 0xF0 for D pressed only, 0xFF for E and D button is pressed 
	cpfsgt FF_byte, A    ;  skip if f less than w, i.e skip if zero byte is less than button_pressed , which occurs whenever a button is pressed  
	call Save_current_index;i want to save the index of the 16th letter and then go onto display;  ;bra Display;display subroutine ;length i gtretaer than 16
	;continue
	movf Length_state, 0, 0 ; 0x00 for no button pressed,0x0F for E pressed only, 0xF0 for D pressed only, 0xFF for E and D button is pressed 
	cpfsgt FF_byte, A    ;  skip if f less than w, i.e skip if zero byte is less than button_pressed , which occurs whenever a button is pressed  
	bra Display;display subroutine ;length i gtretaer than 16
	
	call	Display_index_counter 
	
	; OUR INDEX IS NOT AN ENTER AND OUR WORD IS NOT TOO LONG
	call Save_current_index
	
	
	
	movf index, 0, 0   ; moves value to w
	rlncf index, 0, 0  ; moves 2 x index to W, no carr bit has two most significant bits are zero anyways
        ; stop calling braille table because braille table is overflowing
	;call Braille_table
	;movwf PORTF, A
	;DELAY
	movlw 100      ; LCD delay ms has a limit!!!!!!!!!!!!!

	call LCD_delay_ms; external subroutines
	call LCD_delay_ms; external subroutines
	;call LCD_delay_ms; external subroutines
	nop
	movlw 0x00
	movwf PORTF, A
	goto start
Display:
    ; needs to read indexes in turn and display them
    call Display_index_counter_word ; should only show 16
    call Display_loop
    
    ;;;;;;DELAY
    movlw 100     ; LCD delay ms has a limit!!!!!!!!!!!!!
    call LCD_delay_ms; external subroutines
    call LCD_delay_ms; external subroutines
    ;call LCD_delay_ms; external subroutines
    nop
    bra setup	
    
Display_loop:
    ;movlw 0x01
    ;movwf PORTB, A
    
    call Read_each_index
    ;movlw 1
    ;movwf    read_index, A
    ;movf read_index, 0, 0
    call    Braille_lookup
    movff final_braille, PORTB, A;show on braille
    ;movwf PORTB, A
    movlw 100     ; LCD delay ms has a limit!!!!!!!!!!!!!
    call LCD_delay_ms; external subroutines
    call LCD_delay_ms; external subroutines dont uncomment this- too many delays
    ;call LCD_delay_ms; external subroutines
    ;call LCD_delay_ms
    
    movlw 0
    movwf PORTB, A;show on braille
    movlw 100     ; LCD delay ms has a limit!!!!!!!!!!!!!
    call LCD_delay_ms; external subroutines
    call LCD_delay_ms; external subroutines dont uncomment this- too many delays
    ;call LCD_delay_ms; external subroutines    
    nop
    decfsz index_counter, A
    bra Display_loop
    return
   
    ;nop ;comment out for sf4 key to work, for some reason the number of lines before PCL line affects the last look up possible in the look up table  

    ;end Braille_table
    ;
    ;

    
    
end start


