+++
date = 2019-03-26T21:43:39+02:00
title = 'Markdown support for Vim'
tags = ['vim', 'markdown']
+++

I write a lot of Markdown in work, so it's worth configuring vim to support it
well.

*   Install https://github.com/plasticboy/vim-markdown to get syntax
    highlighting, folding, and more.
*   Add these lines to `~/.vimrc`:

    ```vim
    " Recognise bulleted lists starting with ^\*, so that line wrapping doesn't
    " destroy bulleted lists.
    autocmd FileType markdown setlocal formatoptions+=n
      \ formatlistpat=^\\s*\\(\\*\\\|[0-9]\\.\\)\\s\\+
    " Automatically wrap text at textwidth.
    autocmd FileType markdown setlocal formatoptions+=t formatoptions-=l
    " Interpret blockquotes (lines starting with '>') as comments, so that line
    " wrapping doesn't mangle the blockquote markers.
    autocmd FileType markdown setlocal comments=n:>
    " Turn on spell checking.
    autocmd FileType markdown setlocal spell
    ```
