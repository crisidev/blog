# [2024-05-17] 🐽 Bacon Language Server
If you, like, me, spend a lot of my development time doing Rust 🦀 inside Neovim and is not 
satisfied by [rust-analyzer](https://rust-analyzer.github.io/) performance with medium to 
large sized repositories, you are in the right place 🤩.

Disabling `rust-analyzer.diagnostic` and `rust-analyzer.checkOnSave`, the experience becomes
much more snappy, but we loose LSP diagnostics. Here comes [Bacon](https://dystroy.org/bacon/)
to the rescue.. Bacon is a wrapper around `cargo` that watches the crate we 
are developing, runs the target command (build, test, clippy, etc..) when there are changes
and reports the diagnostics in a structured view in the `bacon` TUI. This little tool is also 
able to keep the `cargo` diagnostics up to date in a file and in a format we can parse.

## 🐽 bacon-ls

[bacon-ls](https://github.com/crisidev/bacon-ls) is the companion to Bacon, reading the diagnostics 
from the Bacon export file and exposing them via the Language Server Protocol over standard input.

### So how does developing with `bacon-ls` looks like?


First of all, `bacon` and `bacon-ls` must be installed on the system:

```bash
❯❯❯ cargo install --locked bacon bacon-ls
```

We need to disable a couple of rules in `rust-analyzer` configuration.
Depending on your editor, the instructions could differ, but for Neovim LSP, it is 
roughly like this:

```lua
default_settings = {
    ["rust-analyzer"] = { 
        diagnostics = { enable = false },
        checkOnSave = { enable = false },
    }
}
```

`bacon-ls` needs to be added to the available servers for [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig/).
Unfortunately this is still manual, but I am slowly adding the support upstream:

- ✅ [#3160](https://github.com/neovim/nvim-lspconfig/pull/3160) Add `bacon-ls` to nvim-lspconfig 
- 🕖 [#5774](https://github.com/mason-org/mason-registry/pull/5774) Add `bacon-ls` to mason-nvim 
- 🕖 [#186](https://github.com/Canop/bacon/pull/187)  Include compiler hints in [Bacon](https://dystroy.org/bacon/) locations 
- 🕖 [#3132](https://github.com/LazyVim/LazyVim/pull/3212) Add `bacon-ls` to LazyVim [Rust extras](https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/extras/lang/rust.lua)

```lua
local configs = require("lspconfig.configs")
if not configs.bacon_ls then
    configs.bacon_ls = {
        default_config = {
            cmd = { "bacon-ls" },
            root_dir = require("lspconfig").util.root_pattern(".git"),
            filetypes = { "rust" },
        },
    }
end
lspconfig.bacon_ls.setup({ autostart = true })
```

And now you are ready to go!

Neovim should look like this:

[![neovim bacon img](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-17/screenshot.png)](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-17/screenshot.png)

If you like the look and feel, you can check my Neovim [configurations](https://github.com/crisidev/lazyvim) 
and this [blog post](https://lmno.lol/crisidev/lunarvim-lazyvim) 😀.

### Live diagnostics

With a properly configured client, the experience is pretty snappy. I keep `nvim-lspconfig`
setting `update_in_insert = true` for very smooth diagnostic icons transitions.

[![neovim bacon gif](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-17/bacon-ls.gif)](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-17/bacon-ls.gif)

If you are interested in how the LSP server is designed and implemented, I'll shortly release 
a new post about it!

`bacon-ls` is open source and can be found on [Github](https://github.com/crisidev/bacon-ls).

