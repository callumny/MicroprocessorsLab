#include <xc.inc>
    
global        Save_current_index, Read_each_index, Set_saving_lfsr, Set_reading_lfsr ;also letters 1-17    
extrn    index
    
    
psect	udata_acs ; reserve data anywhere in RAM (here at 0x400)
letter_array:    ds 16 ; reserve 128 bytes for message data
	myArray EQU 0x400
	align 2
;psect code, abs
psect	save_index_fsr_code,class=CODE
Set_saving_lfsr:
    ;bcf	STATUS, 0	; point to Flash program memory 
    ;bcf	CFGS	; point to Flash program memory  
    ;bsf	EEPGD 	; access Flash program memory
    
    ;lfsr 0, letter_array ; loads letter_array to fsr, so we can point at data adreses more effectively
    lfsr 0, myArray
    return
    
Save_current_index:
    ;movff index, INDF0 ;testing save index works
    ;movff POSTINC0, PORTH;
    
    movff index, POSTINC0 ;save_the index in correct position in letter array, this will also increment the fsr
    
    return
    
    
Set_reading_lfsr:
    ;lfsr 1, letter_array
    lfsr 1, myArray
Read_each_index:
    movf POSTINC1, 0, 0     ; moves current index being read into w register
    return
    
Initialise_letter_array:
    return
    

