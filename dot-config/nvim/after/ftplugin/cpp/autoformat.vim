
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
autocmd BufWritePre <buffer> call FormatCppOnSave()


" Run clang if enabled and installed
function! FormatCppOnSave()
    " Save the current cursor position and view
    let l:current_pos = getpos('.')
    let l:current_view = winsaveview()

    undojoin

    call ClangIfEnabled()

    call setpos('.', l:current_pos)
    call winrestview(l:current_view)

endfunction


" Global variable to track if warning has been shown
if !exists('g:clang_warning_shown')
    let g:clang_warning_shown = 0
endif


" Global variable to enable formatting 
if !exists('g:clang_format_on_save')
    let g:clang_format_on_save = 1  " Default to true if not already set
endif


function! CheckClang()
  " Check if 'clang-format' command is available in the system
  return system('command -v clang-format >/dev/null 2>&1 && echo 1 || echo 0')
endfunction


function! ClangIfEnabled()
    " Local variable to enable formatting for the buffer
    if !exists('b:clang_format_on_save')
        let b:clang_format_on_save = 1  " Default to true if not already set
    endif

    " Skip formatting if either variable is false
    if !b:clang_format_on_save || !g:clang_format_on_save
        return
    endif

    " Define the default style with 4-space indentation
    let l:default_style = '{BasedOnStyle: LLVM, IndentWidth: 4}'

    " Check if a .clang-format file exists
    if filereadable('.clang-format')
        " Use the configuration from the .clang-format file
        let l:clang_format_cmd = '%!clang-format'
    else
        " Use the default style configuration
        let l:clang_format_cmd = '%!clang-format -style=' . shellescape(l:default_style)
    endif

    if CheckClang() == 1
        " Execute clang command to format
        silent! keepjumps execute l:clang_format_cmd
    else
        " Show warning that clang isn't installed on first run
        if g:clang_warning_shown == 0
            echohl WarningMsg
            echo "Warning: Clang is not installed... Not formatting"
            echom "Warning: Clang is not installed... Not formatting"
            echohl None
            let g:clang_warning_shown = 1
        endif
    endif
endfunction
