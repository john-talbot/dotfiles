" Vim compiler file
" Compiler:	Flake8 for Python
" Maintainer: John Talbot <john.andrew.talbot@gmail.com>
" Last Change: 2024 July 16

if exists("current_compiler")
  finish
endif
let current_compiler = "flake8"

if exists(":CompilerSet") != 2		" older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

CompilerSet makeprg=python3\ -m\ flake8\ --max-line-length\ 88\ %
CompilerSet errorformat=%E%f:%l:%c:\ %m,%-Z%p^,%-G%.%#

