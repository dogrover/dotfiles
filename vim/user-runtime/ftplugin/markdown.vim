" Use the Chrome extension Markdown Preview Plus, found at:
" https://github.com/volca/markdown-preview

function! SendToMarkdownPreview(path)
    let s:cmd = '!start "' . a:path . '" "%:p"'
    silent execute s:cmd
endfunction

noremap <leader>md :call SendToMarkdownPreview(g:browser_path)<CR>
nnoremap <leader>jh i## <C-R>=strftime("%d-%b-%Y: %H%M (%a)")<CR><CR><CR><Esc>

" Some entity escaping
" TODO: Figure out how to make these common with HTML files
imap \> &gt;
imap \< &gt;
imap \& &amp;
