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

" Vim Commentary
nnoremap <leader>/ :Commentary<CR>
vnoremap <leader>/ :Commentary<CR>
