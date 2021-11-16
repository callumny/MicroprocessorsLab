#include <xc.inc>

extrn	keyboard_setup, keyboard_start  ; external subroutines
;extrn	LCD_Setup, LCD_Write_Message, Display_clear
	
main:
    call    keyboard_setup
    call    keyboard_start
 end	main   