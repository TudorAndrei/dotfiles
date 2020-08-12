" set leader key
let g:mapleader = "\<Space>"

" Enables syntax highlighing
syntax enable
" Required to keep multiple buffers open multiple buffers
set hidden
 " Display long lines as just one line
set nowrap
" The encoding displayed
set encoding=utf-8
" Makes popup menu smaller
set pumheight=10
" The encoding written to file
set fileencoding=utf-8
" Show the cursor position all the time
set ruler
" More space for displaying messages
set cmdheight=2
" treat dash separated words as a word text object"
set iskeyword+=-
" Enable your mouse
set mouse=a
" Horizontal splits will automatically be below
set splitbelow
" Vertical splits will automatically be to the right
set splitright
" Support 256 colors
set t_Co=256
" So that I can see `` in markdown files
set conceallevel=0
" Change the number of space characters inserted for indentation
set shiftwidth=2
" Makes tabbing smarter will realize you have 2 vs 4
set smarttab
" Converts tabs to spaces
set expandtab
" Makes indenting smart
set smartindent
" Good auto indent
set autoindent
" Always display the status line
set laststatus=0
" tell vim what the background color looks like
set background=dark
" Always show tabs
set showtabline=2
" We don't need to see things like -- INSERT -- anymore
set noshowmode
" This is recommended by coc
set nobackup
" This is recommended by coc
set nowritebackup
" Faster completion
set updatetime=300
" By default timeoutlen is 1000 ms
set timeoutlen=100
" Stop newline continution of comments
set formatoptions-=cro
" Copy paste between vim and everything else
set clipboard=unnamedplus

" auto source when writing to init.vm alternatively you can run :source $MYVIMRC
au! BufWritePost $MYVIMRC source %



let python_highlight_all=1

set colorcolumn=80

set shortmess+=I

" Enable folding
set foldmethod=indent
set foldlevel=99
set encoding=utf-8

" Autoremove trailing white space
autocmd BufWritePre * %s/\s\+$//e

" Show line numbers.
set number

set relativenumber
set laststatus=2

set backspace=indent,eol,start
set hidden
set smartcase
set incsearch


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
autocmd Filetype rmd map <F4> :w <bar> ::!echo<space>"require(rmarkdown);<space>render('<c-r>%')"<space>\|<space>R<space>--vanilla<enter>
autocmd Filetype rmd map <F6> :! zathura %:p:r'.pdf' &<enter> :<enter>

inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
nmap Q <Nop>
set noerrorbells visualbell t_vb=
