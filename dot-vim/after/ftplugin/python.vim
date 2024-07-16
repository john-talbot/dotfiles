" Automatically set makeprg for Python files
setlocal makeprg=flake8\ %

augroup PythonAutoFormat
    autocmd!
    autocmd BufWritePre <buffer> :call BlackFormat()
    autocmd QuickFixCmdPost [^l]* nested cwindow
augroup END

function! BlackFormat()
    silent! execute '%!black -q -'
endfunction
