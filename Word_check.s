#include <xc.inc>
global Check_enter, Check_length, Enter_state, Length_state,\
    Display_index_counter, Display_index_counter_word

extrn LCD_Write_Message, start, setup, LCD_Send_Byte_D, index_counter, index
    
psect	udata_acs   ; reserve data space in access ram
Enter_state:	ds 1   ; reserve 1 byte for variable LCD_cnt_l
Length_state:	ds 1   ; reserve 1 byte for variable LCD_cnt_h

Check_enter:
    ;set Enter_state to 0xFF is enter pressed
    ;else set to 0x00 
    movlw   32		;moves the index value of the enter press to w
    cpfslt  index, A	; compares to the actual index, skips if less than 32, runs next line when =< 32
    bra	    enter_pressed   
    bra	    enter_not_pressed
    
enter_pressed:
    movlw   0xFF	    ;if enter button is pressed, 0xFF is moved into the Enter_state byte
    movwf   Enter_state, A
    return
    
enter_not_pressed:
    movlw   0x00	    ;if enter buttton is not pressed, 0x00 is moved into the Enter_state byte
    movwf   Enter_state, A
    return
    
Check_length:
    ;set Length_state to 0xFF is index_counter is 16
    ;else set to 0x00 
    movlw   17		;check the length before incrementing its 16, after incrementing the first null key press would be at 17
    cpfslt  index_counter, A	    ;compares the index counter to 16, skips as long as index_counter<16	
    bra	    length_long		    ; runs when this condition is no longer met
    bra	    length_short	    ; runs whilst the condition is met

length_long:
    movlw   0xFF		    ; moves 0xFF into W in the case where the word is too long
    movwf   Length_state, A	    ; moves 0xFF into Length_state byte
    return
    
length_short:
    movlw   0x00		    ;moves 0x00 into W in the case where the word is sufficiently small enough
    movwf   Length_state, A	    ; moves 0x00 into Length_state byte
    return

Display_index_counter_word:
    movff index_counter, PORTJ, A
    return
    
Display_index_counter:
    movff index_counter, PORTC, A
    return
    
  