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

