" Only do this when not done yet for this buffer
if exists("b:python_ftplugin")
  finish
endif
let b:python_ftplugin = 1


" Set default compiler to ruff if not already set
if !exists('current_compiler')
    compiler ruff
endif


" Set default color column to 88
if !exists('colorcolumn')
    set colorcolumn=88
endif


" Run formatter on save
autocmd BufWritePre <buffer> call FormatPythonOnSave()


" Run ruff format if enabled and installed
function! FormatPythonOnSave()
    " Only run formatter if the buffer was modified
    if !&modified
        return
    endif

    " Save the current window view
    let save_window = winsaveview()

    " Write the buffer to disk and run the formatter
    silent! write
    call RuffFormatIfEnabled()

    " Restore the window view
    call winrestview(save_window)
endfunction


" Global variable to track if warning has been shown
if !exists('g:ruff_warning_shown')
    let g:ruff_warning_shown = 0
endif


" Global variable to enable ruff formatting 
if !exists('g:ruff_format_on_save')
    let g:ruff_format_on_save = 1  " Default to true if not already set
endif


function! CheckRuff()
  " Check if 'ruff' command is available in the system
  return system('command -v ruff >/dev/null 2>&1 && echo 1 || echo 0')
endfunction


function! RuffFormatIfEnabled()
    " Local variable to enable formatting for the buffer
    if !exists('b:ruff_format_on_save')
        let b:ruff_format_on_save = 1  " Default to true if not already set
    endif

    " Skip formatting if either variable is false
    if !b:ruff_format_on_save || !g:ruff_format_on_save
        return
    endif

    " Run formatter if enabled
    call RuffFormat()
endfunction


function! RuffFormat()
    if CheckRuff() != 1
        if g:ruff_warning_shown == 0
            echohl WarningMsg
            echom "Warning: ruff is not installed... Not formatting"
            echohl None
            let g:ruff_warning_shown = 1
        endif
        return
    endif

    let filename = expand('%:p')

    " Run import sorting fix
    let ruff_check_output = system('ruff check --select I --fix ' . shellescape(filename))
    if v:shell_error != 0
        echohl ErrorMsg
        echom "❌ Ruff check failed:"
        echom ruff_check_output
        echohl None
    endif

    " Run formatter
    let ruff_format_output = system('ruff format ' . shellescape(filename))
    if v:shell_error != 0
        echohl ErrorMsg
        echom "❌ Ruff format failed:"
        echom ruff_format_output
        echohl None
    endif

    " Reload file
   silent! edit!
endfunction

" Create a command to easily run the formatter
command! RuffFormat call RuffFormat()
