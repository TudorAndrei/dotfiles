"nable tabline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ''
let g:airline#extensions#tabline#left_alt_sep = ''
let g:airline#extensions#tabline#right_sep = ''
let g:airline#extensions#tabline#right_alt_sep = ''

" enable powerline fonts
" let g:airline_powerline_fonts = 1
let g:airline_left_sep = ''
let g:airline_right_sep = ''

" Switch to your current theme
let g:airline_theme = 'deus'
set statusline^=%{coc#status()}

" Always show tabs
set showtabline=2

" enalbe word count
let g:airline#extensions#wordcount#filetypes = '\vasciidoc|help|mail|markdown|markdown.pandoc|org|rst|tex|text'

set laststatus=2
