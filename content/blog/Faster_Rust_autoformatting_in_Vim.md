+++
date = 2024-06-04T10:50:50+01:00
title = "Faster rust autoformatting in vim"
tags = ['development', 'programming', 'Rust', 'vim']
+++

I'm slowly learning [Rust](https://www.rust-lang.org/), and as usual I'm using
[Vim](http://www.vim.org) to write my code. I'm using
[rust.vim](https://github.com/rust-lang/rust.vim) for syntax highlighting, and
[vim-lsp](https://github.com/prabirshrestha/vim-lsp) and
[rust-analyzer](https://rust-analyzer.github.io/) for [Language Server
Protocol](https://microsoft.github.io/language-server-protocol/) support.

As I wrote more code I felt that saving my source file was getting slower,
sometimes taking up to 10 seconds! Eventually this got annoying enough that I
used Vim's profiling support (`:help profiling`) to identify the problematic
code:

```vim
:profile start profile.log
:profile file *
:profile func *
:w
:profile stop
:q
```

The resulting `profile.log` was 13360 lines long! I looked for the functions
taking the longest time with:

```shell
rg 'Total time' profile.log | sort -k 3n
...
Total time:   0.117917000
Total time:   0.122267000
Total time:   0.281978000
Total time:   0.376979000
Total time:  11.539883000
Total time:  11.540752000
```

Clearly one function is a real problem. I searched for `Total time:
11.540752000`, which brought me to a trace where the only long running call was:

```text
    1  11.540633000   0.000257000     call s:RunRustfmt(s:RustfmtCommand(), '', v:true)
```

This tells me that the problematic function is autoformatting the file, and when
I tested by disabling autoformatting saving was almost instantaneous.

Searching for `Total time:  11.539883000` brought me to a longer trace
containing:

```text
    1                11.433683000         call setline(1, l:content)
```

`setline()` is a Vim function that changes the content of the file. _Something_
is reacting to the file contents being changed, but what? Searching for _vim
setline very slow_ found some StackOverflow posts asking about `setline()` and
vim-lsp interacting badly. Disabling vim-lsp made autoformatting very quick,
confirming that `setline()` interacts badly with vim-lsp. The hypothesised problem
is that vim-lsp keeps feeding greater and greater prefixes of the file to the
LSP server, explaining why it slows down as the file grows.

I find LSP valuable, and autoformat valuable, so I wanted to find a way to keep
both. I read through the vim-lsp documentation looking for an option to help
with this, e.g. waiting longer between updates to the LSP server. Instead I
found an alternative way to implement autoformat! vim-lsp provides a command,
`LspDocumentFormatSync`, that formats the buffer using the LSP server. I
disabled vim-rust's autoformat support, and added an `autocmd` to autoformat the
buffer contents before writing it.

```vim
let g:rustfmt_autosave = 0
autocmd BufWritePre *.rs LspDocumentFormatSync
```

This gives me autoformat _and_ vim-lsp, without any slowdown :)
