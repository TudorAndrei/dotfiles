" Set
set tabstop=4
set softtabstop=4
set shiftwidth=4
set guicursor=
" remove the hl after searching
set nohlsearch
" Enables syntax highlighing
syntax enable
" Required to keep multiple buffers open multiple buffers
set hidden
 " Display long lines as just one line
set nowrap
" Always show tabs
set showtabline=2
" Makes popup menu smaller
set pumheight=30
" Show the cursor position all the time
set ruler
" More space for displaying messages
set cmdheight=1
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
" Makes tabbing smarter will realize you have 2 vs 4
set smarttab
" Converts tabs to spaces
set expandtab
" Makes indenting smart
set smartindent
" Good auto indent
set autoindent
" Always display the status line
set laststatus=2
" tell vim what the background color looks like
set background=dark
" We don't need to see things like -- INSERT -- anymore
set noshowmode

" By default timeoutlen is 1000 ms
set timeoutlen=1000
" Stop newline continution of comments
set formatoptions-=cro
" Copy paste between vim and everything else
set clipboard=unnamedplus

set scrolloff=5

let python_highlight_all=1

" color the 80thcolumn
" set colorcolumn=80
" autocmd Filetype python set colorcolumn=80
" TextEdit might fail if hidden is not set.
set hidden


" Give more space for displaying messages.
set cmdheight=2

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
set updatetime=100

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c
set shortmess+=I

set noerrorbells visualbell t_vb=

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
set signcolumn=yes


" Enable folding
set foldmethod=indent
set foldlevel=99

" Set file encoding
set encoding=utf-8
set fileencoding=utf-8


" Show line numbers.
set number
set relativenumber
set backspace=indent,eol,start
set smartcase
set incsearch
