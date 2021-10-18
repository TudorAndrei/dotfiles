" set leader key
let g:mapleader = "\<Space>"

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
set pumheight=20
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
" We don't need to see things like -- INSERT -- anymore
set noshowmode

" By default timeoutlen is 1000 ms
set timeoutlen=100
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

" auto-install vim-plug
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

let g:polyglot_disabled = ['python']
" Plug

call plug#begin('~/.config/nvim/autoload/plugged')

    " Better Syntax Support
    Plug 'sheerun/vim-polyglot'
    " Python Syntax
    Plug 'numirias/semshi', {'do': ':UpdateRemotePlugins'}
    " File Explorer
    Plug 'scrooloose/NERDTree'
    " Auto pairs for '(' '[' '{'
    Plug 'jiangmiao/auto-pairs'
    " Import sort
    Plug 'fisadev/vim-isort'
    " Comment lines
    Plug 'tpope/vim-commentary'
    " Colorscheme
    Plug 'dracula/vim', {'name': 'dracula'}
    " Autocomplete
    Plug 'neovim/nvim-lspconfig'
    Plug 'hrsh7th/cmp-nvim-lsp'
    Plug 'hrsh7th/cmp-buffer'
    Plug 'hrsh7th/nvim-cmp'

    Plug 'saadparwaiz1/cmp_luasnip'
    Plug 'L3MON4D3/LuaSnip'

    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'

    " Pandoc, markdown and rmarkdown
    Plug 'vim-pandoc/vim-pandoc'
    Plug 'vim-pandoc/vim-pandoc-syntax'
    Plug 'vim-pandoc/vim-rmarkdown'
    Plug 'lervag/vimtex'
    " align tables
    Plug 'junegunn/vim-easy-align'

    " Plug 'eetsukumaran/vim-pythonsense'
    Plug 'luochen1990/rainbow'
    Plug 'tweekmonster/django-plus.vim'
    Plug 'alvan/vim-closetag'
    Plug 'ap/vim-css-color'
    Plug 'ferrine/md-img-paste.vim'
call plug#end()

colorscheme dracula

" LSP config (the mappings used in the default file don't quite work right)
nnoremap <silent> gd <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> gD <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> gr <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> gi <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> K <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> <C-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> <C-n> <cmd>lua vim.lsp.diagnostic.goto_prev()<CR>
nnoremap <silent> <C-p> <cmd>lua vim.lsp.diagnostic.goto_next()<CR>

" Map

nmap Q <Nop>

" go to normal mode in terminal
tnoremap <Esc> <C-\><C-n>

" keybinds
noremap <silent> <C-n> :NERDTreeToggle<CR>

" Switch buffers
noremap  <leader>n :bn<cr>
noremap <leader>p :bp<cr>
noremap <leader>d :bd<cr>

"split navigations
nnoremap <C-h> <C-W><C-H>
nnoremap <C-j> <C-W><C-J>
nnoremap <C-k> <C-W><C-K>
nnoremap <C-l> <C-W><C-L>

" Autoremove trailing white space
autocmd BufWritePre * %s/\s\+$//e

" Set md as markdown
autocmd BufNewFile,BufReadPost *.md set filetype=markdown
" complie Rmd w/ and w/o output
autocmd Filetype rmd noremap <F5> :w <bar> :!echo<space>"require(rmarkdown);<space>render('<c-r>%')"<space>\|<space>R<space>--vanilla<enter> :<enter>
autocmd Filetype rmd noremap <F6> :w <bar> :!echo<space>"require(rmarkdown);<space>render('<c-r>%')"<space>\|<space>R<space>--vanilla<enter>

" open the current Rmarkdown in zathura
autocmd Filetype rmd noremap <leader>z :! zathura %:p:r'.pdf' &<enter> :<enter>

" Open html in firefox
autocmd Filetype html noremap <silent> <leader>f :!firefox %<enter>

" Run python on the current file
autocmd Filetype python nnoremap <buffer> <F5> :w<CR>:!python3 "%"<CR>



" inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"

au FileType markdown,rmd vnoremap <Leader><Bslash> :EasyAlign*<Bar><Enter>

" After col 80 error highlight
" au BufWinEnter * let w:m1=matchadd('Search', '\%<81v.\%>77v', -1)
" au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)

" Python indentaiotn
au BufNewFile,BufRead *.py
    \ set expandtab       |" replace tabs with spaces
    \ set autoindent      |" copy indent when starting a new line
    \ set foldmethod=indent

" Plugins
"
" Pandoc
let g:pandoc#syntax#conceal#use = 0

"JS beautyfy
autocmd Filetype htmldjango nnoremap <silent> <leader>b :!js-beautify -f % -r --type html  -q <enter><CR>

" Vim Commentary
nnoremap <leader>/ :Commentary<CR>
vnoremap <leader>/ :Commentary<CR>

" Tex
let g:tex_flavor = 'latex'

" Rainbow Brackets
"
let g:rainbow_active = 1
let g:rainbow_conf = {'separately': {'htmldjango': 0}}
" Conda prefixes for runnng python programs

if $CONDA_PREFIX == ""
  let g:current_python_path=$CONDA_PYTHON_EXE
else
  let g:current_python_path=$CONDA_PREFIX.'/bin/python'
endif


" Align GitHub-flavored Markdown tables
au FileType markdown vnoremap <Leader><Bslash> :EasyAlign*<Bar><Enter>
au FileType rmarkdown vnoremap <Leader><Bslash> :EasyAlign*<Bar><Enter>

" Closetag.vim
"
let g:closetag_filenames = '*.html,*.xhtml,*.phtml'

" integer value [0|1]
" This will make the list of non-closing tags case-sensitive (e.g. `<Link>` will be closed while `<link>` won't.)
let g:closetag_emptyTags_caseSensitive = 1

" Disables auto-close if not in a "valid" region (based on filetype)
let g:closetag_regions = {
    \ 'typescript.tsx': 'jsxRegion,tsxRegion',
    \ 'javascript.jsx': 'jsxRegion',
    \ }

" Shortcut for closing tags, default is '>'
let g:closetag_shortcut = '>'
" Add > at current position without closing the current tag, default is ''
let g:closetag_close_shortcut = '<leader>>'

" Airline
" enable tabline
"
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ''
let g:airline#extensions#tabline#left_alt_sep = ''
let g:airline#extensions#tabline#right_sep = ''
let g:airline#extensions#tabline#right_alt_sep = ''
let g:airline_left_sep = ''
let g:airline_right_sep = ''
let g:airline_theme = 'deus'
" enable word count
let g:airline#extensions#wordcount#filetypes = '\vasciidoc|help|mail|markdown|markdown.pandoc|org|rst|tex|text|rmd'

" Images in md and rmd
autocmd FileType markdown,rmd nmap <buffer> <F7> :call mdip#MarkdownClipboardImage()<CR>

:lua require("lsp")
