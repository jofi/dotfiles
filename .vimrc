let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()

Plug 'tpope/vim-sensible'
Plug 'jlanzarotta/bufexplorer'
Plug 'tpope/vim-surround'
Plug 'preservim/nerdtree'
let g:NERDTreeHijackNetrw = 0

Plug 'preservim/nerdcommenter'
let g:NERDSpaceDelims = 1
let g:NERDShutUp = 1

Plug 'mileszs/ack.vim'
Plug 'ctrlpvim/ctrlp.vim'

call plug#end()

" Quick vimrc editing
map <leader>ve :edit ~/.vimrc<CR>
map <leader>vs :source ~/.vimrc<CR>

" Buffer navigation
map <silent> <F11> :if exists(":BufExplorer")<Bar>exe "BufExplorer"<Bar>else<Bar>buffers<Bar>endif<CR>
map <C-F4> :bdelete<CR>

" Surround custom pairs
let g:surround_{char2nr('-')} = "<% \r %>"
let g:surround_{char2nr('=')} = "<%= \r %>"
let g:surround_{char2nr('8')} = "/* \r */"
let g:surround_{char2nr('s')} = " \r"
let g:surround_{char2nr('^')} = "/^\r$/"
let g:surround_indent = 1

" Search with Ack
map <C-F> :Ack<space>
map <C-f> :Ack<space>

" Open URL under cursor in browser
function! OpenURL(url)
  if has("mac")
    exe "silent !open \"".a:url."\""
  else
    exe "silent !xdg-open \"".a:url."\""
  endif
  redraw!
endfunction
command! -nargs=1 OpenURL :call OpenURL(<q-args>)
nnoremap gb :OpenURL <cfile><CR>
nnoremap gG :OpenURL http://www.google.com/search?q=<cword><CR>
nnoremap gW :OpenURL http://en.wikipedia.org/wiki/Special:Search?search=<cword><CR>

" Ctrl-l clears search highlighting
nnoremap <silent> <C-l> :nohl<CR><C-l>

" Save as sudo when forgot to start vim with sudo
cmap w! w !sudo tee > /dev/null %

" macOS Ctrl-a/e line navigation
if has("mac") || $TERM_PROGRAM ==# "iTerm.app"
  nnoremap <C-a> 0
  inoremap <C-a> <C-o>0
  nnoremap <C-e> $
  inoremap <C-e> <C-o>$
endif
