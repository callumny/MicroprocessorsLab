#include <xc.inc>

global	start, setup
extrn	keyboard_setup, LCD_Setup, keyboard_start, Recombine, Display_key_byte, Display_NOT_key_byte, Check_pressed, Find_index, Display_index, key_byte, NOT_key_byte, Print  ; external subroutines
;extrn	LCD_Setup, LCD_Write_Message, Display_clear
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
psect	udata_acs   ; reserve data space in access ram
NOT_key_byte_low:	    ds 1   ; reserve 1 byte for NOTTED keybyte, useful for checking if button pressed	
NOT_key_byte_high:	    ds 1   ; reserve 1 byte for NOTTED keybyte, useful for checking if button pressed	
psect	code, abs	
rst: 	org 0x0
 	goto	setup

	; ******* Programme FLASH read Setup Code ***********************

setup: 
	call	keyboard_setup	; setup keyboard
	call	LCD_Setup
	goto	start
	
	; ******* Main programme ****************************************
start: 	
        ;movlw 0x0F ; only if no button is pressed
	;movwf PORTC, A
	;call clear_check_light
	call keyboard_start
	movlw 0x00
	movwf PORTH, A
	
	call Recombine

	; check if button is pressed
	movff NOT_key_byte, NOT_key_byte_low
	movlw 0x0f
	andwf NOT_key_byte_low, 1,0
	movff NOT_key_byte, NOT_key_byte_high
	movlw 0xf0
	andwf NOT_key_byte_high, 1,0	
	
	movlw 0x00
	cpfsgt NOT_key_byte_low, A
	bra start; if all 00000000 i.e no button is pressed
	cpfsgt NOT_key_byte_high, A
	bra start;
	;movlw 0xFF
	;cpfseq key_byte
        ;goto rest ;yes button pressed
	;bra start ;no button pressed
	
	
	call Display_key_byte
	call Display_NOT_key_byte
	
	
	; greater than 00000000 i.e a button is pressed
	
	
	;'''
	;movlw 0xFF
	;cpfseq key_byte
        ;return ;yes button pressed
	;bra start ;no button pressed
	;'''
	
	
	;;;;;;;;;check light
	;movlw 0xff  ; only if button is pressed
	;movwf PORTC, A
	
	;call Find_index
	;call Display_index
	;call Print
	goto start ; call no_button_pressed    ; no lights on B when no key prssed

check_column: 
    
end start
 