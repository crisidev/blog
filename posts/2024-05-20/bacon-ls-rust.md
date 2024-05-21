# [2024-05-20] 🐽 `bacon-ls` - LSP in Rust
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
