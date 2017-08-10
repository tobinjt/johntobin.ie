I needed to write a static web page in work recently, so I decided to use
Markdown, because writing HTML is time-consuming and unproductive.  I was
writing a reasonably large page, so I wanted folding, which the syntax
highlighting I've been using for years didn't support.  I wrote some simple
folding support to create nested folds at headers, and also reconfigured vim to
recognise bulleted lists so that reformatting with `gq` doesn't destroy lists.

Save
<https://github.com/tobinjt/dotfiles/blob/master/.vim/plugin/markdown-folding.vim>
as `~/.vim/plugin/markdown-folding.vim` - it will be automatically loaded every
time you start vim, but it won't do anything by itself.

Add these lines to `~/.vimrc`:

    " Associate *.mdwn with markdown syntax.
    autocmd BufRead,BufNewFile *.mdwn setlocal filetype=markdown
    " Recognise bulleted lists starting with ^\*
    autocmd FileType markdown setlocal formatoptions+=n formatlistpat=^\\*\\s*
    " Interpret blockquotes as comments.
    autocmd FileType markdown setlocal comments=n:>
    " Configure folding to use the function defined earlier.
    autocmd FileType markdown setlocal foldmethod=expr \
        foldexpr=MarkdownFolding(v:lnum)
