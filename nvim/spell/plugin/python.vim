
" Run python on the current file
autocmd Filetype python nnoremap <buffer> <F5> :w<CR>:!python3 "%"<CR>
" Python indentaiotn
au BufNewFile,BufRead *.py
    \ set expandtab       |" replace tabs with spaces
    \ set autoindent      |" copy indent when starting a new line
    \ set foldmethod=indent
