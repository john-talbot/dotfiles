" Function to call ctags in the given path
function! s:CTagsCall(path)
    execute 'cd ' . a:path
    silent! execute '!ctags -R'
    execute 'cd -'
endfunction

" Function to check if the buffer is empty or unnamed
function! s:CTagsNotFileBuffer()
    return (line('$') == 1 && getline(1) == '') || expand('%') == ''
endfunction

" Function to get the path of the current file buffer
function! s:CTagsFileBufferPath()
    return expand('%:p:h')
endfunction

" Function to get the current working directory
function! s:CTagsCurrentPath()
    return getcwd()
endfunction

" Function to check if the given path is a Git repository
function! s:CTagsIsGitRepo(path)
    return systemlist('git -C ' . a:path . ' rev-parse --is-inside-work-tree --sq')[0] ==# 'true'
endfunction

" Function to get the root of the Git repository
function! s:CTagsGitRoot(path)
    return system('git -C ' . a:path . ' rev-parse --sq --show-toplevel')
endfunction

" Function to generate ctags for the current project
function! s:CTagsGenerate()
    let base_path = s:CTagsCurrentPath()

    if s:CTagsIsGitRepo(base_path)
        let ctag_path = s:CTagsGitRoot(base_path)
    else
        let ctag_path = base_path
    endif

    echo 'Generating CTags at ' . ctag_path
    echom 'Generating CTags at ' . ctag_path
    call s:CTagsCall(ctag_path)
endfunction

" Expose the generate function to be called externally
command! GenerateCTags call s:CTagsGenerate()

