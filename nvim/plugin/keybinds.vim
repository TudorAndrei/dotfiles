nmap Q <Nop>
" Switch buffers
noremap  <leader>n :bn<cr>
noremap <leader>p :bp<cr>
noremap <leader>d :bd<cr>

"split navigations
nnoremap <C-h> <C-W><C-H>
nnoremap <C-j> <C-W><C-J>
nnoremap <C-k> <C-W><C-K>
nnoremap <C-l> <C-W><C-L>
nnoremap <silent><leader>rn :lua vim.lsp.buf.rename()<CR>
nnoremap <silent> gd <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> gD <cmd>lua vim.lsp.buf.declaration()<CR>
nnoremap <silent> gr <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> gi <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> K <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> <C-k> <cmd>lua vim.lsp.buf.signature_help()<CR>


nnoremap <leader>vsh :lua vim.lsp.buf.signature_help()<CR>

nnoremap <leader>vca :lua vim.lsp.buf.code_action()<CR>
nnoremap <leader>vsd :lua vim.lsp.diagnostic.show_line_diagnostics(); vim.lsp.util.show_line_diagnostics()<CR>
nnoremap <leader>vll :call LspLocationList()<CR>

nnoremap <leader>vn :lua vim.lsp.diagnostic.goto_next()<CR>
nnoremap <leader>vp :lua vim.lsp.diagnostic.goto_prev()<CR>


" Python indentaiotn
au BufNewFile,BufRead *.py
    \ set expandtab       |" replace tabs with spaces
    \ set autoindent      |" copy indent when starting a new line
    \ set foldmethod=indent

" Align GitHub-flavored Markdown tables
au FileType markdown,rmd vnoremap <Leader><Bslash> :EasyAlign*<Bar><Enter>

autocmd FileType markdown,rmd nmap <buffer> <F7> :call mdip#MarkdownClipboardImage()<CR>

" go to normal mode in terminal
tnoremap <Esc> <C-\><C-n>

" keybinds
noremap <silent> <C-n> :NERDTreeToggle<CR>
