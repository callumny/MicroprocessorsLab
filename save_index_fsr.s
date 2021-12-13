#include <xc.inc>
    
global        Save_current_index, Read_each_index, Set_saving_lfsr, Set_reading_lfsr ;also letters 1-17    
extrn    index,read_index
    
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)

letter_array:    ds 16 ; reserve 128 bytes for message data	

psect	save_index_fsr_code,class=CODE

Set_saving_lfsr:
    lfsr 0, letter_array ; loads letter_array to fsr, so we can point at data adreses more effectively
    return
    
Save_current_index:
    ;movff index, INDF0 ;testing save index works
    ;movff POSTINC0, PORTH;
    
    movff index, POSTINC0 ;save_the index in correct position in letter array, this will also increment the fsr
    return
    
    
Set_reading_lfsr:
    lfsr 1, letter_array
    return
    
Read_each_index:
    movff POSTINC1, read_index     ; moves current index being read into w register
    return
    
Initialise_letter_array:
    return
    

