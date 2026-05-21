## Context

Neovim has zero fold configuration today — no `foldmethod`, no `foldexpr`, no foldtext. The config ships treesitter (highlight + indent enabled) and Roslyn for C#, but neither contributes to folding without explicit setup. `nvim-ufo` is the standard plugin for annotated foldtext and multi-provider fold ranges; it works with Neovim ≥ 0.5 and integrates directly with treesitter and LSP.

Key constraint: `lua/config/lsp.lua` currently passes no `capabilities` to any server. nvim-ufo's LSP provider requires `textDocument.foldingRange` capabilities advertised at client startup, which means lsp.lua must be updated.

## Goals / Non-Goals

**Goals:**
- Annotated foldtext: `▸ function fetchUser() ··· 8 lines`
- Fold-on-demand: files always open fully expanded (`foldlevelstart = 99`)
- LSP-aware folds for C# (Roslyn `#region` / `#endregion`)
- Treesitter folds for all other languages (Lisp, Lua, F#, Haskell, Markdown)
- Indent fallback for any language without a treesitter grammar

**Non-Goals:**
- Auto-closing folds on file open
- Peek into folds (can be added later)
- which-key group registration for `z` keys (low value without peek)

## Decisions

### nvim-ufo over native treesitter foldexpr
Neovim 0.10+ ships `vim.treesitter.foldexpr()` natively. This gives structural folds for free — but with no foldtext customisation (just shows the raw first line). nvim-ufo adds the annotated foldtext (`▸ … ··· N lines`) and the LSP provider chain, both of which are required here.

**Alternatives considered:** native-only (`foldexpr = "v:lua.vim.treesitter.foldexpr()"`). Rejected — no annotated foldtext, no `#region` support.

### Provider chain: LSP → treesitter → indent
LSP first ensures Roslyn's precise C# ranges (including `#region`) are used when available. Treesitter covers Lua, Lisp, F#, Haskell, Markdown. Indent is the universal fallback.

**Alternatives considered:** treesitter-only (simpler, no lsp.lua changes). Rejected — C# `#region` blocks are only expressible via LSP fold ranges.

### Thread capabilities into lsp.lua via shared table
Build one `capabilities` table once in `lsp.lua` (merging cmp-nvim-lsp defaults + fold range support) and pass it to every `vim.lsp.config()` call. This is the cleanest single-place change and avoids per-server duplication.

```lua
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.foldingRange = {
  dynamicRegistration = false,
  lineFoldingOnly = true,
}
```

**Alternatives considered:** passing fold capabilities only to roslyn. Rejected — if other servers gain fold support later, they'd need manual updates. One shared table is zero extra cost.

### Add `c_sharp` to treesitter ensure_installed
Treesitter serves as the fallback provider even when LSP is primary. Having the `c_sharp` grammar installed ensures folds work immediately without waiting for Roslyn to attach (e.g., on first open before LSP is ready).

### keymaps: z-layer only, no leader shortcuts
Built-in `z` commands (`za`, `zc`, `zo`, `zR`, `zM`) cover all fold interactions. which-key now shows these on `z` pause. No custom leader shortcuts needed — they would duplicate built-ins with no discoverability gain.

## Risks / Trade-offs

- **roslyn.nvim capability merging**: roslyn.nvim manages its own LSP client startup. `vim.lsp.config("roslyn", { capabilities = ... })` should be picked up, but if roslyn.nvim overrides capabilities internally, fold ranges may not be advertised. → Mitigation: test `:lua print(vim.inspect(vim.lsp.get_clients({name="roslyn"})[1].server_capabilities.foldingRangeProvider))` after attach; fall back to treesitter-only if needed.
- **foldcolumn visual noise**: `foldcolumn = "1"` adds a thin gutter column. On narrow splits this can feel cramped. → Mitigation: set `foldcolumn = "1"` (auto-hides when no folds exist in view).
- **Performance on large files**: treesitter fold computation on very large files (10k+ lines) can be slow. → nvim-ufo uses debouncing internally; acceptable trade-off.

## Open Questions

- None. All design decisions made during exploration.
