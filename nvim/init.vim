" set leader key
let g:mapleader = "\<Space>"

" Set
set tabstop=4 softtabstop=4
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
" This is recommended by coc
set nobackup
" This is recommended by coc
set nowritebackup
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
    Plug 'neoclide/coc.nvim', {'branch': 'release'}

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

    Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }
call plug#end()

colorscheme dracula


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
" JS beautyfy
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
  let s:current_python_path=$CONDA_PYTHON_EXE
else
  let s:current_python_path=$CONDA_PREFIX.'/bin/python'
endif
call coc#config('python', {'pythonPath': s:current_python_path})

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
"
let g:closetag_shortcut = '>'

" Add > at current position without closing the current tag, default is ''
let g:closetag_close_shortcut = '<leader>>'

" Coc
"

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  imap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" Use `[g` and `]g` to navigate diagnostics
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying codeAction to the selected region.
" Example: `<leader>aap` for current paragraph
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying codeAction to the current line.
nmap <leader>ac  <Plug>(coc-codeaction)
" Apply AutoFix to problem on the current line.
nmap <leader>qf  <Plug>(coc-fix-current)

" Introduce function text object
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap if <Plug>(coc-funcobj-i)
omap af <Plug>(coc-funcobj-a)

" Use <TAB> for selections ranges.
" NOTE: Requires 'textDocument/selectionRange' support from the language server.
" coc-tsserver, coc-python are the examples of servers that support it.
"nmap <silent> <TAB> <Plug>(coc-range-select)
"xmap <silent> <TAB> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')


" Mappings using CoCList:
" Show all diagnostics.
nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
"
let g:coc_node_path = '/home/tudor/.nvm/versions/node/v15.5.0/bin/node'

" Airline
" enable tabline
"
" Add (Neo)Vim's native statusline support.
"
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ''
let g:airline#extensions#tabline#left_alt_sep = ''
let g:airline#extensions#tabline#right_sep = ''
let g:airline#extensions#tabline#right_alt_sep = ''
let g:airline_left_sep = ''
let g:airline_right_sep = ''

" Switch to your current theme
let g:airline_theme = 'deus'

" enable word count
let g:airline#extensions#wordcount#filetypes = '\vasciidoc|help|mail|markdown|markdown.pandoc|org|rst|tex|text'

