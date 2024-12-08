let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

if filereadable(expand("~/.vimrc.before"))
  source ~/.vimrc.before
endif

" start
call plug#begin()

" List your plugins here
Plug 'tpope/vim-sensible'
Plug 'jlanzarotta/bufexplorer'
Plug 'tpope/vim-surround'
Plug 'preservim/nerdtree'
let g:NERDTreeHijackNetrw = 0

Plug 'preservim/nerdcommenter'
let g:NERDSpaceDelims = 1

Plug 'mileszs/ack.vim'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'vim-ruby/vim-ruby'
Plug 'tpope/vim-rails'  " Optional, enhances Ruby development
"Plug 'k0kubun/vim-xmpfilter'



call plug#end()
" end

if filereadable(expand("~/.vimrc.after"))
  source ~/.vimrc.after
endif

