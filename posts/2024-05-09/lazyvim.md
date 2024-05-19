# [2024-05-09] 🚀 LunarVim -> LazyVim

I use [Neovim](https://neovim.io/) as my IDE for a long time, mainly for Rust, Python, C, Go, Lua and the usual markup languages and configuration management such has YAML, JSON, Toml and Mardown.

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

