" Function to convert a binary number (in decimal) to hexadecimal
function! BinToHex(bin_str)
    " Remove '0b' prefix if present
    if a:bin_str =~ '^0b'
        let bin_str = substitute(a:bin_str, '^0b', '', '')
    endif

    " Convert binary string to hexadecimal using printf
    let hex_str = printf('0x%X', str2nr(a:bin_str, 2))
    return hex_str
endfunction

" Function to convert a hexadecimal number with '0x' prefix to binary
function! HexToBin(hex_str)
    " Remove '0x' prefix if present
    if a:hex_str =~ '^0x'
        let hex_str = substitute(a:hex_str, '^0x', '', '')
    endif
    
    " Convert hexidecimal to binary and pad with leading zeros to ensure 8-bit representation
    let bin_str = printf('0b%08b', str2nr(hex_str, 16))
    return bin_str
endfunction
