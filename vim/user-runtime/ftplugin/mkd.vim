" For markdown files, we want to be able to 'compile' to HTML. I'm using Python
" 2.7's markdown module, which outputs HTML to STDOUT. However, Vim's makeprg
" setting too aggressively captures STDOUT, so let's just use a keybinding,
" instead.
nmap <leader>md :! python -m markdown "%:p" >"%:p:r.htm"<cr><cr>
