+++
date = 2024-10-30T22:08:37Z
title = "Debugging in Neovim with nvim-dap"
tags = ['Neovim', 'Debugging', 'programming']
+++

## Motivation

I recently switched to Neovim after over 20 years of using Vim.  (At some point
I might write about why I switched, but not today.)  One of the few features I
missed in Vim compared to an IDE was debugging: sure, I could fire up `dlv` or
`gdb`, but I didn't have syntax highlighted code, automatic display of local
variables, and likely other helpful info I didn't even know I was missing. Sadly
I had never heard of <https://github.com/puremourning/vimspector> which does
provide this for Vim.  When I was setting up Neovim I frequently looked at
<https://lazyvim.github.io/> and <https://astronvim.com/> for help and
inspiration, and there I saw `nvim-dap` and decided to give it a try.  Getting
it working took me a good few evenings of experimentation and testing, so I
decided to document it as a reference for myself and as a resource for others.

Note: I use <https://github.com/folke/lazy.nvim> to manage my plugins, so the
example configs also use lazy.nvim.  As a newcomer to Neovim I am completely
unfamiliar with other plugin managers so I haven't tried to translate the
example configs to other plugin managers.

## Setting up nvim-dap

> <https://github.com/mfussenegger/nvim-dap> is is a Debug Adapter Protocol
> client implementation for Neovim. nvim-dap allows you to:
>
> - Launch an application to debug
> - Attach to running applications and debug them
> - Set breakpoints and step through code
> - Inspect the state of the application

`nvim-dap` does the heavy lifting of interfacing with the DAP server.
Surprisingly:

- It does not automatically configure DAP servers for different filetypes, you
  need to do that yourself (we will later).  You will see a helpful error
  message when you set a breakpoint without configuring a DAP server:

  ```text
  No configuration found for `markdown`. You need to add configs to
  `dap.configurations.markdown` (See `:h dap-configuration)
  ```

- It does not configure keybindings or commands to control the debugger, you
  need to do that yourself (we will in this section).

I must admit I found this confusing at first: I installed it and wondered _what
does it do?_ The answer is that it provides an API to build on, and the simplest
way to build on the API is to configure keybindings yourself.

Configuration:

- I copied keybindings from LazyVim, reformatted them, and eventually removed
  many of them when I used the UI (described later).
- All of the debugging plugins are lazy loaded.  IMHO lazy-loading is overdone,
  but because I rarely use a debugger I feel it's worth lazy-loading these.

```lua{
{
  "mfussenegger/nvim-dap",
  lazy = true,
  -- Copied from LazyVim/lua/lazyvim/plugins/extras/dap/core.lua and
  -- modified.
  keys = {
    {
      "<leader>db",
      function() require("dap").toggle_breakpoint() end,
      desc = "Toggle Breakpoint"
    },

    {
      "<leader>dc",
      function() require("dap").continue() end,
      desc = "Continue"
    },

    {
      "<leader>dC",
      function() require("dap").run_to_cursor() end,
      desc = "Run to Cursor"
    },

    {
      "<leader>dT",
      function() require("dap").terminate() end,
      desc = "Terminate"
    },
  },
}
```

## Configuring DAP servers

We need to configure a DAP server for each filetype we want to debug.  Happily
we can use plugins to do this for many filetypes rather than writing the config
ourselves.

<https://github.com/jay-babu/mason-nvim-dap.nvim> configures the majority of DAP
servers for us.  Getting this to work was an exercise in frustration, because
one piece of the config (`handlers = {}`) _looks_ optional but is actually
required (see comment in the config snippet).

```lua
{
  "jay-babu/mason-nvim-dap.nvim",
  ---@type MasonNvimDapSettings
  opts = {
    -- This line is essential to making automatic installation work
    -- :exploding-brain
    handlers = {},
    automatic_installation = {
      -- These will be configured by separate plugins.
      exclude = {
        "delve",
        "python",
      },
    },
    -- DAP servers: Mason will be invoked to install these if necessary.
    ensure_installed = {
      "bash",
      "codelldb",
      "php",
      "python",
    },
  },
  dependencies = {
    "mfussenegger/nvim-dap",
    "williamboman/mason.nvim",
  },
}
```

See the next section for language-specific plugins for DAP server configuration.

## Language-specific plugins

I use three language-specific plugins to give me a better DAP server
configuration for the languages I write in most: Go, Python, and Rust.  There
are other language-specific plugins available, see
<https://github.com/mfussenegger/nvim-dap/wiki/Extensions#language-specific-extensions>

### Go

<https://github.com/leoluz/nvim-dap-go> provides options for debugging
individual tests.  You need to install <https://github.com/go-delve/delve> and
have it in your `$PATH`.  I added a keymapping to debug an individual test, but
I haven't had an opportunity to try it yet.

```lua
{
  "leoluz/nvim-dap-go",
  config = true,
  dependencies = {
    "mfussenegger/nvim-dap",
  },
  keys = {
    {
      "<leader>dt",
      function() require('dap-go').debug_test() end,
      desc = "Debug test"
    },
  },
},
```

### Python

<https://github.com/mfussenegger/nvim-dap-python> provides config for debugging
individual tests.  You need to install <https://github.com/microsoft/debugpy>
and configure `nvim-dap-python` with the path to a Python binary that can
import `debugpy`.  <https://github.com/williamboman/mason.nvim> will install
`debugpy` in a `virtualenv`, and the correct path for that installation is
`~/.local/share/nvim/mason/packages/debugpy/venv/bin/python` - this ensures that
Python can find the `debugpy` package.

I haven't tested this, but if your Python project already uses a virtualenv I
suggest installing `debugpy` there so that all the modules you require are
available in one bundle rather than messing with multiple virtualenv
directories.  Before starting Neovim activate the virtualenv so that `python`
from the virtualenv is first in `$PATH`.  Configure `nvim-dap-python` to use
`python` (literally `python`, not `/path/to/python`) so it picks up `python`
from the virtualenv and hopefully everything will Just Work.  This should work
across multiple projects and multiple virtualenvs without reconfiguration.
`nvim-dap-python`

To test the `python` path you configure `nvim-dap-python` with, run:

```shell
/path/to/python -m debugpy --version
```

Unusually (in my limited experience) `nvim-dap-python`'s `setup()` doesn't take
an options table as a parameter.  Instead it takes an optional path to the
`python3` binary, and an optional options table.

```lua
{
  "mfussenegger/nvim-dap-python",
  lazy = true,
  config = function()
    local python = vim.fn.expand("~/.local/share/nvim/mason/packages/debugpy/venv/bin/python")
    require("dap-python").setup(python)
  end,
  -- Consider the mappings at
  -- https://github.com/mfussenegger/nvim-dap-python?tab=readme-ov-file#mappings
  dependencies = {
    "mfussenegger/nvim-dap",
  },
},
```

### Rust

<https://github.com/mrcjkb/rustaceanvim> has lot of features, almost all of
which I haven't explored.  Notably it configures LSP differently (I haven't
noticed the difference though), so if you're using
<https://github.com/neovim/nvim-lspconfig> to configure LSP servers, make sure
you remove `rust` from that list. The resulting DAP configuration allows you to
debug an individual test, which I found very useful.

All of the other plugins described in this post are lazy-loaded when a
keymapping activates the UI.  Because `rustaceanvim` reconfigures LSP I have it
configured to load whenever I edit Rust, and it depends on `nvim-dap` so that's
loaded too, but there's no real downside to that.

```lua
return {
  {
    -- Automatically sets up LSP, so lsp.lua doesn't include rust.
    -- Makes debugging work seamlessly.
    "mrcjkb/rustaceanvim",
    version = '^5', -- Recommended by module.
    ft = "rust",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
  },
}
```

## Setting up a UI

The configuration thus far gives you the ability to run a debugger, but it's
very awkward to see the debugging information or interact with the debugger.  To
address this need I'm using two plugins:

- <https://github.com/theHamsta/nvim-dap-virtual-text> uses virtual text to
  display the value of each local variable beside its declaration.  There are
  screenshots on Github showing how it works and the various options you can
  configure.

  ```lua
  {
    "theHamsta/nvim-dap-virtual-text",
    config = true,
    dependencies = {
      "mfussenegger/nvim-dap",
    },
  },
  ```

- <https://github.com/rcarriga/nvim-dap-ui> provides a full UI, similar to an
  IDE.  I've configured a keymapping to display the UI, and because the UI
  depends on all the other plugins (except `rustaceanvim`) they will all be
  loaded.  Again, there are screenshots and docs on Github to look at.

  ```lua
  {
    "rcarriga/nvim-dap-ui",
    config = true,
    keys = {
      {
        "<leader>du",
        function()
          require("dapui").toggle({})
        end,
        desc = "Dap UI"
      },
    },
    dependencies = {
        "jay-babu/mason-nvim-dap.nvim",
        "leoluz/nvim-dap-go",
        "mfussenegger/nvim-dap-python",
        "nvim-neotest/nvim-nio",
        "theHamsta/nvim-dap-virtual-text",
    },
  }
  ```

## My complete config for reference

<https://github.com/tobinjt/dotfiles/blob/master/.config/nvim/lua/plugins/debugging.lua>
You'll notice that most of the plugins are nested as dependencies of
`nvim-dap-ui`; this doesn't cause any change in functionality, I just prefer
this structure because it's clear that the plugins are only used there.

<https://github.com/tobinjt/dotfiles/blob/master/.config/nvim/lua/plugins/rust.lua>
contains the `rustaceanvim` config.

## Debugging the debugger

In my limited experience the biggest problem getting `nvim-dap` working is not
configuring it properly for the current filetype.  Here are some things to check
when debugging (assuming you're using the config I've described):

```vim
" Load all the plugins and display the UI.  Do you see the UI?
:lua require("dapui").open()
" Open Lazy and check whether the expected plugins are loaded?
:Lazy
" Print the configuration for Python.  If this is empty, focus on changing the
" configuration of nvim-dap-python until you see entries here.
:lua vim.print(require('dap').configurations.python)
" Print the configuration for the current filetype.  If this is empty, there is
" most likely something wrong with the configuration of mason-nvim-dap.nvim.
" Make sure you check the filetype is included in the list of supported debug
" adaptors at
" https://github.com/jay-babu/mason-nvim-dap.nvim/blob/main/lua/mason-nvim-dap/mappings/filetypes.lua
:lua vim.print(require('dap').configurations[vim.bo.filetype])
```

## Using the debugger

This is a **very** brief introduction:

```vim
" Load all the plugins and display the UI.
:lua require("dapui").open()
" Navigate to where you want to place a breakpoint, then set the breakpoint
" with:
:lua require("dap").set_breakpoint()
" Start the program and run until the breakpoint is hit.  Some filetypes have
" many options for running the program, and in that case a menu will be
" displayed for you to choose from.
:lua require("dap").continue()
" Fingers crossed the debugger has stopped the program at your checkpoint!
" You should see information in many of the UI windows, and values displayed
" beside variables in your source code.

" Navigate to the window named `dap-repl-<NUMBER>`, this is where you will enter
" commands to control the debugger.  Enter insert mode and you'll see a `dap> `
" prompt.  Enter `.help` to show a list of commands - I haven't found another
" reference for the commands :(  Continue debugging like you would in GDB or
" dlv.
```
