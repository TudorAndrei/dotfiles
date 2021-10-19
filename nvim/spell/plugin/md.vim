
autocmd BufNewFile,BufReadPost *.md set filetype=markdown
" complie Rmd w/ and w/o output
autocmd Filetype rmd noremap <F5> :w <bar> :!echo<space>"require(rmarkdown);<space>render('<c-r>%')"<space>\|<space>R<space>--vanilla<enter> :<enter>
autocmd Filetype rmd noremap <F6> :w <bar> :!echo<space>"require(rmarkdown);<space>render('<c-r>%')"<space>\|<space>R<space>--vanilla<enter>

" open the current Rmarkdown in zathura
autocmd Filetype rmd noremap <leader>z :! zathura %:p:r'.pdf' &<enter> :<enter>

" Align GitHub-flavored Markdown tables
au FileType markdown,rmd vnoremap <Leader><Bslash> :EasyAlign*<Bar><Enter>

autocmd FileType markdown,rmd nmap <buffer> <F7> :call mdip#MarkdownClipboardImage()<CR>
" inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
