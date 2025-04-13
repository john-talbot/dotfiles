" Vim compiler file
" Compiler:	ruff for Python
" Maintainer: John Talbot <john.andrew.talbot@gmail.com>
" Last Change: 2025 Mar 31

if exists("current_compiler")
  finish
endif
let current_compiler = "ruff"

if exists(":CompilerSet") != 2		" older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

CompilerSet makeprg=python3\ -m\ ruff\ check\ --line-length\ 88\ --output-format\ concise\ %
CompilerSet errorformat=%E%f:%l:%c:\ %m,%-Z%p^,%-G%.%#

