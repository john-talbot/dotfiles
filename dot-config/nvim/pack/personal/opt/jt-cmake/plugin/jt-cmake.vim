" Options
let g:cmake_jump_on_error=0
" Symlink compile_commands.json into the source dir so clangd can find it
let g:cmake_link_compile_commands=1

"Load cmake
packadd vim-cmake

"CMake keymappings (nmap, not nnoremap: <Plug> targets must be remappable)
nmap <Leader>cg <Plug>(CMakeGenerate)
nmap <Leader>cb <Plug>(CMakeBuild)
nmap <Leader>ci <Plug>(CMakeInstall)
nmap <Leader>cc <Plug>(CMakeClean)
nmap <Leader>cs <Plug>(CMakeSwitch)
nmap <Leader>cq <Plug>(CMakeClose)
nmap <Leader>ct <Plug>(CMakeTest)
