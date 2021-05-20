+++
date = 2021-05-20T20:43:39+02:00
title = 'Markdown support for Vim'
tags = ['vim', 'markdown']
+++

I write a lot of Markdown in work, so it's worth configuring vim to support it
well.

- Install https://github.com/plasticboy/vim-markdown to get syntax
  highlighting. I disable that plugin's folding in favour of my own because I
  find mine is simpler and works better.
- Install https://github.com/google/vim-codefmt and https://prettier.io/ to get
  autoformatting on write - you'll need some of the config below to enable this.
- Add these lines to `~/.vimrc`:

<!-- prettier-ignore -->
  ```vim
  " Recognise ```shell as a block with sh syntax.
  let g:vim_markdown_fenced_languages = ['shell=sh']
  " Don't indent new lines in lists.
  let g:vim_markdown_new_list_item_indent = 0
  " Disable mappings; I don't use them, and they conflict with diff mappings
  " (e.g. " [c, ]c).
  let g:vim_markdown_no_default_key_mappings = 1
  " Highlight various types of front matter as used by Hugo.
  let g:vim_markdown_frontmatter = 1
  let g:vim_markdown_toml_frontmatter = 1
  let g:vim_markdown_json_frontmatter = 1
  " Support strikethrough.
  let g:vim_markdown_strikethrough = 1
  " Disable the plugin's folding because it randomly folds and unfolds when
  " editing; autocmds will use my simple folding instead.
  let g:vim_markdown_folding_disabled = 1

  " Load https://github.com/plasticboy/vim-markdown here so the settings above
  " take effect when the plugin is loaded.

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

  " Configure autoformat on write.
  Glaive codefmt plugin[mappings]
  augroup autoformat_settings
    autocmd FileType markdown AutoFormatBuffer prettier
  augroup END

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
