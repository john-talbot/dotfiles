" Only do this when not done yet for this buffer
if exists("b:python_ftplugin")
  finish
endif
let b:python_ftplugin = 1


" Set default compiler to flake8 if not already set
if !exists('current_compiler')
    compiler flake8
endif


" Set default color column to 88
if !exists('colorcolumn')
    set colorcolumn=88
endif


" Run formatter on save
autocmd BufWritePre <buffer> call FormatPythonOnSave()


" Run isort and black if enabled and installed
function! FormatPythonOnSave()
    let cursor_pos = getcurpos()
    call ISortIfEnabled()
    call BlackIfEnabled()
    call setpos('.', cursor_pos)
    redraw!
endfunction


" Global variable to track if warning has been shown
if !exists('g:isort_warning_shown')
    let g:isort_warning_shown = 0
endif


" Global variable to enable formatting 
if !exists('g:isort_format_on_save')
    let g:isort_format_on_save = 1  " Default to true if not already set
endif


function! CheckISort()
  " Check if 'black' command is available in the system
  return system('python -m isort --version >/dev/null 2>&1 && echo 1 || echo 0')
endfunction


function! ISortIfEnabled()
    " Local variable to enable formatting for the buffer
    if !exists('b:isort_format_on_save')
        let b:isort_format_on_save = 1  " Default to true if not already set
    endif

    " Skip formatting if either variable is false
    if !b:isort_format_on_save || !g:black_format_on_save
        return
    endif

    if CheckISort() == 1
        " Execute isort command to format
        silent! % !python -m isort -
    else
        " Show warning that isort isn't installed on first run
        if g:isort_warning_shown == 0
            echohl WarningMsg
            echo "Warning: isort is not installed... Not formatting"
            echom "Warning: isort is not installed... Not formatting"
            echohl None
            let g:isort_warning_shown = 1
        endif
    endif
endfunction


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

    if CheckBlack() == 1
        " Execute black command to format
        execute 'Black'
    else
        " Show warning that black isn't installed on first run
        if g:black_warning_shown == 0
            echohl WarningMsg
            echo "Warning: Black is not installed... Not formatting"
            echom "Warning: Black is not installed... Not formatting"
            echohl None
            let g:black_warning_shown = 1
        endif
    endif
endfunction
