" Set default compiler to flake8 if not already set
if !exists('current_compiler')
    compiler flake8
endif

" Set default color column to 88
if !exists('colorcolumn')
    set colorcolumn=88
endif


" Global variable to enable formatting for the session
if !exists('g:enable_black')
    let g:enable_black = 1  " Default to true if not already set
endif

augroup PythonAutoCommands
    autocmd!
    autocmd BufWritePre <buffer> :call BlackFormat()
augroup END


function! BlackFormat()
    " Local variable to enable formatting for the buffer
    if !exists('b:enable_black')
        let b:enable_black = 1  " Default to true if not already set
    endif

    " Skip formatting if either variable is false
    if !b:enable_black || !g:enable_black
        return
    endif

    " Execute black command to format
    silent! execute '%!black -q -'
endfunction
