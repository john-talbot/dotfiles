" MIT License
"
" Copyright (c) [2024] [John Andrew Talbot]
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the 'Software'), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in all
" copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
" SOFTWARE.


"################################################################################
" MINPAC PACKAGE MANAGER
"################################################################################
" Function to initialize minpac. Usage: 'call PackInit()'
function! PackInit() abort
    packadd minpac
    call minpac#init()
    source $HOME/.config/nvim/packages.vim
endfunction

" Convenience commands
command! PackUpdate source $MYVIMRC | call PackInit() | call minpac#update()
command! PackClean  source $MYVIMRC | call PackInit() | call minpac#clean()
command! PackStatus packadd minpac | call minpac#status()

" Add matchit plugin
packadd! matchit


"################################################################################
" APPEARANCE
"################################################################################
if !empty(glob(expand("$HOME/.config/nvim/pack/minpac/start/vim-code-dark")))
    colorscheme codedark
endif

" Load desired airline extensions
let g:airline_extensions = ['branch', 'virtualenv']

" Remove encoding section of airline
let g:airline_section_y = ''

" Fix font problems by removing glyphs from airline symbols
" First check if symbol dictionary exists to avoid overwrite
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif

" Remove glyphs from column and line numbers
let g:airline_symbols.colnr = ' Col: '
let g:airline_symbols.linenr = ' Line: '
let g:airline_symbols.maxlinenr = ' '


"################################################################################
" OPTIONS
"################################################################################
" Enable swap files and set directory
set directory^=~/.config/nvim/swap//
set swapfile

" Enable backup files and set directory
set backup
set backupdir^=~/.config/nvim/backup//

" Enable persistent undo and set directory
set undofile
set undodir=~/.config/nvim/undo//

" Default to using 4 spaces per tab
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

" Save last 2000 commands in history rather than 20
set history=2000

" Configure wildmenu to behave like zsh
set wildmenu
set wildmode=full

" Enable filetype recognition and load relevant plugin
filetype plugin indent on

" Enable syntax highlighting
" syntax on

" Show line numbers
set number

" Set incremental search and highlight search results
set incsearch
set hlsearch

" Disable mouse
set mouse=

" Split new windows below and to the right
set splitbelow
set splitright

" Set insert mode completion to use fuzzy matching and only insert after
" selection
set completeopt+=noinsert,fuzzy

" Set grep to ripgrep by default
set grepprg=rg\ --vimgrep\ --no-heading\ --smart-case


"################################################################################
" VARIABLES
"################################################################################
""" Black
" Don't install black automatically with virtualenv
let g:black_use_virtualenv = 0

" Enable black formatting on save
let g:black_format_on_save = 1


"################################################################################
" KEYBINDINGS
"################################################################################
" Keybind Ctrl-l to call nohlsearch as well as redraw screen
nnoremap <silent> <C-l> :<C-u>nohlsearch<CR><C-l>

" Terminal mode exit with normal Esc
tnoremap <Esc> <C-\><C-n>
tnoremap <C-v><Esc> <Esc>


"################################################################################
" COMMANDS
"################################################################################
" Automatically open quickfix window after running a quickfix command
augroup JTQuickFixGroup
    autocmd!
    autocmd QuickFixCmdPost [^l]* nested cwindow
augroup END


"################################################################################
" LUA INIT
"################################################################################
" Extra lua initialization for neovim (located at .config/nvim/lua/init.lua)
lua require('init')
