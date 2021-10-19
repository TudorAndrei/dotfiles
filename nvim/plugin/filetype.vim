" Autoremove trailing white space
autocmd BufWritePre * %s/\s\+$//e

" Set md as markdown
" Open html in firefox
autocmd Filetype html noremap <silent> <leader>f :!firefox %<enter>
" After col 80 error highlight
" au BufWinEnter * let w:m1=matchadd('Search', '\%<81v.\%>77v', -1)
" au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
" Vim Commentary
nnoremap <leader>/ :Commentary<CR>
vnoremap <leader>/ :Commentary<CR>
