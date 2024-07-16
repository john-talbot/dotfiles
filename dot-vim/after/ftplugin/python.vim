" Set default compiler to flake8 if not already set
if !exists('current_compiler')
    compiler flake8
endif


" Set default color column to 88
if !exists('colorcolumn')
    set colorcolumn=88
endif


" Run black formatter on save
augroup PythonAutoCommands
    autocmd!
    autocmd BufWritePre <buffer> call BlackIfEnabled()
augroup END


" Global variable to enable formatting 
if !exists('g:black_format_on_save')
    let g:black_format_on_save = 1  " Default to true if not already set
endif


function! BlackIfEnabled()
    " Local variable to enable formatting for the buffer
    if !exists('b:black_format_on_save')
        let b:black_format_on_save = 1  " Default to true if not already set
    endif

    " Skip formatting if either variable is false
    if !b:black_format_on_save || !g:black_format_on_save
        return
    endif

    " Execute black command to format
    execute 'Black'
endfunction
