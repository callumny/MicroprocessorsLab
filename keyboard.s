#include <xc.inc>
    
    
extrn LCD_Write_Message, start, LCD_Send_Byte_D
    
global  keyboard_setup, keyboard_start, Recombine, Invert, Reset_bit_counter, Keys_setup, Zero_check,Index_row, Index_column, Add_index,Print
    
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

column_index:	    ds  1	    ; reserves 1 byte for the column index i
row_index:	    ds  1	    ; reserves 1 byte for the row index j
invert_byte:	    ds  1	    ; reserves 1 byte for the number 11111111
location_column:    ds	1	; reserves 1 byte for the location of the column data
location_row:	    ds	1	; reserves 1 byte for the location of the row data
index_counter:	    ds	1
bit:	    ds	1   ; reserves a bit for the bit ocunter
index_final:	ds  1 ; reserves a bit for the final index


        
psect	uart_code,class=CODE
   
Keys_setup:

    movlw    0xFF
    movwf   invert_byte,A
    
    return
    
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
    movlw 1
    call  LCD_delay_ms	    
    nop
    
    ;Read value from port and put it in row_byte
    movff PORTE, row_byte, A		

    ;Sets columns to be inputs 
    movlw 0xF0			; 11110000 ; PORTE 4-7 (columns) are inputs and Port E 0-3 (rows) are outputs
    movwf TRISE, A
    nop
    
    ;Call a delay to allow the TRIS voltage to settle
    movlw 1
    call  LCD_delay_ms      
    nop
    
    ;Read value from port and put it in row_column
    movff PORTE, column_byte, A
    
    return
    
Recombine:

    ;Combines row and column into one byte containing all the information
    movf    row_byte, W, A
    iorwf   column_byte, 0, 0	    ;compares contents of two addresses, if both bits are a 1, returns a 1, otherwise 0 (places in W reg)
    movwf   key_byte, A
    movff   key_byte, PORTH

    
    ;read the whole 8 bits
    ; and it with 0x0F for the lower 4 bits
    ; and it with 0xF0 for the upper 4 bits
    return
    
Zero_check:
    movlw   0xFF		;moves FF into the W repositry, the output that is asssociated with 
    cpfseq  key_byte, A		; compares with the value of key_byte, if they are both 0xFF, i.e. no key has been presses then it skips the next line
    return  
    movwf   PORTD, A
    goto    start		;  returns to the start to detect if a key has been pressed 
    
Invert:
    movf    key_byte, W , A		    ;puts the result from the keypad in the w register
    subwf   invert_byte, A		    ;subtracts W repositry from 11111111 to create 0s everywhere apart from 1s at the points of interest and puts it back in invert_byte
    movf    invert_byte, W, A		    ;puts the new invert_byte into the W repositry
    ;movwf   PORTC, A
    
    andlw   0xF0		    ; this gets the inverted column nibble (01000000 for example) and puts it back in W repositry
    movwf   location_column,A	    ; moves the value from the W repositry into location column which now holds the address of the index
    ;movwf   PORTC, A
    
    movf    invert_byte, W, A	    ; moves the key_byte back into w repositry 
    andlw   0x0F		    ; inverts the row nibble
    movwf   location_row,A	    ; moves the value of the W repositry into location row, now holds address of the index
    movwf   PORTF, A
    swapf   location_column,A	    ; flips the nibbles and puts them back into location_row
    
    movff   location_row, PORTC, A
    movff   location_column, PORTD, A
    
    ;now have location_row and location_column in the form 0000 XXXX so the interesting bit is the least significant

    return

testing:
    
    
    
    
Reset_bit_counter: ;must call on this before calling an index function
    movlw   0
    movwf   bit,A   ; set the counter to start from 3, the most signficiant bit of the lower nibble
    movwf   PORTD, A
    return

    
Loop_increase_1:
    incf    bit, A				    ;if bit is a 0 then skips to this line, and decreases by 1, when this value is equal to zero it skips the next line
    movff   bit, PORTD
    goto    Index_row			    ;loops back again on a different bit
    return
    
Loop_increase_2:
    incf    bit, A				    ;if bit is a 0 then skips to this line, and decreases by 1, when this value is equal to zero it skips the next line
    movff   bit, PORTD
    goto    Index_column			    ;loops back again on a different bit
    return
    
    
Index_row:   
    
    rrcf    location_row,1,0
    movff   location_row, PORTB
    btfss   STATUS, 0, A	    ;checks the Nth bit, if it is 1 it skips the next line
    call    Loop_increase_1
    movff   bit, row_index ,A		    ;if the bit is a 1 then the value of the bit address is put into the row_index which should be a number between 0-3
    movff   bit, PORTD, A
    
    movff   row_index, PORTC, A
    
    return
    
Index_column:

    rrcf    location_column,A
    btfss   STATUS, 0, A	    ;checks the Nth bit, if it is 1 it skips the next line
    call    Loop_increase_2
    movff   bit, column_index ,A		    ;if the bit is a 1 then the value of the bit address is put into the row_index which should be a number between 0-3
    movff   bit, PORTD, A
    
    movff   column_index, PORTC, A
    
    return
    
Add_index: ;column_index +4*row_index
    
    movf    row_index, W, A	    ;move row value to w rep
    addwf   row_index, W, A	    ;add row value
    addwf   row_index, W, A	    
    addwf   row_index, W, A
    
    addwf   column_index,A	    ;add column index
    movwf   index_final, A	    ;move to index_final
    
    movf    0x00, A		    ;moves 0x00 to W reg
    movwf   TRISF, A
    
    movf    index_final, A	    ;moves index_final to W reg
    ;movwf   PORTF, A		    ;moves index_final to J
    
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



