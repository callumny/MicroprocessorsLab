extrn    index
global        index_save, enter_state, save_current_index, read_each_index ;also letters 1-17    
    
psect	udata_bank4 ; reserve data anywhere in RAM (here at 0x400)
letter_array:    ds 16 ; reserve 128 bytes for message data

psect code, abs

lfsr 0, letter_array ; loads letter_array to fsr, so we can point at data adreses more effectively

save_current_index:
    movff index, POSTINC0;save_the index in correct position in letter array, this will also increment the fsr
    return
    
read_each_index:
    lfsr 1, letter_array
    movff POSTINC1, index_read
    return
    
initialise_letter_array:
    
    

