extrn    index

global        index_save, enter_state ;also letters 1-17    
    
psect udata_acs
counter: ds 1  ; counter for length of typed word
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
letter_array:    ds 16 ; reserve 128 bytes for message data

psect code, abs

lfsr 0, letter_array ; loads letter_array to fsr, so we can point at data adreses more effectively

;initiallise counter
 movlw 0x00
 movwf counter
 
 ; saving indices into letter-array

 
; call after index has come in from the keypad
check_enter:
    
    
 
save_current_index:
    ;increment counter
    ;check index is enter, if yes then escape
    ;check if counter is 16, if yes then escape
    movff index, POSTINC0;save_the index in correct position in letter array, this will also increment the fsr
    return
    
movf index
;retrieve index
movwf POSTINC0  ; increments fsr pouner so next time the literal in w is moved to letter array it is in the next position along
;increment counter

; check if number of letters is 16, if yes then exit
 

