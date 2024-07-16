" minpac must have {'type': 'opt'} so that it can be loaded with `packadd`.
call minpac#add('k-takata/minpac', {'type': 'opt'})

" General enhancements
call minpac#add('tpope/vim-sensible')
call minpac#add('tpope/vim-surround')
call minpac#add('tpope/vim-unimpaired')
call minpac#add('junegunn/fzf.vim')

" CMake Build Environment
call minpac#add('cdelledonne/vim-cmake', {'type': 'opt'})

" Colorschemes
call minpac#add('vim-airline/vim-airline')
call minpac#add('tomasiser/vim-code-dark')
