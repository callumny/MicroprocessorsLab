#include <xc.inc>
    
    
extrn LCD_Write_Message, start, setup, LCD_Send_Byte_D
    
global  keyboard_setup_E, keyboard_start_E, Recombine_E, Split_NOT_key_byte_E, Display_key_byte_E, Display_NOT_key_byte_E, Check_pressed_E, Find_index_E, Display_index_E, key_byte_E, NOT_key_byte_E, NOT_key_byte_low_E, NOT_key_byte_high_E, index_E, zero_byte, invalid_index  ; external subroutines
    
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
zero_byte:          ds 1
invalid_index:      ds 1
psect	uart_code,class=CODE
    
two_keyboard_setup:
    ;select the correct bank to work in
    banksel	PADCFG1 ; bank select register - because PADCFG1 is not in access RAM
    bsf REPU ; turns off all pullups on pins 
    banksel 0

    ;clear the LAT registers (remembers position of pull up registers)
    clrf LATD, A
    clrf LATC, A
    clrf LATH, A
    clrf LATF, A
    clrf LATB, A
    clrf LATE, A ; 
    
    ;set all the tristates to ouptuts
    movlw   0x00
    movwf   TRISB,A
    movwf   TRISC,A
    movwf   TRISH,A
    movwf   TRISF,A
    
    ; set zero_byte to 0x00 for comparisons
    movlw 0x00
    movwf zero_byte, A
    
    ; set invalid_index value
    movlw 0xff
    movwf invalid_index, A
    return
 
   
; ROUTINES FOR KEYPAD E
keyboard_start_E:
    
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
    ;movlw 5
    ;call  LCD_delay_ms	    
    
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
    ;movlw 5
    ;call  LCD_delay_ms	    
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
    ;below two lines for debugging
    ;movff   row_byte, PORTC,A
    ;movff   column_byte, PORTD, A
    
    movf    row_byte_E, W, A
    iorwf   column_byte_E, 0, 0	    ;compares contents of two addresses, if both bits are a 1, returns a 1, otherwise 0 (places in W reg)
    movwf   key_byte_E, A
    
    comf    key_byte_E, 0, 0          ; NOTS the key_byte and puts in wreg(for some reason need to do 0,0 instead of A, A,)
    movwf   NOT_key_byte_E, A         ; NOTS the keybyte, useful for checking if button is pressed
    return
    
Display_key_byte_E:
    movff   key_byte_E, PORTH, A
    return
    
Display_NOT_key_byte_E:
    movff   NOT_key_byte_E, PORTC, A
    return  
    
Find_index_E:    
    ;movf key_byte, W, A
    bra A_check

Found_index_E: ; exists as part
    movwf index_E, A
    return    

Check_pressed_E:
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
 
Display_index_E:
    movff   index_E, PORTC, A
    return

    
; ROUTINES FOR KEYPAD D
keyboard_start_D:
    
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
    ;movlw 5
    ;call  LCD_delay_ms	    
    
    ;Drive output bits low all at once
    movlw	0x00
    movwf	PORTD, A
    
    ;Read value from port and put it in row_byte
    movff PORTD, row_byte, A	 ;EtoD 
    
    ;Sets columns to be inputs 
    movlw 0xF0			; 11110000 ; PORTE 4-7 (columns) are inputs and Port E 0-3 (rows) are outputs
    movwf TRISD, A
    
    ;Call a delay to allow the TRIS voltage to settle
    movlw	10		; wait 40us
    call	LCD_delay_x4us
    ;movlw 5
    ;call  LCD_delay_ms	    
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
    
Display_key_byte_D:
    movff   key_byte_D, PORTH, A
    return
    
Display_NOT_key_byte_D:
    movff   NOT_key_byte_D, PORTC, A
    return  
    
Find_index_D:    
    ;movf key_byte, W, A
    bra Q_check

Found_index_D: ; exists as part
    movwf index_D, A
    return    

Check_pressed_D:
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
    movlw 1    ; index for A
    goto Found_index_D
    
R_check:
    movlw   10110111B
    cpfseq  key_byte_D, A
    bra S_check
    movlw 2    ; index for B
    goto Found_index_D
    
S_check:
    movlw   11010111B
    cpfseq  key_byte_D, A
    bra T_check
    movlw 3    ; index for C
    goto Found_index_D

T_check:
    movlw   11100111B
    cpfseq  key_byte_D, A
    bra U_check
    movlw 4    ; index for D
    goto Found_index_D
    
U_check:
    movlw   01111011B
    cpfseq  key_byte_D, A
    bra V_check
    movlw 5    ; index for E
    goto Found_index_D
    
V_check:
    movlw   10111011B
    cpfseq  key_byte_D, A
    bra W_check
    movlw 6    ; index for F
    goto Found_index_D
 
W_check:
    movlw   11011011B
    cpfseq  key_byte_D, A
    bra X_check
    movlw 7    ; index for G
    goto Found_index_D 
    
X_check:
    movlw   11101011B
    cpfseq  key_byte_D, A
    bra Y_check
    movlw 8    ; index for H
    goto Found_index_D     
    
Y_check:
    movlw   01111101B
    cpfseq  key_byte_D, A
    bra Z_check
    movlw 9    ; index for I
    goto Found_index_D
    
Z_check:
    movlw   10111101B
    cpfseq  key_byte_D, A
    bra SF1_check
    movlw 10    ; index for J
    goto Found_index_D 
    
SF1_check:
    movlw   11011101B
    cpfseq  key_byte_D, A
    bra SF2_check
    movlw 11    ; index for K
    goto Found_index_D 
    
SF2_check: 
    movlw 11101101B
    cpfseq  key_byte_D, A
    bra SF3_check
    movlw 12    ; index for L
    goto Found_index_D 

SF3_check:
    movlw 01111110B
    cpfseq  key_byte_D, A
    bra SF4_check
    movlw 13    ; index for M
    goto Found_index_D 
    
SF4_check:
    movlw 10111110B
    cpfseq  key_byte_D, A
    bra SF5_check
    movlw 14    ; index for N
    goto Found_index_D 

SF5_check:
    movlw 11011110B
    cpfseq  key_byte_D, A
    bra SF6_check
    movlw 15    ; index for 0
    goto Found_index_D 
    
SF6_check: 
    movlw 11101110B
    cpfseq  key_byte_D, A
    bra Invalid_check_D
    movlw 16    ; index for P
    goto Found_index_D 
    
Invalid_check_D:
    movf invalid_index, W, A
    goto Found_index_D
 
Display_index_D:
    movff   index_D, PORTC, A
    return

        
    
    
    
    
    
    
    

    
    
    
    
    
    
    
    
; ** a few delay routines below here as LCD timing can be quite critical **** from LCD.s
LCD_delay_ms:		    ; delay given in ms in W
	movwf	LCD_cnt_ms, A

lcdlp2:	movlw	250	    ; 1 ms delay
	call	LCD_delay_x4us	
	decfsz	LCD_cnt_ms, A
	bra	lcdlp2
	return
    
LCD_delay_x4us:		    ; delay given in chunks of 4 microsecond in W
	movwf	LCD_cnt_l, A	; now need to multiply by 16
	swapf   LCD_cnt_l, F, A	; swap nibbles
	movlw	0x0f	    
	andwf	LCD_cnt_l, W, A ; move low nibble to W
	movwf	LCD_cnt_h, A	; then to LCD_cnt_h
	movlw	0xf0	    
	andwf	LCD_cnt_l, F, A ; keep high nibble in LCD_cnt_l
	call	LCD_delay
	return

LCD_delay:			; delay routine	4 instruction loop == 250ns	    
	movlw 	0x00		; W=0
lcdlp1:	decf 	LCD_cnt_l, F, A	; no carry when 0x00 -> 0xff
	subwfb 	LCD_cnt_h, F, A	; no carry when 0x00 -> 0xff
	bc 	lcdlp1		; carry, then loop again
	return			; carry reset so return

	
    
end    



