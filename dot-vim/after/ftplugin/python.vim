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


" Global variable to track if warning has been shown
if !exists('g:black_warning_shown')
    let g:black_warning_shown = 0
endif


" Global variable to enable formatting 
if !exists('g:black_format_on_save')
    let g:black_format_on_save = 1  " Default to true if not already set
endif


function! CheckBlack()
  " Check if 'black' command is available in the system
  return system('command -v black >/dev/null 2>&1 && echo 1 || echo 0')
endfunction


function! BlackIfEnabled()
    " Local variable to enable formatting for the buffer
    if !exists('b:black_format_on_save')
        let b:black_format_on_save = 1  " Default to true if not already set
    endif

    " Skip formatting if either variable is false
    if !b:black_format_on_save || !g:black_format_on_save
        return
    endif

    if CheckBlack() == 0
        if g:black_warning_shown == 0
            echohl WarningMsg
            echo "Warning: Black is not installed... Not formatting"
            echom "Warning: Black is not installed... Not formatting"
            echohl None
            let g:black_warning_shown = 1
        endif
        return
    endif

    " Execute black command to format
    execute 'Black'
endfunction
