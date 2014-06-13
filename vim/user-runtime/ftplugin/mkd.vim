" For markdown files, we want to be able to 'compile' to HTML. I'm using Python
" 2.7's markdown module, which outputs HTML to STDOUT. However, Vim's makeprg
" setting too aggressively captures STDOUT, so let's just use a keybinding,
" instead.
"
" This mapping requires the following:
"   * Python
"   * The Markdown module - https://pypi.python.org/pypi/Markdown
"   * The xhtml_wrap extension - https://bitbucket.org/paulprovost/xhtml_wrap

function! ExtractMarkdownTitle()
    let unnamed_register_contents = @@

    " Search for the first H1 marker in the file. Yank the rest of the text on
    " that line to the unnamed register.
    execute "normal! gg/\<c-u>\^# \<cr>wy$"
    let title = @@
    let @@ = unnamed_register_contents
    return title
endfunction

function! GetMarkdownCssPath()
    let orig_dir = getcwd()
    lcd %:p:h
    let css_path = findfile("markdown.css", "**")
    " Not sure why this is necessary. Using lcd as we did above, but with
    " a variable, gives this:
    "   E344: Can't find directory "orig_dir" in cdpath
    "   E472: Command failed
    execute "lcd " . orig_dir
    return css_path
endfunction

function! ConvertMarkdownToHtml()
    let cmd = "markdown_py -o html5 -f %:p:r.htm"

    " If we don't find a markdown.css file, assume it's in the current path
    let css_path = GetMarkdownCssPath()
    if css_path ==? ""
        let css_path = "markdown.css"
    endif
    let cmd .= ' -x "xhtml_wrap(css_url=' . css_path

    " Only specify a title if we find one
    let title_text = ExtractMarkdownTitle()
    if title_text !=? ""
        let cmd .= ", title=" . title_text
    endif
    let cmd .= ")\" %:p"
    execute "! " . cmd
endfunction

nmap <leader>md :<c-u>call ConvertMarkdownToHtml()<cr><cr>
