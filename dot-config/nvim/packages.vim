" minpac must have {'type': 'opt'} so that it can be loaded with `packadd`.
call minpac#add('k-takata/minpac', {'type': 'opt'})


" General enhancements
call minpac#add('tpope/vim-sensible')
call minpac#add('tpope/vim-surround')
call minpac#add('tpope/vim-unimpaired')
call minpac#add('tpope/vim-fugitive')
call minpac#add('tpope/vim-commentary')
call minpac#add('tpope/vim-obsession')
call minpac#add('junegunn/fzf', {'dir': "$HOME/.local/bin"})
call minpac#add('junegunn/fzf.vim')
call minpac#add('nvim-treesitter/nvim-treesitter', {'do': 'TSUpdate'})

" Python
call minpac#add('tmhedberg/SimpylFold')

" Language server support
" call minpac#add('neovim/nvim-lspconfig')
" call minpac#add('williamboman/mason.nvim')
" call minpac#add('williamboman/mason-lspconfig.nvim')

" CMake Build Environment
call minpac#add('cdelledonne/vim-cmake', {'type': 'opt'})

" Colorschemes
call minpac#add('vim-airline/vim-airline')
call minpac#add('tomasiser/vim-code-dark')
