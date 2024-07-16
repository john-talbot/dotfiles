packadd minpac
call minpac#init({'verbose': 0, 'confirm': 'FALSE', 'progress_open': 'none', 'status_open': 'FALSE', 'status_auto': 'FALSE'})
source $HOME/.vim/packages.vim
call minpac#clean()
call minpac#update('', {'do': 'qall'})
