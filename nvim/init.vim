" set leader key
let g:mapleader = "\<Space>"

if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

call plug#begin('~/.config/nvim/autoload/plugged')

    " Better Syntax Support
    " Plug 'sheerun/vim-polyglot'
    Plug 'lukas-reineke/indent-blankline.nvim'
    " Python Syntax
    Plug 'numirias/semshi', {'do': ':UpdateRemotePlugins'}
    " File Explorer
    " Auto pairs for '(' '[' '{'
    Plug 'jiangmiao/auto-pairs'
    " Import sort
    Plug 'fisadev/vim-isort'
    " Comment lines
    Plug 'tpope/vim-commentary'
    " Colorscheme
    Plug 'Mofiqul/dracula.nvim'
    " Autocomplete
    Plug 'neovim/nvim-lspconfig'
    Plug 'hrsh7th/cmp-nvim-lsp'
    Plug 'hrsh7th/cmp-buffer'
    Plug 'hrsh7th/nvim-cmp'

    Plug 'saadparwaiz1/cmp_luasnip'
    Plug 'L3MON4D3/LuaSnip'


    Plug 'psf/black', { 'branch': 'stable' }
    " Pandoc, markdown and rmarkdown
    Plug 'vim-pandoc/vim-pandoc'
    Plug 'vim-pandoc/vim-pandoc-syntax'
    Plug 'vim-pandoc/vim-rmarkdown'
    Plug 'lervag/vimtex'

    " align tables
    Plug 'junegunn/vim-easy-align'

    Plug 'luochen1990/rainbow'
    Plug 'tweekmonster/django-plus.vim'
    Plug 'alvan/vim-closetag'
    Plug 'ap/vim-css-color'
    Plug 'ferrine/md-img-paste.vim'

    Plug 'kyazdani42/nvim-web-devicons' " for file icons
    Plug 'kyazdani42/nvim-tree.lua'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'lewis6991/gitsigns.nvim'

    Plug 'hoob3rt/lualine.nvim'

    Plug 'nvim-telescope/telescope.nvim'
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
call plug#end()


colorscheme dracula
set termguicolors

if $CONDA_PREFIX == ""
  let g:current_python_path=$CONDA_PYTHON_EXE
else
  let g:current_python_path=$CONDA_PREFIX.'/bin/python'
endif

:lua require("lsp")
:lua require("nvimtree")
:lua require("statusline")
:lua require("indent")



