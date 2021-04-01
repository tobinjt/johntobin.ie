+++
date = 2019-03-26T21:43:39+02:00
title = 'Markdown support for Vim'
tags = ['vim', 'markdown']
+++

I write a lot of Markdown in work, so it's worth configuring vim to support it
well.

- Install https://github.com/plasticboy/vim-markdown to get syntax
  highlighting. I disable that plugin's folding in favour of my own because I
  find mine is simpler and works better.
- Add these lines to `~/.vimrc`:

  ```vim
  " Enable "frontmatter" as used by Hugo.
  let g:vim_markdown_frontmatter = 1
  let g:vim_markdown_toml_frontmatter = 1
  " Disable folding and use mine instead.
  let g:vim_markdown_folding_disabled = 1
  " Recognise bulleted lists starting with ^\*, so that line wrapping doesn't
  " destroy bulleted lists.
  autocmd FileType markdown setlocal formatoptions+=n
    \ formatlistpat=^\\s*\\([-*]\\\|[0-9]\\.\\)\\s\\+
  " Automatically wrap text at textwidth.
  autocmd FileType markdown setlocal formatoptions+=t formatoptions-=l
  " Interpret blockquotes (lines starting with '>') as comments, so that line
  " wrapping doesn't mangle the blockquote markers.
  autocmd FileType markdown setlocal comments=n:>
  " Turn on spell checking.
  autocmd FileType markdown setlocal spell
  " Enable simple folding.
  autocmd FileType markdown setlocal foldmethod=expr
    \ foldexpr=MarkdownFolding(v:lnum)

  if ! exists('g:MarkdownMinimumHeaderFoldingLevel')
    let g:MarkdownMinimumHeaderFoldingLevel = 2
  endif
  function! MarkdownFolding(lnum)
    let l:line = getline(a:lnum)
    let l:matches = matchlist(l:line, '^\(#\+\)')
    if len(l:matches) == 0
      return '='
    endif
    let l:length = strlen(l:matches[1])
    if l:length <= 1
      return '='
    endif
    return '>' . (l:length - (g:MarkdownMinimumHeaderFoldingLevel - 1))
  endfunction
  ```
