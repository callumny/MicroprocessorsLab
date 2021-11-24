#include <xc.inc>
    
    
extrn LCD_Write_Message, start, setup, LCD_Send_Byte_D
    
global  keyboard_setup, keyboard_start, Recombine, Find_index, Place_index, Print, check_light, clear_check_light, key_byte, Check_button_pressed
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
myArray:    ds 0x80 ; reserve 128 bytes for message data

psect	data    
	; ******* myTable, data in programme memory, and its length *****
myTable:	
	db	'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P'
	myTable_l   EQU	16	; length of data
	align	2
    
psect	udata_acs   ; reserve data space in access ram
keyboard_counter: ds    1	    ; reserve 1 byte for variable keyboard_counter
LCD_cnt_l:	ds 1   ; reserve 1 byte for variable LCD_cnt_l
LCD_cnt_h:	ds 1   ; reserve 1 byte for variable LCD_cnt_h
LCD_cnt_ms:	    ds 1   ; reserve 1 byte for ms counter
row_byte:	    ds 1   ; reserve 1 byte for row byte
column_byte:	    ds 1   ; reserve 1 byte for column byte
key_byte:	    ds 1   ; reserve 1 byte for combined row and column  
index_final:	    ds	1   ;reserve 1 byte for final index value
        
psect	uart_code,class=CODE
    
keyboard_setup:
    ;select the correct bank to work in
    banksel	PADCFG1
    bsf REPU ; bank select register - because PADCFG1 is not in access RAM
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
    
    return

    
keyboard_start:
    
    ;clears the column byte
    movlw   0x00
    movwf   row_byte , A
    movwf   column_byte, A	    
    
    ;Sets rows to be inputs
    movlw 0x0F; 00001111 ; PORTE 4-7 (columns) are outputs and Port E 0-3 (rows) are inputs
    movwf TRISE, A
    nop
    
    ;Call a delay to allow the TRIS voltage to settle
    movlw 5
    call  LCD_delay_ms	    
    nop
    
    ; Drive output bits low all at once
    movlw	0x00
    movwf	PORTE, A
    ;Read value from port and put it in row_byte
    movff PORTE, row_byte, A		

    ;Sets columns to be inputs 
    movlw 0xF0			; 11110000 ; PORTE 4-7 (columns) are inputs and Port E 0-3 (rows) are outputs
    movwf TRISE, A
    nop
    
    ;Call a delay to allow the TRIS voltage to settle
    movlw 5
    call  LCD_delay_ms      
    nop
    
    ; Drive output bits low all at once
    movlw	0x00
    movwf	PORTE, A
    ;Read value from port and put it in row_column
    movff PORTE, column_byte, A
    return
    
Recombine:

    ;Combines row and column into one byte containing all the information
    ;below two lines for debugging
    movff   row_byte, PORTC,A
    movff   column_byte, PORTD, A
    
    movf    row_byte, W, A
    iorwf   column_byte, 0, 0	    ;compares contents of two addresses, if both bits are a 1, returns a 1, otherwise 0 (places in W reg)
    movwf   key_byte, A
    ;movwf   PORTH,A
    movff   key_byte, PORTH, A

    return
    
Check_button_pressed:
    ;check button is pressed by checking column
    clrf PORTB, A
    movlw 0xFF
    cpfseq key_byte
    return;call yes_button_pressed    ; show lights on port b if key has been pressed
    goto start; call no_button_pressed    ; no lights on B when no key prssed
    
yes_button_pressed:
    movlw 0xff
    movwf PORTB, A
    return
    
no_button_pressed: 
    movlw 0x00
    movwf PORTB, A
    goto start
    
clear_check_light:
    movlw 0x00
    movwf PORTC, A
    ;return
    
check_light:
    movlw 0xAA
    movwf PORTC, A
    return
    
Find_index:    
    ;movf key_byte, W, A
    call A_check

    return
    
A_check: 
    movlw   01110111
    cpfseq  key_byte, A
    call B_check
    movlw 0    ; index for A
    return
   
B_check:
    movlw   10110111
    cpfseq  key_byte, A
    call C_check
    movlw 1    ; index for B
    return
    
C_check:
    movlw   11010111
    cpfseq  key_byte, A
    call D_check
    movlw 2    ; index for C
    return

D_check:
    movlw   11100111
    cpfseq  key_byte, A
    call E_check
    movlw 3    ; index for D
    return
    
E_check:
    movlw   01111011
    cpfseq  key_byte, A
    call F_check
    movlw 4    ; index for E
    return
    
F_check:
    movlw   10111011
    cpfseq  key_byte, A
    goto G_check
    movlw 5    ; index for F
    return
 
G_check:
    movlw   11011011
    cpfseq  key_byte, A
    goto H_check
    movlw 6    ; index for G
    return 
    
H_check:
    movlw   11101011
    cpfseq  key_byte, A
    goto I_check
    movlw 7    ; index for H
    return     
    
I_check:
    movlw   01111101
    cpfseq  key_byte, A
    goto J_check
    movlw 8    ; index for I
    return
    
J_check:
    movlw   11011101
    cpfseq  key_byte, A
    goto K_check
    movlw 9    ; index for J
    return 
    
K_check:
    movlw   11011101
    cpfseq  key_byte, A
    goto L_check
    movlw 10    ; index for K
    return 
    
L_check: 
    movlw 11101101
    cpfseq  key_byte, A
    goto M_check
    movlw 11    ; index for L
    return 

M_check:
    movlw 01111101
    cpfseq  key_byte, A
    goto N_check
    movlw 12    ; index for M
    return 
    
N_check:
    movlw 10111101
    cpfseq  key_byte, A
    goto O_check
    movlw 13    ; index for N
    return 

O_check:
    movlw 11011101
    cpfseq  key_byte, A
    goto P_check
    movlw 14    ; index for 0
    return 
    
P_check: 
    movlw 15    ; index for P
    return 
    
Place_index:
    movwf   index_final,A
    movff   index_final,PORTB, A
   ; movlw   01101011
    ;movwf   PORTB
    movlw   10
    call    LCD_delay_ms
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
	
	movf	index_final, A
	addwfc	TBLPTRL, A
	movwf	TBLPTRL, A
	
	movlw	1
	lfsr	2, myArray
	call	LCD_Send_Byte_D
	
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



