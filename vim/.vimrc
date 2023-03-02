set nocompatible
filetype off

" remap leader key
"
let mapleader = "<Space>"

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
  Plugin 'presernvim/nerdtree'
  Plugin 'VundleVim/Vundle.vim'
  Plugin 'dracula/vim',{'name':'dracula'}
  Plugin 'xuhdev/vim-latex-live-preview'
  Plugin 'vim-airline/vim-airline'
  Plugin 'Valloric/YouCompleteMe'
  Plugin 'tmhedberg/SimpylFold'
  Plugin 'vim-syntastic/syntastic'
  Plugin 'nvie/vim-flake8'
  Plugin 'junegunn/goyo.vim'
  Plugin 'vim-pandoc/vim-pandoc'
  Plugin 'vim-pandoc/vim-pandoc-syntax'
  Plugin 'vim-pandoc/vim-rmarkdown'
  Plugin 'lervag/vimtex'
call vundle#end()

colorscheme dracula

filetype plugin indent on

colorscheme dracula
" Enable folding
set foldmethod=indent
set foldlevel=99
set encoding=utf-8

" Autocomplete

let g:ycm_autoclose_preview_window_after_completion=1
map <leader>g  :YcmCompleter GoToDefinitionElseDeclaration<CR>

" Autoremote trailing white space
autocmd BufWritePre * %s/\s\+$//e

" Turn on syntax highlighting.
syntax on
let python_highlight_all=1


set colorcolumn=80
" Disable the default Vim startup message.
set shortmess+=I

" Show line numbers.
set number

set relativenumber
set laststatus=2
set backspace=indent,eol,start
set hidden
set smartcase
set incsearch

nmap Q <Nop> " 'Q' in normal mode enters Ex mode. You almost never want this.
set noerrorbells visualbell t_vb=

" KEYBINDS
map <C-n> :NERDTreeToggle<CR>

" Enable folding with the spacebar

"split navigations
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" Remvove arrow keys
nnoremap <Left>  :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up>    :echoe "Use k"<CR>
nnoremap <Down>  :echoe "Use j"<CR>
" ...and in insert mode
inoremap <Left>  <ESC>:echoe "Use h"<CR>
inoremap <Right> <ESC>:echoe "Use l"<CR>
inoremap <Up>    <ESC>:echoe "Use k"<CR>
inoremap <Down>  <ESC>:echoe "Use j"<CR>

autocmd Filetype rmd map <F5> :w <bar> :!echo<space>"require(rmarkdown);<space>render('<c-r>%')"<space>\|<space>R<space>--vanilla<enter> :<enter>
autocmd Filetype rmd map <F6> :! zathura %:p:r'.pdf' &<enter> :<enter>
