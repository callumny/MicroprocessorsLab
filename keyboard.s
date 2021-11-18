#include <xc.inc>
    
global  keyboard_setup, keyboard_start, Recombine

psect	udata_acs   ; reserve data space in access ram
keyboard_counter: ds    1	    ; reserve 1 byte for variable keyboard_counter
LCD_cnt_l:	ds 1   ; reserve 1 byte for variable LCD_cnt_l
LCD_cnt_h:	ds 1   ; reserve 1 byte for variable LCD_cnt_h
LCD_cnt_ms:	ds 1   ; reserve 1 byte for ms counter
    
    
psect	uart_code,class=CODE

    
keyboard_setup:
    
    banksel	PADCFG1
    bsf REPU ; bank select register - because PADCFG1 is not in access RAM
    banksel 0
    
    ;clrf LATD, A
    ;clrf LATC, A
    ;clrf LATH, A
    clrf PORTE, A
    clrf PORTD, A
    clrf PORTC, A
    clrf LATE, A ; writes all 0's to LAT register - remembers outputs/position of pull up resistors on Port E
    
    return
; D should be at adress less than C, rows than columns DDDDCCCC 
    ; D at 0x06, C at 0x07
    
keyboard_start: ; press and hold button 
    ;Finding Rows
    movlw 0x0F; 00001111 ; PORTE 4-7 (columns) are outputs and Port E 0-3 (rows) are inputs
    movwf TRISE, A
    nop
    ;call    lcdlp2	    ; calls a 1ms delay after setting the Tristate to allow voltage pins to settle
    
    movf PORTE, W, A
    movwf 0x06, A		; move data on w to Port D
    
    ;Finding Columns  
    
    clrf PORTE, A
    
    movlw 0xF0			; 11110000 ; PORTE 4-7 (columns) are inputs and Port E 0-3 (rows) are outputs
    movwf TRISE, A
    
    ;call    lcdlp2	    ;call a 1ms delay to allow voltage to stabilize
    nop
    movf PORTE, W, A
    ;call lcdlp2
    movwf 0x07, A	    ; move data on w to Port C
    
    return
    
Recombine:
    ; Combininng data on port C and D to one byte
    
    movf    0x06, W, A ; displyaing row nibble
    movwf   PORTD, A
    
    movlw   0x00
    movwf   TRISD, A	    ;set port D to outputs
    ;call    lcdlp2	    ;calls a 1ms delay to allow voltage to stabilize
    nop
    movf    0x07, W, A ; displaying coloumn nibble
    movwf   PORTC, A	    ;moves the coloumn nibble to PORTC

    movlw   0x00
    movwf   TRISC, A	    ;set port C to outputs
    ;call    lcdlp2	    ;calls a 1ms delay to allow voltage to stabilize

    movf    0x06, W, A
    iorwf   0x07, 0, 0	    ;compares the contents of 0x06
    
    movwf   PORTH, A
    movlw   0x00
    movwf   TRISH, A
    
    ;movlw   0x20
    ;call    LCD_delay_ms
    
    ;read the whole 8 bits
    ; and it with 0x0F for the lower 4 bits
    ; and it with 0xF0 for the upper 4 bits
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
	
    
end    





