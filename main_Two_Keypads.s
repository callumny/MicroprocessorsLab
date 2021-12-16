#include <xc.inc>

global	start, initialise, index_counter, read_index, counter,final_braille,final_alphabet,timer_counter,index,Delay_one_second,EM_counter
;extrn  Two_keypad_setup, button_pressed_state, Display_E_and_D_press_state, E_and_D_press_state, Is_button_D_pressed, Check_pressed_2_D, Is_button_E_pressed, button_pressed_E,button_pressed_D, Check_pressed_2_E, Keypad_start_E, Keypad_start_D, Recombine_E, Recombine_D, Split_NOT_key_byte_E, Display_key_byte_E, Display_NOT_key_byte_E, Check_pressed_E, Find_index_E, Display_index_E, key_byte_E, NOT_key_byte_E, NOT_key_byte_low_E, NOT_key_byte_high_E, index_E, zero_byte, invalid_index  ; external subroutines

    
extrn    Two_keypad_setup, button_pressed_state, \
    Display_E_and_D_press_state, E_and_D_press_state, Is_button_D_pressed, Check_pressed_2_D, Is_button_E_pressed, Check_pressed_2_E, \
    Keypad_start_E, Keypad_start_D, \
    Recombine_E, Split_NOT_key_byte_E,\
    Find_index_E, key_byte_E, NOT_key_byte_E, NOT_key_byte_low_E, NOT_key_byte_high_E, index_E,\
    Recombine_D, Split_NOT_key_byte_D,\
    Find_index_D, key_byte_D, NOT_key_byte_D, NOT_key_byte_low_D, NOT_key_byte_high_D, index_D,\
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
    Display_running,\
    Save_current_index, Set_saving_lfsr, Set_reading_lfsr,\
    Read_each_index,\
    Initialise_braille,\
    Braille_lookup,\
    Initialise_alphabet,\
    LCD_Setup, Alphabet_display,\
    Check_delay_set_key, Delay_set_key_state,\
    Find_indices_and_button_press_states,\
    Print_OM,\
    Display_clear,\
    Print_ST,\
    Set_Second_line,\
    Write_delay,\
    two_digit_number_display,\
    Initialise_numbers,\
    Print_EM,\
    Clear_EM,\
    Set_EM_counter
    ; external subroutines
; external subroutines	LCD_Setup, LCD_Write_Message, Display_clear
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
psect     udata_acs
index_counter:  ds  1 
timer_counter: ds 1
timer_counter_temp: ds 1
read_index: ds 1  
counter:    ds 1
final_braille: ds 1
final_alphabet: ds 1
EM_counter: ds	1
    
    
psect	code, abs	
rst: 	org 0x0
 	goto	super_setup

	; ******* Programme FLASH read Setup Code ***********************
super_setup:
    call    LCD_Setup
    call    Initialise_braille
    call    Initialise_alphabet
    call    Initialise_numbers
    call    Two_keypad_setup

   
    call    Print_OM
    call    Delay_one_second
    call    Delay_one_second
    bra	    timer_set
    
timer_set:
    call    LCD_Setup
    call    Print_ST
    call    Set_Second_line
    movlw   0x05
    movwf   timer_counter, A
    movlw 0x0F
    movwf PORTJ, A
    call    Delay_between_keypresses
    
timer_set_loop:
    ; NOW KEY IS PRESSED TO SET DELAY TIME: A = 1 SECOND, B = 2 SECOND ETC... (TIMER_COUNTER IS SET EQUAL TO INDEX OF PRESSED CHARACTER)
    
    ; generates row and column bytes for each keypad
    call Find_indices_and_button_press_states

    ; Check if any key has been pressed at all
    movf	button_pressed_state, 0, 0 ; 0x00 for no key pressed,0x0F for E pressed only, 0xF0 for D pressed only, 0xFF for E and D button is pressed 
    cpfslt	zero_byte, A    
    bra	timer_set_loop    ; no key pressed 
    
    ; at least one key is pressed, continue

    ; Check the key(s) pressed are on only one port, i.e. check buttons on both ports keypads havent been pressed simultaneously
    movf	button_pressed_state, 0, 0 ; 0x00 for no key pressed,0x0F for E pressed only, 0xF0 for D pressed only, 0xFF for E and D button is pressed 
    cpfsgt	FF_byte, A    
    call	Invalid_button_press_one ; keys on both keypads have been pressed simultaneously, 0x11 error light on PORTJ

    ; key(s) pressed are only one port, continue 
    
    movf	button_pressed_state, 0, 0 ; same check as above but now branches to start
    cpfsgt	FF_byte, A
    bra	timer_set_loop
    
    ; key(s) pressed are only one port, continue 

    ; retrieves index by identifying whether keypad E or D is pressed and then using single keypad indices
    call	Two_keypad_find_index 

    ; Check only one key is pressed on a given keypad, e.g if two buttons are pressed on keypad E then show error
    movf	index, 0, 0
    cpfsgt	FF_byte, A           
    call	Invalid_button_press_two      ; multiple keys have been pressed on one keypad, 0x22 error light on PORTJ
	    ; only one key pressed, continue
    movf	index, 0, 0 ; same check as above but now branches to start
    cpfsgt	invalid_index, A
    bra	timer_set_loop
	    ; only one key pressed, continue
	    
    ; VALID KEY PRESS
    call	Check_enter ; defines Enter_state: 0x00 for no enter pressed, 0xFF for enter is pressed

    movf	Enter_state, 0, 0 ; 0x00 for no enter pressed, 0xFF for enter is pressed
    cpfsgt	FF_byte, A 
    bra initialise      ;enter pressed
 
    movff index, timer_counter
    call    two_digit_number_display
    bra	timer_set_loop
    
    call Delay_between_keypresses
	
    movlw 0x00
    movwf PORTJ, A
    
    
    bra initialise 
initialise: ;more of an initialise stage
	
    call    LCD_Setup          ; just acts as clear here

    call    Set_saving_lfsr
    call    Set_reading_lfsr

    movlw   0x00
    movwf   index_counter, A ; number of letters that have been typed

    ;set all the tristates to ouptuts
    movlw   0x00
    movwf   TRISC,A ; index_counter is displayed on PORTC
    movwf   TRISH,A ; Braille characters are read onto PORTH
    movwf   TRISJ,A ; 0xFF on PORTJ while display is running, also shows error lights for invalid keypresses

    bra    EM_message

	; ******* Main programme ****************************************
EM_message: 	
    ;set EM_message_counter to 1
    call    Set_EM_counter
    call    Print_EM
    ;call    Delay_one_second
    ;call    LCD_Setup
    
    bra	    start
    
start:    
    
    ; Set PORTB and PORTF to output
    movlw	0x00
    movwf	PORTH, A	; Lowers all pegs 
    movwf	PORTJ, A	; set PORTJ back to 0x00 after display has finished

    ; generates row and column bytes for each keypad
    call Find_indices_and_button_press_states

    ; Check if any key has been pressed at all
    movf	button_pressed_state, 0, 0 ; 0x00 for no key pressed,0x0F for E pressed only, 0xF0 for D pressed only, 0xFF for E and D button is pressed 
    cpfslt	zero_byte, A    
    bra	start    ; no key pressed 
	    ; at least one key is pressed, continue

    ; Check the key(s) pressed are on only one port, i.e. check buttons on both ports keypads havent been pressed simultaneously
    movf	button_pressed_state, 0, 0 ; 0x00 for no key pressed,0x0F for E pressed only, 0xF0 for D pressed only, 0xFF for E and D button is pressed 
    cpfsgt	FF_byte, A    
    call	Invalid_button_press_one ; keys on both keypads have been pressed simultaneously, 0x11 error light on PORTJ
	    ; key(s) pressed are only one port, continue 
    movf	button_pressed_state, 0, 0 ; same check as above but now branches to start
    cpfsgt	FF_byte, A
    bra	start
	    ; key(s) pressed are only one port, continue 

    ; retrieves index by identifying whether keypad E or D is pressed and then using single keypad indices
    call	Two_keypad_find_index 

    ; Check only one key is pressed on a given keypad, e.g if two buttons are pressed on keypad E then show error
    movf	index, 0, 0
    cpfsgt	FF_byte, A           
    call	Invalid_button_press_two      ; multiple keys have been pressed on one keypad, 0x22 error light on PORTJ
	    ; only one key pressed, continue
    movf	index, 0, 0 ; same check as above but now branches to start
    cpfsgt	invalid_index, A
    bra	start
    ; only one key pressed, continue
	    
    ;clear the 'Enter Word' message after the first button is pressed
    call    Clear_EM

    ;ONLY VALID KEYPRESSES REMAINING
    call	Check_delay_set_key ; defines Enter_state: 0x00 for no enter pressed, 0xFF for enter is pressed
    movf	Delay_set_key_state, 0, 0 ; 0x00 for no enter pressed, 0xFF for enter is pressed
    cpfsgt	FF_byte, A 
    bra	timer_set       ;enter pressed


    ; Check if enter has been pressed
    call    Check_enter ; defines Enter_state: 0x00 for no enter pressed, 0xFF for enter is pressed

    movf	Enter_state, 0, 0 ; 0x00 for no enter pressed, 0xFF for enter is pressed
    cpfsgt	FF_byte, A 
    bra		Display       ;enter pressed
    ; no enter pressed, continue

    ;increment index_counter
    incf    index_counter, 1, 0

    ; Check length of word is less than 16 letters, once 16th letter is typed begin display subroutine
    call    Check_length

    movf    Length_state, 0, 0 
    cpfsgt  FF_byte, A    
    call    Save_current_index ; save index for 16th letter

    movf    Length_state, 0, 0 
    cpfsgt  FF_byte, A    
    call    Alphabet_display ; translate index to ASCII and write to LCD for 16th letter, as for another normal letter

    movf    Length_state, 0, 0 
    cpfsgt  FF_byte, A    
    bra	Display
	    ; word length less than 16 letters, continue

    ; display index_counter on PORTC
    call    Display_index_counter 

    ; Valid key press which is not the enter key and total word length is less than 16
    call    Save_current_index

    ; Translate index to ASCII and then save ASCII in word, then output letter on LCD
    call    Alphabet_display

    call    Delay_between_keypresses

    goto	start
Display:
    ; needs to read indexes in turn and display them
    
    ; word length is 0, no letters have been entered befor enter key was pressed, branch to start
 
    movf	index_counter, 0, 0  
    cpfslt	zero_byte, A    
    bra		start
    
    call Display_running ; 0xFF on PORTJ when display is running
    call Display_loop
  
    bra initialise	
    
Display_loop:
    
    call Read_each_index
    call    Braille_lookup
    movff final_braille, PORTH, A;show on braille
    
    movf timer_counter, 0, 0
    call Delay_in_seconds      ; number of seconds each character is displayed for

    movlw 0
    movwf PORTH, A;show on braille

    call Delay_between_braille_display ; time pased when changing between two braille chr=aracters, must be long enough to let solenoids demagnetise
    
    decfsz index_counter, A
    bra Display_loop
    return
   
Delay_in_seconds:
    movwf timer_counter_temp,A
dlp2:    
    call Delay_one_second
    decfsz timer_counter_temp, A
    bra dlp2
    return
   
Delay_one_second:
; literal stored in w for no. seconds
    movlw	250
    call	LCD_delay_ms
    call	LCD_delay_ms
    call	LCD_delay_ms
    call	LCD_delay_ms
    return

Delay_between_keypresses:
    movlw	250
    call	LCD_delay_ms
    ;call	LCD_delay_ms
    return

Delay_between_braille_display:
    movlw 250     ; LCD delay ms has a limit!!!!!!!!!!!!!
    call LCD_delay_ms; external subroutines
    call LCD_delay_ms; external subroutines dont uncomment this- too many delays
    return