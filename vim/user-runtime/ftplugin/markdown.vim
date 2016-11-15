" Use the Chrome extension Markdown Preview Plus, found at:
" https://github.com/volca/markdown-preview

function! SendToMarkdownPreview(path)
    let s:cmd = '!"' . a:path . '" "%:p"'
    silent execute s:cmd
endfunction

noremap <leader>md :call SendToMarkdownPreview(g:browser_path)
