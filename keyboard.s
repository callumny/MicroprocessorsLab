#include <xc.inc>
    
global  keyboard_setup, keyboard_start, Recombine
    
psect	udata_acs   ; reserve data space in access ram
keyboard_counter: ds    1	    ; reserve 1 byte for variable keyboard_counter
LCD_cnt_l:	ds 1   ; reserve 1 byte for variable LCD_cnt_l
LCD_cnt_h:	ds 1   ; reserve 1 byte for variable LCD_cnt_h
LCD_cnt_ms:	ds 1   ; reserve 1 byte for ms counter
row_byte:       ds 1   ; reserve 1 byte for row byte
column_byte:    ds 1   ; reserve 1 byte for column byte
key_byte:       ds 1   ; reserve 1 byte for combined row and column    

psect	data
	
Keys:
	db	'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P', 0x0a
	
    
psect	uart_code,class=CODE

    
keyboard_setup:
    
    banksel	PADCFG1
    bsf REPU ; bank select register - because PADCFG1 is not in access RAM
    banksel 0
    
    clrf LATD, A
    clrf LATC, A
    clrf LATH, A
    ;clrf PORTE, A
    ;clrf PORTD, A
    ;clrf PORTC, A
    clrf LATE, A ; writes all 0's to LAT register - remembers outputs/position of pull up resistors on Port E
    
    movlw   0x00
    movwf   TRISD,A
    movwf   TRISC,A
    movwf   TRISH,A
       
    return
; D should be at adress less than C, rows than columns DDDDCCCC 
    ; D at 0x06, C at 0x07
    
keyboard_start: ; press and hold button
    
    movlw   0x00
    movwf   row_byte , A
    movwf   column_byte, A	    ;clears the 0x06 and 0x07
    
    ;Finding Rows
    movlw 0x0F; 00001111 ; PORTE 4-7 (columns) are outputs and Port E 0-3 (rows) are inputs
    movwf TRISE, A
    nop
    movlw 1
    call  LCD_delay_ms	    ;DELAY!!!!!!
    movf PORTE, W, A
    movwf row_byte, A		; move data on w to Port D
    
    ;Finding Columns  
    movlw 0xF0			; 11110000 ; PORTE 4-7 (columns) are inputs and Port E 0-3 (rows) are outputs
    movwf TRISE, A
    nop
    movlw 1
    call  LCD_delay_ms      ;DELAY!!!! 
    movf PORTE, W, A
    movwf column_byte, A	    ; move data on w to Port C
    
    return
    
Recombine:
    ; Combininng data on port C and D to one byte
    
    movf    row_byte, W, A ; displyaing row nibble
    movwf   PORTD, A
    
    movf    column_byte, W, A ; displaying coloumn nibble
    movwf   PORTC, A	    ;moves the coloumn nibble to PORTC
    
    movf    row_byte, W, A
    iorwf   column_byte, 0, 0	    ;compares the contents of 0x06
    movwf   key_byte, A
    movff   key_byte, PORTH

    
    ;read the whole 8 bits
    ; and it with 0x0F for the lower 4 bits
    ; and it with 0xF0 for the upper 4 bits
    return

Decode:
    
    
    
    
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



