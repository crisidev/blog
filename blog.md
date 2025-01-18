# Suspend Sedation on Linux

| :exclamation:  This post starts as a rant, but ends with some hope.. Bear with me :)   |
|----------------------------------------------------------------------------------------|

I remember the good old days, in 2004 (or maybe 2025?).. My laptop was an iBook G4 running Debian GNU/Linux
and I could put that thing in suspend to RAM and it would last around a month.

Today, in 2025, the current situation around suspend to RAM on Linux is ridiculous.

I have two laptops I use regularly, a Lenovo Carbon X1 Gen 10 for personal use and a Dell Latitude 5490 for
work, both running a recent version on Ubuntu. And the both sucks in terms of power management, battery time
and suspend to RAM.

## The suspend to RAM dilemma

Let's start with the Lenovo. My Carbon X1 supports proper S3 suspend, which is basically the suspend to RAM level
where everything apart from the memory banks is powered off. This should give days, if not weeks of suspend time.

The problem? After going to S3, the laptop never comes back. I had, as many other Lenovo Linux users, to select
s2idle in the BIOS, meaning the RAM doesn't go into the lower power mode and the NVME is kept powered on.

The result, is a couple of days of suspend time and if the battery runs off during suspend, most of the time my
LUKS partition gets corrupted and I have to recover it manually during the next boot. Fun, ha? 🤮

With the Dell, the problem is very similar. Dell decided to rip the S3 support from their BIOS and bend over to
mother Microsoft so that Windows can wake the laptop up when it wants and do things you probably really don't want
it to do. Fun again, ha? 🤮

So, it's the same story as the Lenovo, if the battery runs out during, suspend, the LUKS partition will get corrupted,
yadda, yadda, yadda.

**I had to do something!**

## Suspend sedation to the rescue

The Debian wiki has a nice article about a technique called *suspend sedation*: https://wiki.debian.org/SystemdSuspendSedation.

The gist is that we can use a watchdog time to wake up the laptop from s2idle and do something to mitigate this shit show.

If you are lucky and you can use hibernate, the Debian wiki covers how to hibernate your laptop from suspend after certain time.

If you, like me, want (or are forced) to use secure boot, and cannot make your laptop go into hibernate, I crafted a poor man solution
to the issue.

I crated a Systemd suspend sedation service that wakes up the laptop every two hours, check if the battery is less than a certain
threshold and, if it is, cleanly shuts down your laptop, preventing the nasty corruption I experienced many times.

**I know, it's sad, but man, when the world gives you lemon, you do something, right 🍋?**

```systemd
❯❯❯ cat /etc/systemd/system/suspend-sedation.service
[Unit]
Description=Wake up periodically and check battery status

[Service]
Type=oneshot
RemainAfterExit=yes
Environment="ALARM_SEC=7200"
Environment="WAKEALARM=/sys/class/rtc/rtc0/wakealarm"
Environment="POWEROFF_LEVEL=10"

ExecStart=/usr/sbin/rtcwake --seconds $ALARM_SEC --auto --mode no
ExecStop=/bin/sh -c '\
  ALARM=$(cat $WAKEALARM); \
  NOW=$(date +%%s); \
  if [ -z "$ALARM" ] || [ "$NOW" -ge "$ALARM" ]; then \
    echo "suspend-sedation: Woke up without alarm set. Checking battery..."; \
    BATTERY_LEVEL=$(cat /sys/class/power_supply/BAT0/capacity); \
    if [ "$BATTERY_LEVEL" -lt "$POWEROFF_LEVEL" ]; then \
      echo "suspend-sedation: Battery level is $BATTERY_LEVEL% (< $POWEROFF_LEVEL%). Shutting down..."; \
      sleep 5; \
      /usr/bin/systemctl poweroff; \
      sync; \
    else \
      echo "suspend-sedation: Battery level is $BATTERY_LEVEL% (> $POWEROFF_LEVEL%). Suspending again..."; \
      sleep 5; \
      /usr/bin/systemctl suspend; \
    fi; \
  else \
    echo "suspend-sedation: Normal wake up before alarm. Nothing to do..."; \
    /usr/sbin/rtcwake --auto --mode disable; \
  fi \
'

[Install]
WantedBy=sleep.target
```

I hope this can help someone else 😁. You can change the environment variables to tune this taking in account your preferences.

Since I'll probably end up tuning this service, here is the source where you'll be able to find the update version: [suspend-sedation.service](https://github.com/crisidev/dotfiles/blob/main/system/etc/systemd/system/suspend-sedation.service).

Happy powersave everyone 💻.
# [2025-01-03] 🐽 bacon-ls - a lot of new features
It's been a while since I have written here and I am happy to announce a lot of new nice features that I baked in `bacon-ls`.

There features are available with [version 0.8.0](https://crates.io/crates/bacon-ls) of `bacon-ls` and requires `bacon` at
least at [version 3.7.0](https://crates.io/crates/bacon). This new version of `bacon` adds some amazing support at parsing
the JSON that can be produced by `cargo` when running with the option `--message-format json-diagnostic-rendered-ansi`.

Directly parsing this format allows for very precise span locations and direct access to `cargo` and `clippy` suggestions.

## New features 

* **Precise diagnostics positions**: since spans are precisely gathered from `cargo`, now the diagnostics locations are 
  only applied to right portion of text.
* **Code actions**: Replacement and quick fix code actions are now exposed by `bacon-ls` to the LSP client, allowing
  for refactoring similar to the one available on `rust-analyzer`.
* **VsCode extensions**: extensions for [Visual Studio Code](https://code.visualstudio.com/) and derivatives are
  now published on the [VSCode Marketplace](https://marketplace.visualstudio.com/items?itemName=MatteoBigoi.bacon-ls-vscode)
  and on the [Open VSX Registry](https://open-vsx.org/extension/MatteoBigoi/bacon-ls-vscode)

**Please take a moment to read `bacon-ls` [README](https://github.com/crisidev/bacon-ls/blob/main/README.md) as the `bacon`
location configuration has changed and must be updated to work properly.**

Happy diagnostics 🦀!

# [2024-05-20] 🐽 bacon-ls - LSP in Rust
What is the experience of building a Language Server in Rust 🦀 you ask?
Without any prior knowledge of the protocol?

Well, it not bad.. It requires basic familiarity with the [tokio](https://docs.rs/crate/tokio/) 
asynchronous ecosystem and with Rust async in general, but you can get 
something done in a couple of days of work.

`bacon-ls` depends on [tower-lsp](https://docs.rs/crate/tower-lsp/) for the 
STDIN/STDOUT/HTTP communication and on [tokio](https://docs.rs/crate/tokio/)
for the asynchronous runtime and the foundational LSP types are provided by
[lsp-types](https://docs.rs/crate/lsp-types).

[Bacon](https://dystroy.org/bacon/) writes a file with a diagnostic per line
and `bacon-ls` requires a specific format that can be parsed:

```bash
line_format = "{kind}:{path}:{line}:{column}:{message}{context}"
```

Since [Bacon](https://dystroy.org/bacon/) supports (from [#5d95852](https://github.com/Canop/bacon/commit/5d958528a19cb3ec3b8129df7f0364bb0716932c)) 
the message `{context}`, any other line captured in relation to the current 
diagnostic, `bacon-ls` can emit the whole diagnostic, including hints from
clippy and cargo.

## Diagnostics and Language Servers
Language clients can request [textDocument/diagnostic](https://microsoft.github.io/language-server-protocol/specification#textDocument_diagnostic) and [workspace/diagnostic](https://microsoft.github.io/language-server-protocol/specification#workspace_diagnostic) capabilities, expecting the list of diagnostics for the current
file or for the whole workspace. The diagnostic carries metadata, such has
the `line:column` of the diagnostic, URL, message and so on..

I think you see where this is going..

`bacon-ls` reads [Bacon](https://dystroy.org/bacon/) diagnostics and exposes
them on the LSP interface to clients requesting it 🚀!

## Some some Rust please

`tower-lsp` is implemented more or less how you would expect it. It exports a 
[LanguageServer](https://docs.rs/tower-lsp/latest/tower_lsp/trait.LanguageServer.html)
trait the user can implement to expose the capabilities for their use-case.

For `bacon-ls`, we only need to implement 3 methods:

- Initialize the LSP server
- Implement [textDocument/diagnostic](https://microsoft.github.io/language-server-protocol/specification#textDocument_diagnostic)
- Implement [workspace/diagnostic](https://microsoft.github.io/language-server-protocol/specification#workspace_diagnostic)
### Initialize the LSP server

The LSP server must be initialized so that it can returns the list of available
capabilities to clients.

[![initialize](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-20/initialize.png)](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-20/initialize.png)

### Fetch diagnostic from Bacon

All the rest of the LSP server implementation is using this function to fetch them
diagnostics from Bacon. 

[![bacon-diagnostic](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-20/bacon-diagnostic.png)](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-20/bacon-diagnostic.png)

### Implement textDocument/diagnostic

This method is what is being called by the LSP client when it wants to retrieve the current
document diagnostic.

[![document-diagnostic](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-20/document-diagnostic.png)](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-20/document-diagnostic.png)

### Implement workspace/diagnostic


This method is what is being called by the LSP client when it wants to retrieve the whole
workspace diagnostic.

[![workspace-diagnostic](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-20/workspace-diagnostic.png)](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-20/workspace-diagnostic.png)

### Tower service

The LSP server is implemented as a [Tower](https://docs.rs/tower/latest/tower/) service and only requires a structure implementing the [LanguageServer](https://docs.rs/tower-lsp/latest/tower_lsp/trait.LanguageServer.html). Tower will take care of the LSP server process lifecycle, clients handling and so on.


[![tower-service](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-20/tower-service.png)](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-20/tower-service.png)

## Done 🚀

I was not expecting this do be so easy and well integrated with Rust!
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

**The look and feel is GREAT!**

[Alpha](), the startup / welcome dashboard with recent files, quick actions and sessions and a cool banner 🤩

[![alpha](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-09/alpha.png)](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-09/alpha.png)

Developing in Rust with files and tests panels and LSP completion

[![rust](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-09/rust.png)](https://raw.githubusercontent.com/crisidev/blog/main/posts/2024-05-09/rust.png)

All the my configuration is open source and you can take what you need from it on [Github](https://github.com/crisidev/lazyvim)!

# blog-text-art-banner

 ██████╗██████╗ ██╗███████╗██╗██████╗ ███████╗██╗   ██╗
██╔════╝██╔══██╗██║██╔════╝██║██╔══██╗██╔════╝██║   ██║
██║     ██████╔╝██║███████╗██║██║  ██║█████╗  ██║   ██║
██║     ██╔══██╗██║╚════██║██║██║  ██║██╔══╝  ╚██╗ ██╔╝
╚██████╗██║  ██║██║███████║██║██████╔╝███████╗ ╚████╔╝ 

# blog-about

Hello there 👋, I'm [@crisidev](/crisidev). 

[![crisidev](https://raw.githubusercontent.com/crisidev/blog/main/posts/photo.png)](https://lmno.lol/crisidev)

I serialize thoughts and ideas into ELF binaries, mainly in 🦀.
### Links

- 💻 Github - [@crisidev](https://github.com/crisidev)
- 🌎 Mastodon - [@crisidev](https://hachyderm.io/@crisidev)
- 💁 LinkedIn - [matteobigoi](https://www.linkedin.com/in/matteobigoi/)
- 📧 Email - bigo **at** crisidev **dot** org

