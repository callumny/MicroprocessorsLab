#include <xc.inc>
    
    
extrn LCD_Write_Message, start, setup, LCD_Send_Byte_D
    
global  keyboard_setup, keyboard_start, Recombine, Split_NOT_key_byte, Display_key_byte, Display_NOT_key_byte, Check_pressed, Find_index, Display_index, key_byte, NOT_key_byte, NOT_key_byte_low, NOT_key_byte_high, Print, index, zero_byte, invalid_index  ; external subroutines

psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data

psect	data    
	; ******* myTable, data in programme memory, and its length *****
myTable:	
	db	'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P'
	myTable_l   EQU	16	; length of data
	align	2
	
    
psect	udata_acs   ; reserve data space in access ram
LCD_cnt_l:	ds 1   ; reserve 1 byte for variable LCD_cnt_l
LCD_cnt_h:	ds 1   ; reserve 1 byte for variable LCD_cnt_h
LCD_cnt_ms:	    ds 1   ; reserve 1 byte for ms counter
row_byte:	    ds 1   ; reserve 1 byte for row byte
column_byte:	    ds 1   ; reserve 1 byte for column byte
key_byte:	    ds 1   ; reserve 1 byte for combined row and column  
NOT_key_byte:	    ds 1   ; reserve 1 byte for NOTTED keybyte, useful for checking if button pressed
index:	            ds 1   ;reserve 1 byte for final index value
NOT_key_byte_low:	    ds 1   ; reserve 1 byte for NOTTED keybyte, useful for checking if button pressed	
NOT_key_byte_high:	    ds 1   ; reserve 1 byte for NOTTED keybyte, useful for checking if button pressed  
zero_byte:          ds 1
invalid_index:      ds 1
psect	uart_code,class=CODE
    
keyboard_setup:
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
    movwf   TRISD,A
    movwf   TRISC,A
    movwf   TRISH,A
    movwf   TRISF,A
    
    ; set zero_byte to 0x00 for comparisons
    movlw 0x00
    movwf zero_byte, A
    
    ; set invalid_index value
    movlw 32
    movwf invalid_index, A
    return
    
keyboard_start:
    
    ;clears the column byte
    movlw   0x00
    movwf   row_byte , A
    movwf   column_byte, A
    
    
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
    movff PORTE, row_byte, A	 ;EtoD 
    
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
    movff PORTE, column_byte, A 
    return
    
Split_NOT_key_byte:
    movff NOT_key_byte, NOT_key_byte_low
    movlw 0x0f
    andwf NOT_key_byte_low, 1,0
    movff NOT_key_byte, NOT_key_byte_high
    movlw 0xf0
    andwf NOT_key_byte_high, 1,0	
    return
Recombine:

    ;Combines row and column into one byte containing all the information
    ;below two lines for debugging
    ;movff   row_byte, PORTC,A
    ;movff   column_byte, PORTD, A
    
    movf    row_byte, W, A
    iorwf   column_byte, 0, 0	    ;compares contents of two addresses, if both bits are a 1, returns a 1, otherwise 0 (places in W reg)
    movwf   key_byte, A
    
    comf    key_byte, 0, 0          ; NOTS the key_byte and puts in wreg(for some reason need to do 0,0 instead of A, A,)
    movwf   NOT_key_byte, A         ; NOTS the keybyte, useful for checking if button is pressed
    return
    
Display_key_byte:
    movff   key_byte, PORTH, A
    return
    
Display_NOT_key_byte:
    movff   NOT_key_byte, PORTC, A
    return  
    
Find_index:    
    ;movf key_byte, W, A
    bra A_check

Found_index: ; exists as part
    movwf index, A
    return    

Check_pressed:
    call Split_NOT_key_byte
    movlw 0x00
    cpfsgt NOT_key_byte_low, A
    retlw 0x00       ;goto start                      ; if all 00000000 i.e no button is pressed
    cpfsgt NOT_key_byte_high, A
    retlw 0x00;
    movlw 0xff
    return
    
A_check: 
    movlw   01110111B
    cpfseq  key_byte, A
    bra B_check
    movlw 0    ; index for A
    goto Found_index
    
B_check:
    movlw   10110111B
    cpfseq  key_byte, A
    bra C_check
    movlw 1    ; index for B
    goto Found_index
    
C_check:
    movlw   11010111B
    cpfseq  key_byte, A
    bra D_check
    movlw 2    ; index for C
    goto Found_index

D_check:
    movlw   11100111B
    cpfseq  key_byte, A
    bra E_check
    movlw 3    ; index for D
    goto Found_index
    
E_check:
    movlw   01111011B
    cpfseq  key_byte, A
    bra F_check
    movlw 4    ; index for E
    goto Found_index
    
F_check:
    movlw   10111011B
    cpfseq  key_byte, A
    bra G_check
    movlw 5    ; index for F
    goto Found_index
 
G_check:
    movlw   11011011B
    cpfseq  key_byte, A
    bra H_check
    movlw 6    ; index for G
    goto Found_index 
    
H_check:
    movlw   11101011B
    cpfseq  key_byte, A
    bra I_check
    movlw 7    ; index for H
    goto Found_index     
    
I_check:
    movlw   01111101B
    cpfseq  key_byte, A
    bra J_check
    movlw 8    ; index for I
    goto Found_index
    
J_check:
    movlw   10111101B
    cpfseq  key_byte, A
    bra K_check
    movlw 9    ; index for J
    goto Found_index 
    
K_check:
    movlw   11011101B
    cpfseq  key_byte, A
    bra L_check
    movlw 10    ; index for K
    goto Found_index 
    
L_check: 
    movlw 11101101B
    cpfseq  key_byte, A
    bra M_check
    movlw 11    ; index for L
    goto Found_index 

M_check:
    movlw 01111110B
    cpfseq  key_byte, A
    bra N_check
    movlw 12    ; index for M
    goto Found_index 
    
N_check:
    movlw 10111110B
    cpfseq  key_byte, A
    bra O_check
    movlw 13    ; index for N
    goto Found_index 

O_check:
    movlw 11011110B
    cpfseq  key_byte, A
    bra P_check
    movlw 14    ; index for 0
    goto Found_index 
    
P_check: 
    movlw 11101110B
    cpfseq  key_byte, A
    bra Invalid_check
    movlw 15    ; index for P
    goto Found_index 
    
Invalid_check:
    movf invalid_index, W, A
    goto Found_index

    
    
Display_index:
    movff   index, PORTC, A
    return
    
Print:
; read the corresponding value
	lfsr	0, myArray	; Load FSR0 with address in RAM	
	movlw	low highword(myTable)	; address of data in PM
	movwf	TBLPTRU, A		; load upper bits to TBLPTRU
	movlw	high(myTable)	; address of data in PM
	movwf	TBLPTRH, A		; load high byte to TBLPTRH
	movlw	low(myTable)	; address of data in PM
	movwf	TBLPTRL, A		; load low byte to TBLPTRL
	
	movf	index, A
	addwfc	TBLPTRL, A
	movwf	TBLPTRL, A
	
	movlw	1
	lfsr	2, myArray
	call	LCD_Write_Message 
	
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



