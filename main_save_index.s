#include <xc.inc>

extrn      keyboard_setup, keyboard_start, enter_state  ; external subroutines
;extrn    LCD_Setup, LCD_Write_Message, Display_clear
                

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    
psect     code, abs             
rst:         org 0x0
               goto       start

                ; ******* Programme FLASH read Setup Code ***********************
start:
    
    call index_save
    
    movlw   1
    cpfseq  enter_state
    bra     start    ; 
    call    Display   ; if enter
                
end start



