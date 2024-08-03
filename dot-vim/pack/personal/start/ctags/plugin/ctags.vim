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

" Function to call ctags in the given path
function! s:CTagsCall(args, paths)
    silent! execute '!ctags ' . join(args, ' ') . join(paths, ' ')
endfunction

" Function to parse arguments to ctags
function! s:CTagsArguments()
    if exists('g:ctags_arguments')
        return g:ctags_arguments
    else
        return ['-R']
    endif
endfunction

" Function to parse paths to ctags
function! s:CTagsPaths()
    if exists('g:ctags_paths')
        return g:ctags_paths
    endif

    if s:CTagsNotFileBuffer()
        let base_path = s:CTagsCurrentPath()
    else
        let base_path = s:CTagsFileBufferPath() 
    endif

    if s:CTagsIsGitRepo(base_path)
        let ctag_paths = [s:CTagsGitRoot(base_path)]
    else
        let ctag_paths = [base_path]
    endif

    return ctag_paths
endfunction

" Function to check if the buffer is empty or unnamed
function! s:CTagsNotFileBuffer()
    return (line('$') == 1 && getline(1) == '') || expand('%') == ''
endfunction

" Function to generate ctags for the current project
function! s:CTagsGenerate()
    let ctag_args = s:CTagsArguments()
    let ctag_paths = s:CTagsPaths()
    echo 'Generating CTags'
    echom 'Generating CTags'
    call s:CTagsCall(ctag_args, ctag_path)
endfunction

" Expose the generate function to be called externally
command! GenerateCTags call s:CTagsGenerate()

