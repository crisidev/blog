# [2024-05-18] 🌎 Uploading blog programmatically

I am a lazy person spending most of their time in a terminal 💻...

This is one of the reasons why [lmno.lol](https://lmno.lol) really suites me.. I update my 
markdown locally, drag it on the edit page, click save, boom, done 👈!

Since I don't want to move out of my terminal, I hacked a little script
using [curl](https://curl.se/) to upload my blog programmatically.

[lmno.lol](https://lmno.lol) is protected by a cookie based authentication
system. The first thing to do is to login with the username and password.
Luckily the login screen is a form I can submit with curl with roughly this
command:

[![login curl](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-18/login-curl.png)](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-18/login-curl.png)

After storing the cookie session key, we can now move to the next step, which
is uploading a new version of [lmno.lol/crisidev](https://lmno.lol/crisidev)! 

## Today I learned something wild!
I was inspecting the Firefox console during the blog upload phase, after clicking `save` on
`https://lmno.lol/crisidev/edit` and I found the API POST call to `https://lmno.lol/api`
that is responsible to update my blog.

I click on the request and 🔥

[![copy as curl](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-18/copy-as-curl.png)](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-18/copy-as-curl.png)

I am crying of joy.

## Update my blog

Mozilla produces a working `curl` command that I had to tweak a little to basically this:

[![api curl](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-18/api-curl.png)](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-18/api-curl.png)

Easy! 
## The result

[![script result](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-18/script-result.png)](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-18/script-result.png)

## Auto publish anyone? 🤩

The blog is a self-contained [Github repo](https://github.com/crisidev/blog) and is published
to [lmno.lol/crisidev](https://lmno.lol/crisidev) using a 
[Github action](https://github.com/crisidev/blog/blob/main/.github/workflows/publish.yml)
based on the learnings above so that every time I update it the repository and push on `main`, 
the CI kicks in and a new version is published automatically 🚀

## The code
Here is the full script, which is shared also as a [gist](https://gist.github.com/crisidev/658906ccd133ddb0083258771ffe17e9).

[![lmno blog upload script](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-18/script.png)](https://gist.github.com/crisidev/658906ccd133ddb0083258771ffe17e9)

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

# [2024-05-09] 🚀 LunarVim -> LazyVim

I use [Neovim](https://neovim.io/) as my IDE for a long time, mainly for Rust, Python, C, Go, Lua and the usual markup languages and configuration management such has YAML, JSON, Toml and Mardown.

Here is a loud Neovim logo to cheer you up on a rainy day 🌧️

                                             
      ████ ██████           █████      ██
     ███████████             █████ 
     █████████ ███████████████████ ███   ███████████
    █████████  ███    █████████████ █████ ██████████████
   █████████ ██████████ █████████ █████ █████ ████ █████
 ███████████ ███    ███ █████████ █████ █████ ████ █████
██████  █████████████████████ ████ █████ █████ ████ ██████

I all started by porting my incredibly old (10+ years) and complicated Vim configuration to Neovim, all implemented in vimscript. IT WAS A NIGHTMARE 🔥..

Later on I discovered you can configure Neovim using Lua and I fell in love with it.

I built a bloated and complex configuration in Lua, based on the [LunarVim](https://www.lunarvim.org/) distribution and inspired on the great work of [@abzcoding](https://github.com/abzcoding/lvim), piling up to a ton of code and customizations:

```sh
❯❯❯ ~/.homesick/repos/lvim/home/.config/lvim $ tokei .
===============================================================================
 Language            Files        Lines         Code     Comments       Blanks
===============================================================================
 JSON                    8          804          804            0            0
 Lua                    76         9900         8668          549          683
 TOML                    2           55           43            0           12
 Vim script             13          425          361           33           31
===============================================================================
 Total                  99        11184         9876          582          726
===============================================================================
```

Unfortunately LunarVim is [not being actively maintained](https://github.com/LunarVim/LunarVim/discussions/4518#discussioncomment-8963843) and I had several issues maintaining such a complex configuration, so I started looking at alternatives and into only implementing configurations and utilities for the functionalities I use daily.

I tried out [Astronvim](https://astronvim.com/), but it uses a lot of plugins I don't like for important functionalities such has UI and buffers.

This Github [issue](https://github.com/abzcoding/lvim/issues/145#issuecomment-2079957357) pointed me at [LazyVim](https://www.lazyvim.org/) and I fell in 💗 again: it is properly maintained by [@folke](https://github.com/folke), the author of many plugins I use and love and after a couple of evenings of work, I was able to port all my configuration to LazyVim and I now have a faster and more consistent experience in multiple languages.

On top of this, it's less code to maintain 🤩. It's still a lot, but what the heck, Neovim is what helps me pay the bills 💸!

```sh
❯❯❯ ~/.config/nvim $ tokei .
===============================================================================
 Language            Files        Lines         Code     Comments       Blanks
===============================================================================
 JSON                    7          892          892            0            0
 Lua                    48         3864         3516          136          212
 Markdown                1           24            0           16            8
 TOML                    1            3            3            0            0
===============================================================================
 Total                  57         4783         4411          152          220
===============================================================================
```

And the look and feel is GREAT!

[![rust](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-09/rust.png)](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-09/rust.png)

All the my configuration is open source and you can take what you need from it on [Github](https://github.com/crisidev/lazyvim)!

# blog-text-art-banner

 ██████ ██████  ██ ███████ ██ ██████  ███████ ██    ██ 
██      ██   ██ ██ ██      ██ ██   ██ ██      ██    ██ 
██      ██████  ██ ███████ ██ ██   ██ █████   ██    ██ 
██      ██   ██ ██      ██ ██ ██   ██ ██       ██  ██  
 ██████ ██   ██ ██ ███████ ██ ██████  ███████   ████  

# blog-about

Hello there 👋, I'm [@crisidev](/crisidev).

I serialize thoughts and ideas into ELF binaries, mainly in 🦀.

I can be found online here

- Github - [@crisidev](https://github,com/crisidev)
- Mastodon - [@crisidev](https://hachyderm.io/@crisidev)
- LinkedIn - [matteobigoi](https://www.linkedin.com/in/matteobigoi/)
- Email - bigo _at_ crisidev _dot_ org

