"Load cmake
packadd vim-cmake

" Options
let g:cmake_jump_on_error=0

"CMake keymappings
nnoremap <Leader>cg <Plug>(CMakeGenerate)
nnoremap <Leader>cb <Plug>(CMakeBuild)
nnoremap <Leader>ci <Plug>(CMakeInstall)
nnoremap <Leader>cc <Plug>(CMakeClean)
nnoremap <Leader>cs <Plug>(CMakeSwitch)
nnoremap <Leader>cq <Plug>(CMakeClose)
nnoremap <Leader>ct <Plug>(CMakeTest)
