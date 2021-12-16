#include <xc.inc>
    
    
extrn LCD_Write_Message, start, initialise, LCD_Send_Byte_D
    
global    Two_keypad_setup, button_pressed_state, \
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
    Find_indices_and_button_press_states,\
    LCD_delay_ms,\
    lcdlp2,\
    LCD_delay_x4us,\
    LCD_delay,\
    lcdlp1
    
    ; external subroutines
    
psect	udata_acs   ; reserve data space in access ram
LCD_cnt_l:	ds 1   ; reserve 1 byte for variable LCD_cnt_l
LCD_cnt_h:	ds 1   ; reserve 1 byte for variable LCD_cnt_h
LCD_cnt_ms:	    ds 1   ; reserve 1 byte for ms counter
row_byte_E:	    ds 1   ; reserve 1 byte for row byte
column_byte_E:	    ds 1   ; reserve 1 byte for column byte
key_byte_E:	    ds 1   ; reserve 1 byte for combined row and column  
NOT_key_byte_E:	    ds 1   ; reserve 1 byte for NOTTED keybyte, useful for checking if button pressed
index_E:	            ds 1   ;reserve 1 byte for final index value
NOT_key_byte_low_E:	    ds 1   ; reserve 1 byte for NOTTED keybyte, useful for checking if button pressed	
NOT_key_byte_high_E:	    ds 1   ; reserve 1 byte for NOTTED keybyte, useful for checking if button pressed  
row_byte_D:	    ds 1   ; reserve 1 byte for row byte
column_byte_D:	    ds 1   ; reserve 1 byte for column byte
key_byte_D:	    ds 1   ; reserve 1 byte for combined row and column  
NOT_key_byte_D:	    ds 1   ; reserve 1 byte for NOTTED keybyte, useful for checking if button pressed
index_D:	            ds 1   ;reserve 1 byte for final index value
NOT_key_byte_low_D:	    ds 1   ; reserve 1 byte for NOTTED keybyte, useful for checking if button pressed	
NOT_key_byte_high_D:	    ds 1   ; reserve 1 byte for NOTTED keybyte, useful for checking if button pressed  
button_pressed_E: ds 1
button_pressed_D: ds 1
button_pressed_state: ds 1         ; reserve 1 byte for if E or D is pressed or both
zero_byte:          ds 1
FF_byte:            ds 1
OF_byte:            ds 1
invalid_index:      ds 1
index:              ds 1
;psect	uart_code,class=CODE
psect	keypad_code,class=CODE
    
Two_keypad_setup:
    ;select the correct bank to work in
    banksel	PADCFG1 ; bank select register - because PADCFG1 is not in access RAM
    bsf REPU ; turns off all pullups on pins 
    bsf RDPU
    banksel 0
    
    ; set zero_byte to 0x00 for comparisons
    movlw 0x00
    movwf zero_byte, A
    
    ; set FF_byte to 0x00 for comparisons
    movlw 0xFF
    movwf FF_byte, A
    
    ; set 0F_byte to 0x00 for comparisons
    movlw 0x0F
    movwf OF_byte, A
    
    ; set button presses to none pressed initially
    movlw 0x00
    movwf button_pressed_E, A
    movwf button_pressed_D, A
    movwf button_pressed_state, A
    
    ; set invalid_index value
    movlw 0xFF
    movwf invalid_index, A
    return
 
   
; ROUTINES FOR KEYPAD E
Keypad_start_E:
    
    ;clears the column byte
    movlw   0x00
    movwf   row_byte_E, A
    movwf   column_byte_E, A
    
    ;Sets rows to be inputs
    movlw 0x0F; 00001111 ; PORTE 4-7 (columns) are outputs and Port E 0-3 (rows) are inputs
    movwf TRISE, A
    
    ;Call a delay to allow the TRIS voltage to settle
    movlw	10		; wait 40us
    call	LCD_delay_x4us   
    
    ;Drive output bits low all at once
    movlw	0x00
    movwf	PORTE, A
    
    ;Read value from port and put it in row_byte
    movff PORTE, row_byte_E, A	 ;EtoD 
    
    ;Sets columns to be inputs 
    movlw 0xF0			; 11110000 ; PORTE 4-7 (columns) are inputs and Port E 0-3 (rows) are outputs
    movwf TRISE, A
    
    ;Call a delay to allow the TRIS voltage to settle
    movlw	10		; wait 40us
    call	LCD_delay_x4us
    
    ;Drive output bits low all at once
    movlw	0x00
    movwf	PORTE, A
    
    ;Read value from port and put it in column_byte
    movff PORTE, column_byte_E, A 
    return
    
Split_NOT_key_byte_E:
    movff NOT_key_byte_E, NOT_key_byte_low_E
    movlw 0x0f
    andwf NOT_key_byte_low_E, 1,0
    movff NOT_key_byte_E, NOT_key_byte_high_E
    movlw 0xf0
    andwf NOT_key_byte_high_E, 1,0	
    return
    
Recombine_E:
    ;Combines row and column into one byte containing all the information
   
    movf    row_byte_E, W, A
    iorwf   column_byte_E, 0, 0	    ;compares contents of two addresses, if both bits are a 1, returns a 1, otherwise 0 (places in W reg)
    movwf   key_byte_E, A
    
    comf    key_byte_E, 0, 0          ; NOTS the key_byte and puts in wreg(for some reason need to do 0,0 instead of A, A,)
    movwf   NOT_key_byte_E, A         ; NOTS the keybyte, useful for checking if button is pressed
    return
    
Find_index_E:    
    bra A_check

Found_index_E: ; saves returned value in wreg to index_E byte
    movwf index_E, A
    return    

Is_button_E_pressed: 
    ; saves value in w reg from check_pressed_2_E to button_pressed_state_E
    call Check_pressed_2_E
    movwf button_pressed_E, A
    return    ; returns to main
    
Check_pressed_2_E:
    call Split_NOT_key_byte_E
    movlw 0x00
    cpfsgt NOT_key_byte_low_E, A
    retlw 0x00       ; no button pressed returns 0
    cpfsgt NOT_key_byte_high_E, A
    retlw 0x00       ; no button pressed returns 0  
    movlw 0x0F
    return  
    
A_check: 
    movlw   01110111B
    cpfseq  key_byte_E, A
    bra B_check
    movlw 1    ; index for A
    goto Found_index_E
    
B_check:
    movlw   10110111B
    cpfseq  key_byte_E, A
    bra C_check
    movlw 2    ; index for B
    goto Found_index_E
    
C_check:
    movlw   11010111B
    cpfseq  key_byte_E, A
    bra D_check
    movlw 3    ; index for C
    goto Found_index_E

D_check:
    movlw   11100111B
    cpfseq  key_byte_E, A
    bra E_check
    movlw 4    ; index for D
    goto Found_index_E
    
E_check:
    movlw   01111011B
    cpfseq  key_byte_E, A
    bra F_check
    movlw 5    ; index for E
    goto Found_index_E
    
F_check:
    movlw   10111011B
    cpfseq  key_byte_E, A
    bra G_check
    movlw 6    ; index for F
    goto Found_index_E
 
G_check:
    movlw   11011011B
    cpfseq  key_byte_E, A
    bra H_check
    movlw 7    ; index for G
    goto Found_index_E 
    
H_check:
    movlw   11101011B
    cpfseq  key_byte_E, A
    bra I_check
    movlw 8    ; index for H
    goto Found_index_E     
    
I_check:
    movlw   01111101B
    cpfseq  key_byte_E, A
    bra J_check
    movlw 9    ; index for I
    goto Found_index_E
    
J_check:
    movlw   10111101B
    cpfseq  key_byte_E, A
    bra K_check
    movlw 10    ; index for J
    goto Found_index_E 
    
K_check:
    movlw   11011101B
    cpfseq  key_byte_E, A
    bra L_check
    movlw 11    ; index for K
    goto Found_index_E 
    
L_check: 
    movlw 11101101B
    cpfseq  key_byte_E, A
    bra M_check
    movlw 12    ; index for L
    goto Found_index_E 

M_check:
    movlw 01111110B
    cpfseq  key_byte_E, A
    bra N_check
    movlw 13    ; index for M
    goto Found_index_E 
    
N_check:
    movlw 10111110B
    cpfseq  key_byte_E, A
    bra O_check
    movlw 14    ; index for N
    goto Found_index_E 

O_check:
    movlw 11011110B
    cpfseq  key_byte_E, A
    bra P_check
    movlw 15    ; index for 0
    goto Found_index_E 
    
P_check: 
    movlw 11101110B
    cpfseq  key_byte_E, A
    bra Invalid_check_E
    movlw 16    ; index for P
    goto Found_index_E 
    
Invalid_check_E:
    movf invalid_index, W, A
    goto Found_index_E
    
; ROUTINES FOR KEYPAD D
Keypad_start_D:
    
    ;clears the column byte
    movlw   0x00
    movwf   row_byte_D, A
    movwf   column_byte_D, A
    
    
    ;Sets rows to be inputs
    movlw 0x0F; 00001111 ; PORTD 4-7 (columns) are outputs and Port D 0-3 (rows) are inputs
    movwf TRISD, A
    
    ;Call a delay to allow the TRIS voltage to settle
    movlw	10		; wait 40us
    call	LCD_delay_x4us

    ;Drive output bits low all at once
    movlw	0x00
    movwf	PORTD, A
    
    ;Read value from port and put it in row_byte
    movff PORTD, row_byte_D, A	 ;EtoD 
    
    ;Sets columns to be inputs 
    movlw 0xF0			; 11110000 ; PORTE 4-7 (columns) are inputs and Port E 0-3 (rows) are outputs
    movwf TRISD, A
    
    ;Call a delay to allow the TRIS voltage to settle
    movlw	10		; wait 40us
    call	LCD_delay_x4us
	    
    ;Drive output bits low all at once
    movlw	0x00
    movwf	PORTD, A
    
    ;Read value from port and put it in column_byte
    movff PORTD, column_byte_D, A 
    return
    
Split_NOT_key_byte_D:
    movff NOT_key_byte_D, NOT_key_byte_low_D
    movlw 0x0f
    andwf NOT_key_byte_low_D, 1,0
    movff NOT_key_byte_D, NOT_key_byte_high_D
    movlw 0xf0
    andwf NOT_key_byte_high_D, 1,0	
    return
    
Recombine_D:

    ;Combines row and column into one byte containing all the information
    ;below two lines for debugging
    ;movff   row_byte, PORTC,A
    ;movff   column_byte, PORTD, A
    
    movf    row_byte_D, W, A
    iorwf   column_byte_D, 0, 0	    ;compares contents of two addresses, if both bits are a 1, returns a 1, otherwise 0 (places in W reg)
    movwf   key_byte_D, A
    
    comf    key_byte_D, 0, 0          ; NOTS the key_byte and puts in wreg(for some reason need to do 0,0 instead of A, A,)
    movwf   NOT_key_byte_D, A         ; NOTS the keybyte, useful for checking if button is pressed
    return
    
Find_index_D:    
    ;movf key_byte, W, A
    bra Q_check

Found_index_D: ; exists as part
    movwf index_D, A
    return    
    
Is_button_D_pressed:
    call Check_pressed_2_D
    movwf button_pressed_D, A
    return    ; returns to main
    
Check_pressed_2_D:
    call Split_NOT_key_byte_D
    movlw 0x00
    cpfsgt NOT_key_byte_low_D, A
    retlw 0x00       ; no button pressed returns 0
    cpfsgt NOT_key_byte_high_D, A
    retlw 0x00       ; no button pressed returns 0  
    movlw 0xF0
    return  
    
Q_check: 
    movlw   01110111B
    cpfseq  key_byte_D, A
    bra R_check
    movlw 17    ; index for A
    goto Found_index_D
    
R_check:
    movlw   10110111B
    cpfseq  key_byte_D, A
    bra S_check
    movlw 18    ; index for B
    goto Found_index_D
    
S_check:
    movlw   11010111B
    cpfseq  key_byte_D, A
    bra T_check
    movlw 19    ; index for C
    goto Found_index_D

T_check:
    movlw   11100111B
    cpfseq  key_byte_D, A
    bra U_check
    movlw 20    ; index for D
    goto Found_index_D
    
U_check:
    movlw   01111011B
    cpfseq  key_byte_D, A
    bra V_check
    movlw 21    ; index for E
    goto Found_index_D
    
V_check:
    movlw   10111011B
    cpfseq  key_byte_D, A
    bra W_check
    movlw 22    ; index for F
    goto Found_index_D
 
W_check:
    movlw   11011011B
    cpfseq  key_byte_D, A
    bra X_check
    movlw 23   ; index for G
    goto Found_index_D 
    
X_check:
    movlw   11101011B
    cpfseq  key_byte_D, A
    bra Y_check
    movlw 24    ; index for H
    goto Found_index_D     
    
Y_check:
    movlw   01111101B
    cpfseq  key_byte_D, A
    bra Z_check
    movlw 25   ; index for I
    goto Found_index_D
    
Z_check:
    movlw   10111101B
    cpfseq  key_byte_D, A
    bra SF1_check
    movlw 26    ; index for J
    goto Found_index_D 
    
SF1_check:
    movlw   11011101B
    cpfseq  key_byte_D, A
    bra SF2_check
    movlw 27    ; index for K
    goto Found_index_D 
    
SF2_check: 
    movlw   11101101B
    cpfseq  key_byte_D, A
    bra SF3_check
    movlw 28    ; index for L
    goto Found_index_D 

SF3_check:
    movlw   01111110B
    cpfseq  key_byte_D, A
    bra SF4_check
    movlw 29    ; index for M
    goto Found_index_D 
    
SF4_check:
    movlw   10111110B
    cpfseq  key_byte_D, A
    bra SF5_check
    movlw 30    ; index for N
    goto Found_index_D 

SF5_check:
    movlw   11011110B
    cpfseq  key_byte_D, A
    bra SF6_check
    movlw 31    ; index for 0
    goto Found_index_D 
    
SF6_check: 
    movlw   11101110B
    cpfseq  key_byte_D, A
    bra Invalid_check_D
    movlw 32    ; index for P
    goto Found_index_D 
    
Invalid_check_D:
    movf invalid_index, W, A
    goto Found_index_D
    
E_and_D_press_state:
    movf    button_pressed_E, W, A
    iorwf   button_pressed_D, 0, 0	    ;compares contents of two addresses, if both bits are a 1, returns a 1, otherwise 0 (places in W reg)
    movwf   button_pressed_state, A         ; 0F for only E, F0 for only D, FF for both pressed, 00 for neither pressed
    return
    
Display_E_and_D_press_state:
    movff button_pressed_state, PORTC, A
    return
    
    
; Different displays on PORTJ for different types of errors    
Invalid_button_press_one: ;
    movlw 0x11
    movwf PORTJ, A
    nop
    movlw 1000000000000000000
    call LCD_delay_ms
    return

Invalid_button_press_on_port_E:
    movlw 0x0A
    movwf PORTJ, A
    movlw 1000000000000000000
    call LCD_delay_ms
    return

Invalid_button_press_on_port_D:
    movlw 0xA0
    movwf PORTJ, A
    movlw 1000000000000000000
    call LCD_delay_ms
    return
    
Invalid_button_press_two:
    movlw 0x22
    movwf PORTJ, A
    movlw 1000000000000000000
    call LCD_delay_ms
    return
    
    
; Find index for keypressed
Two_keypad_find_index:
    movf button_pressed_state, A
    cpfseq OF_byte, A    ; skip if only portE keypad is pressed
    bra set_index_D      ;movff index_D, index ;port D is pressed
    bra set_index_E      ;movff index_E, index ;port E is pressed
    ;return
    
set_index_D:
    movff index_D, index ;port D is pressed
    return
    
set_index_E:
    movff index_E, index ;port E is pressed
    return
    
Display_two_keypad_index:
    movff index, PORTH, A
    return    
    
Find_indices_and_button_press_states:    
	call	Keypad_start_E
	call	Keypad_start_D
	
	; Recombines row and column bytes for each keypad
	call	Recombine_E
	call	Recombine_D
	
	; Creating button_press_state to determine which keypad has been pressed
	call	Is_button_E_pressed ; sets button_pressed_state_E to 0x0F for port E keypad pressed
	call	Is_button_D_pressed ; sets button_pressed_state_D to 0xF0 for port D keypad pressed
	call	E_and_D_press_state ;defines button_pressed_state: 0xF0 for portD, 0x0F for port E, 0xFF for both pressed, 0x00 for neither pressed

	; Finding corresponding index for a keypress for each keypad
        call	Find_index_E   ; finds index of keypress for keypad connected to PORTE
	call	Find_index_D   ; finds index of keypress for keypad connected to PORTD 
	return
	
    	

end    



