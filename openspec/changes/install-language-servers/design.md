## Context

`lua/config/lsp.lua:48-55` enables both servers through the native API:

```lua
-- F# LSP (requires: dotnet tool install -g fsautocomplete)
vim.lsp.config("fsautocomplete", { on_attach = on_attach, capabilities = capabilities })
vim.lsp.enable("fsautocomplete")

-- Markdown LSP (requires: marksman on $PATH)
vim.lsp.config("marksman", { on_attach = on_attach, capabilities = capabilities })
vim.lsp.enable("marksman")
```

`vim.lsp.enable` does not verify the binary exists. When it is missing nothing starts, nothing is logged, and the buffer simply has no client — indistinguishable from a server that attached and had nothing to say. That is why this went unnoticed long enough for the docs to drift.

The install instructions had drifted in opposite directions. `setup.adoc:146` already carried the correct `dotnet tool install -g fsautocomplete`; two other pages carried `sudo apt install marksman`, which cannot work — the package does not exist in the configured repos.

## Goals / Non-Goals

**Goals:**

- Both servers installed, attaching, and documented with commands that actually run.
- The capabilities each server provides recorded from measurement, not from its README.
- Every spec statement that was true only because the servers were missing, found and corrected.

**Non-Goals:**

- Closing the wider F# gap. F# still has no indent support of any kind — no `indent/fsharp.vim`, no `ftplugin/fsharp.vim`, no `indents.scm` — so a newline after `| Circle r ->` copies the previous indent instead of indenting the body. Fixing that means adopting `ionide/Ionide-vim` for its `indent/fsharp.vim`, which bundles its own LSP integration and would have to be reconciled with `fsautocomplete` rather than added alongside it. That is a plugin decision, not configuration, and belongs in its own change.
- Pinning or automating server updates. Both are manually installed, like every other language server here.
- Containerising the servers. Language servers are the deliberate exception to keeping dependencies in Docker: they are editor subprocesses speaking stdio with direct filesystem access, and containerising them fights the design.

## Decisions

### D1 — Install each server the way its ecosystem expects

| Server | Method | Version | Location | Matches |
|---|---|---|---|---|
| `marksman` | GitHub release asset `marksman-linux-x64` | `2026-02-08` | `~/.local/bin/marksman` | `lua-language-server` |
| `fsautocomplete` | `dotnet tool install -g fsautocomplete` | `0.83.0` | `~/.dotnet/tools/fsautocomplete` | `csharpier`, `csharprepl`, `dotnet-ef`, `dotnet-script`, `easydotnet` |

Both directories are already on `$PATH`. Neither install introduces a new PATH entry, a new package manager, or a service.

The marksman release publishes no checksum file alongside its binaries, so the download cannot be verified against a published digest. Recording the one observed instead, so a future re-install can at least be compared against this one:

```
be5098e8213219269c47fc0d916a66fa31ce0602ec967475c722260aabf26087  marksman-linux-x64
```

### D2 — marksman supplies no folding ranges, so the markdown fold decision stands

The question this change was expected to reopen: `code-folding` gives markdown `{ "treesitter", "indent" }` and justifies omitting the LSP slot on the grounds that no markdown server is installed. That justification expires here.

Measured against the running server rather than assumed:

| Capability | `marksman` | `fsautocomplete` |
|---|---|---|
| `foldingRangeProvider` | **absent** | **true** |
| `hoverProvider` | true | true |
| `definitionProvider` | true | true |
| `referencesProvider` | true | true |
| `renameProvider` | true | true |
| `completionProvider` | true | true |
| `documentSymbolProvider` | true | true |
| `documentFormattingProvider` | **absent** | **true** |
| `signatureHelpProvider` | absent | true |
| `codeActionProvider` | true | true |

So markdown keeps `{ "treesitter", "indent" }`. The LSP slot would be genuinely dead weight, and with only two slots (`ufo/fold/manager.lua:110-121`) it would displace the indent fallback that list folding depends on. The decision is unchanged; only the reason is, and the reason is the part a future reader would act on.

The same table settles a second question without a code change: marksman advertises no `documentFormattingProvider`, so no markdown formatting appears and nothing in `conform.lua` needs revisiting.

### D3 — F# gains formatting and folding with no edit, which is the risk worth testing

`fsautocomplete` advertises both `documentFormattingProvider` and `foldingRangeProvider`. Two pieces of configuration that were already present and inert therefore start working:

- `lua/plugins/conform.lua:10` — `fsharp = { lsp_format = "prefer" }`. Format-on-save begins reformatting `.fs` files on write.
- `lua/plugins/ufo.lua` — F# has no `folds.scm`, so the generic path already returns `{ "lsp", "indent" }`. The first slot stops being dead.

Neither is a code change, which makes them easy to miss and the reason both get explicit validation cases. Format-on-save is the one to watch: it is silent, it fires on every write, and if `fsautocomplete`'s formatter misbehaves it will rewrite the buffer before anyone notices it is active.

`fsautocomplete` attached to a loose `testdocs/hello.fs` with no project file, so basic features do not require a `.fsproj`. `testdocs/fsharp-project/` exists for the project-scoped checks.

### D4 — Two new capability specs, mirroring `lua-lsp`

Markdown and F# LSP support have never had specs; only `lua-lsp` does. Rather than invent a new shape, `markdown-lsp` and `fsharp-lsp` mirror it: the server is registered through the native API with the shared `on_attach`, keymaps match every other language, and a missing binary degrades silently rather than erroring.

Each also records what the server does *not* provide, since that is what this change had to measure and what the next person would otherwise re-measure.

`docs-language-setup` gets no delta. It already requires an install command per language; the documentation simply violated it. Fixing the pages satisfies the existing requirement rather than changing it.

## Risks / Trade-offs

- **F# format-on-save arrives unannounced.** Nobody edited a formatter config, but `.fs` files will be reformatted on write from now on. If the result is unwelcome the fix is to drop `fsharp` from `conform.lua`, but it should be a deliberate call rather than a surprise — hence the validation case.
- **Two more long-running subprocesses.** `fsautocomplete` in particular is a .NET process and not cheap. Only started for the relevant filetypes.
- **Manual updates.** Neither server auto-updates. `marksman` has no checksum published to verify future downloads against; the current digest is recorded above as the only available reference point.
- **The `code-folding` Purpose was already stale before this change touched it.** Corrected here because this change is modifying that spec anyway, but it is a symptom of a broader problem — fourteen other capabilities carry placeholder Purposes, and `openspec archive` will never fix any of them.
