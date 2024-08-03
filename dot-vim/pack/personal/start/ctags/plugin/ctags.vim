" Function to check if the buffer is empty or unnamed    
function! s:NotFileBuffer()    
    return (line('$') == 1 && getline(1) == '') || expand('%') == ''    
endfunction    

" Function to get the path of the current file buffer    
function! s:FileBufferPath()    
    return expand('%:p:h')    
endfunction    

" Function to get the current working directory    
function! s:CurrentPath()    
    return getcwd()    
endfunction    

" Function to check if the given path is a Git repository    
function! s:IsGitRepo(path)    
    return system('git -C ' . a:path . ' rev-parse --is-inside-work-tree') =~ 'true'    
endfunction    

" Function to get the root of the Git repository    
function! s:GitRoot(path)    
    return trim(system('git -C ' . a:path . ' rev-parse --show-toplevel'))    
endfunction    

" Function to parse arguments to ctags    
function! s:GetArgList(base_path)    
    if exists('g:ctags_arguments')    
        return g:ctags_arguments    
    else    
        return ['-R', '-f', a:base_path . '/tags']    
    endif    
endfunction    

function! s:RootPath()    
    if s:NotFileBuffer()    
        let base_path = s:CurrentPath()    
    else    
        let base_path = s:FileBufferPath()    
    endif    
    
    if s:IsGitRepo(base_path)    
        let root_path = s:GitRoot(base_path)    
    else    
        let root_path = base_path    
    endif    
    
    return root_path    
endfunction    

" Function to generate ctags for the current project    
function! s:GenerateTags()    
    let root_path = s:RootPath()    
    let ctag_args = s:GetArgList(root_path)    
    
    if exists('g:ctags_paths')    
        let ctag_paths = g:ctags_paths    
    else    
        let ctag_paths = [root_path]    
    endif    
    
    " Convert ctag_paths to a space-separated string
    let ctag_paths_str = root_path . ' ' . join(ctag_paths, ' ')
    
    echom 'Setting CTags paths to: ' . ctag_paths_str
    echom 'Generating CTags...'
    
    " Ensure root_path is a string and not a list
    silent! execute 'cd ' . shellescape(root_path)    
    silent! execute '!ctags ' . join(ctag_args, ' ') . ' ' . ctag_paths_str    
    silent! execute 'cd -'    

    echom 'Done'
endfunction    

" Expose the generate function to be called externally    
command! GenerateCTags call s:GenerateTags()    
