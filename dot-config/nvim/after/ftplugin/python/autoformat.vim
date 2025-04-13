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

" Global variable to track if warning has been shown
if !exists('g:ruff_warning_shown')
    let g:ruff_warning_shown = 0
endif

" Global variable to enable ruff formatting 
if !exists('g:ruff_format_on_save')
    let g:ruff_format_on_save = 1  " Default to true if not already set
endif

" Run formatter on save
autocmd BufWritePre <buffer> call FormatPythonOnSave()

" Command to run ruff format
command! RuffFormat call RuffFormatIfModified()

" Quickly run ruff format
nnoremap <Leader>r :RuffFormat<CR>

" Run ruff format if enabled and installed
function! FormatPythonOnSave()
    " Save the current window view
    let save_window = winsaveview()

    " Only join undo if buffer is modified
    if &modified
        " Allow the next command to be joined with the previous undo block
        silent! undojoin
    endif

    " Run the formatter
    call RuffFormatIfEnabled()

    " Restore the window view
    call winrestview(save_window)
endfunction


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

    call RuffFormat()
endfunction


function! RuffFormatIfModified()
    if &modified
        call RuffFormat()
    endif
endfunction


function! RuffFormat()
    if CheckRuff() == 1
        " Execute ruff format to format the file
        silent! %!ruff check --select I --fix --stdin-filename % -q -
        silent! %!ruff format --stdin-filename % -q -
    else
        " Show warning that ruff isn't installed on first run
        if g:ruff_warning_shown == 0
            echohl WarningMsg
            echom "Warning: ruff is not installed... Not formatting"
            echohl None
            let g:ruff_warning_shown = 1
        endif
    endif
endfunction
