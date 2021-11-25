#include <xc.inc>
    
    
extrn LCD_Write_Message, start, setup, LCD_Send_Byte_D
    
global  keyboard_setup, keyboard_start, Recombine, Display_key_byte,Display_NOT_key_byte, Check_pressed, Find_index, Display_index, key_byte, NOT_key_byte, Print  ; external subroutines

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
    
    ;Call a delay to allow the TRIS voltage to settle
    movlw	10		; wait 40us
    call	LCD_delay_x4us
    ;movlw 5
    ;call  LCD_delay_ms	    
    
    ;Drive output bits low all at once
    movlw	0x00
    movwf	PORTE, A
    
    ;Read value from port and put it in row_byte
    movff PORTE, row_byte, A	
    
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
    
Recombine:

    ;Combines row and column into one byte containing all the information
    ;below two lines for debugging
    ;movff   row_byte, PORTC,A
    movff   column_byte, PORTD, A
    
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
    
    
Check_pressed:
    movlw 0xFF
    cpfseq key_byte, A
    return ;yes button pressed
    goto start ;no button pressed
Find_index:
    return
Display_index:
    ;movff   index,PORTB, A
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



