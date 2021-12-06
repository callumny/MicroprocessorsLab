external    index

global        index_save, enter_state ;also letters 1-17    
    
    
psect     udata_acs
    
index_counter:  ds  1           ;reserves 1 byte in memory for the index_counter
letter_1:   ds       1
letter_2:   ds       1
letter_3:   ds       1
letter_4:   ds       1
letter_5:   ds       1
letter_6:   ds       1
letter_7:   ds       1
letter_8:   ds       1
letter_9:   ds       1
letter_10:   ds    1
letter_11:   ds    1
letter_12:   ds    1
letter_13:   ds    1
letter_14:   ds    1
letter_15:   ds    1
letter_16:   ds    1
letter_17:   ds 1
enter_state:       ds 1
    
    movff   letter_1, portd


psect     uart_code,class=CODE

set_index_counter: ;put this in the initialising at the start
    movlw   1
    movf    index_counter
    
index_save: ;compare to literal value, this compares to an address

    movlw   1                                            ;moves 1 to W
    cpfsgt  index_counter     ;compares W with index_counter, if index counter is greater than W then skips, when its equal to or greater then it runs the next line
    bra    letter_1_check
    
    movlw   2
    cpfsgt  index_counter
    bra    letter_2_check
    
    movlw   3
    cpfsgt  index_counter
    bra    letter_3_check
    
    movlw   4
    cpfsgt  index_counter
    bra    letter_4_check
    
    movlw   5
    cpfsgt  index_counter
    bra    letter_5_check
    
    movlw   6
    cpfsgt  index_counter
    bra    letter_6_check
    
    movlw   7
    cpfsgt  index_counter
    bra    letter_7_check
    
    movlw   8
    cpfsgt  index_counter
    bra    letter_8_check
    
    movlw   9
    cpfsgt  index_counter
    bra    letter_9_check
    
    movlw   10
    cpfsgt  index_counter
    bra    letter_10_check
    
    movlw   11
    cpfsgt  index_counter
    bra    letter_11_check
    
    movlw   12
    cpfsgt  index_counter
    bra    letter_12_check
    
    movlw   13
    cpfsgt  index_counter
    bra    letter_13_check
    
    movlw   14
    cpfsgt  index_counter
    bra    letter_14_check
    
    movlw   15
    cpfsgt  index_counter
    bra    letter_15_check
    
    movlw   16
    cpfsgt  index_counter
    bra    letter_16_check
    
    movlw   17
    cpfsgt  index_counter
    bra    letter_17_check
    
letter_1_check:
    movff   index, letter_1
    bra    counter_add
    
letter_2_check:
    movff   index, letter_2
    bra    counter_add
    
letter_3_check:
    movff   index, letter_3
    bra    counter_add    
    
letter_4_check:
    movff   index, letter_4
    bra    counter_add
    
letter_5_check:
    movff   index, letter_5
    bra    counter_add   
    
letter_6_check:
    movff   index, letter_6
    bra    counter_add
    
letter_7_check:
    movff   index, letter_7
    bra    counter_add
    
letter_8_check:
    movff   index, letter_8
    bra    counter_add
    
letter_9_check:
    movff   index, letter_9
    bra    counter_add  
    
letter_10_check:
    movff   index, letter_10
    bra    counter_add
    
letter_11_check:
    movff   index, letter_11
    bra    counter_add 
    
letter_12_check:
    movff   index, letter_12
    bra    counter_add
    
letter_13_check:
    movff   index, letter_13
    bra    counter_add
    
letter_14_check:
    movff   index, letter_14
    bra    counter_add
    
letter_15_check:
    movff   index, letter_15
    bra    counter_add
    
letter_16_check:
    movff   index, letter_16
    bra    counter_add
    
letter_17_check:
    movff   index, letter_17
    bra    counter_add
    
counter_add:
    movff   index_counter, PORTB	    ;checking before we increase the index
    movf    index_counter, A
    addlw   1
    movwf   index_counter,A
    movf    17
    movff   index_counter, PORTB	    ;this is a check to see if index is counting properly
    cpfseq  index_counter,A               ;want to make it that it can only store 16 letters, and if any more are pressed we just display the first 16 letters
    bra    Enter_check
    return                   ;followed by the display module
    
Enter_check:
    movf    32                            ;          moves 32 to W    
    cpfslt index                     ;   compares W with index, if the index is less than 32 it skips the next line, otherwie it runs the next line
    bra    enter_pressed        ; branches to the enter_pressed function
    bra    enter_not_pressed
    
enter_pressed:
    movlw   1
    movwf   enter_state
    return
    
enter_not_pressed:
    movlw   0
    movwf   enter_state
    return
    
