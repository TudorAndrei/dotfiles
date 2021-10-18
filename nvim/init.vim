" set leader key
let g:mapleader = "\<Space>"

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

" Conda prefixes for runnng python programs
if $CONDA_PREFIX == ""
  let g:current_python_path=$CONDA_PYTHON_EXE
else
  let g:current_python_path=$CONDA_PREFIX.'/bin/python'
endif


:lua require("lsp")
