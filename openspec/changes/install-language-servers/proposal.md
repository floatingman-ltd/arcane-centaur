## Why

`lua/config/lsp.lua` calls `vim.lsp.enable` for `marksman` (markdown) and `fsautocomplete` (F#), but neither binary was on `$PATH`. `vim.lsp.enable` fails silently when the server is absent, so both filetypes simply had no LSP — no hover, references, rename, diagnostics, document symbols or real completion — with nothing in `:messages` to say why.

The documentation made it worse rather than surfacing it. Two pages instruct `sudo apt install marksman`, a package that does not exist in the configured repos (`apt-cache policy marksman` returns nothing), so following the instruction produces "unable to locate package". A third lists marksman with a ✅, implying it is active.

F# is the bigger loser. Two features were already wired up and inert for want of the binary: `lua/plugins/conform.lua:10` sets `fsharp = { lsp_format = "prefer" }`, and ufo's generic provider path returns `{ "lsp", "indent" }` for F# because it has no `folds.scm`. Both start working the moment the server exists, with no code change.

## What Changes

- Install `marksman` from its GitHub release binary into `~/.local/bin`, matching how `lua-language-server` is installed here.
- Install `fsautocomplete` via `dotnet tool install -g`, matching the five global dotnet tools already on this machine and the command `setup.adoc:146` already documents.
- Correct the two `sudo apt install marksman` instructions and the unqualified ✅, and add a Markdown row to the Language Setup matrix, which already carries `fsautocomplete` correctly but omits `marksman` entirely.
  - **Not** the getting-started prerequisite table, as `recommendations/ideas.md` proposed. The `docs-getting-started` spec keeps language-specific prerequisites out of that page deliberately; the comparison the entry drew to the ripgrep/fzf gap does not hold, since those are editor-wide and these are per-language.
- Record what each server actually provides, measured rather than assumed. **`marksman` does not advertise `foldingRangeProvider`**, so the markdown fold decision is unchanged — but the reason recorded in the `code-folding` spec ("no markdown language server is currently installed") is now wrong and must be replaced.
- Update the stale comment in `lua/plugins/ufo.lua` that says marksman is "configured but absent".
- Correct the `code-folding` Purpose, which still claims "treesitter folding is deliberately disabled; markdown uses indent only" — overturned by `align-treesitter-providers` and already contradicted by line 48 of its own spec.

## Capabilities

### New Capabilities

- `markdown-lsp`: markdown LSP support via `marksman` — what it provides, and the fact that it supplies no folding ranges.
- `fsharp-lsp`: F# LSP support via `fsautocomplete`, including the formatting and folding behaviour that becomes live once it is installed.

### Modified Capabilities

- `docs-language-setup`: the setup matrix SHALL cover every language with a configured language server, Markdown included, and SHALL NOT publish an install command that cannot run.
- `code-folding`: the markdown requirement's justification changes from "no server is installed" to "the installed server supplies no folding ranges", and F# gains genuine LSP-supplied folds through the existing generic path.

## Impact

- No runtime Lua behaviour changes. Two binaries appear on `$PATH`; the config already referenced both.
- `after/ftplugin/fsharp.lua` and `lua/plugins/conform.lua` gain working format-on-save for F# — a real behavioural change for anyone editing `.fs`, arriving without an edit.
- F# buffers gain LSP folds via the existing `{ "lsp", "indent" }` path.
- `lua/plugins/ufo.lua` — comment only.
- Documentation: `editor/code-intelligence.adoc`, `content/diagrams.adoc`, `other/architecture.adoc`, `getting-started.adoc`.
- `openspec/specs/code-folding/spec.md` — one modified requirement plus a hand-corrected Purpose.
