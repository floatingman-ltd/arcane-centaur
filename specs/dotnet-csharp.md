# Proposal: .NET / C# Editing Support

## Summary

Add full C# editing support to the Neovim config, complementing the existing F# setup.
This covers syntax highlighting, LSP, formatting, a REPL, and filetype settings.
F# and C# REPL configuration will be consolidated into a single `dotnet.lua` plugin file.

---

## Capabilities

| Capability | Tool | Notes |
|---|---|---|
| Syntax highlighting + indentation | Treesitter `c_sharp` parser | Already supported by nvim-treesitter |
| LSP (go-to-def, hover, refs, rename, diagnostics) | `csharp_ls` | `dotnet tool install -g csharp-ls` |
| Format-on-save + `<leader>f` | conform.nvim + CSharpier | `dotnet tool install -g csharpier` |
| C# REPL (send line / selection / file) | iron.nvim + `csharprepl` | `dotnet tool install -g csharprepl` |
| Filetype settings | `after/ftplugin/cs.lua` | indent, localleader, REPL keymaps |

---

## Implementation Plan

### Files to Create
- `lua/plugins/dotnet.lua` — iron.nvim config covering both `cs` and `fsharp`
- `after/ftplugin/cs.lua` — C# indent settings, localleader, REPL keymaps
- `docs/guides/dotnet.md` — usage guide (prerequisites, LSP setup, REPL workflow)
- `docs/cheatsheets/dotnet.md` — keybinding reference

### Files to Modify
- `lua/plugins/treesitter.lua` — add `c_sharp` to `ensure_installed`
- `lua/config/lsp.lua` — add `vim.lsp.enable("csharp_ls")`
- `lua/plugins/conform.lua` — add `cs` → `csharpier` to `formatters_by_ft`
- `lua/plugins/init.lua` — replace `fsharp` import with `dotnet`
- `readme.md` — Supported Languages table, LSP Support, Plugin Overview

### Files to Remove
- `lua/plugins/fsharp.lua` — iron.nvim F# config moves into `dotnet.lua`

---

## Key Decisions

**LSP: `csharp_ls` over OmniSharp**
`csharp_ls` is a lightweight pure-.NET language server installable with a single `dotnet tool install` command. Full OmniSharp/Roslyn is more capable but significantly heavier. `csharp_ls` will be the default; OmniSharp documented as an alternative in the guide.

**Formatter: CSharpier**
Opinionated, fast, zero-config. Consistent with the existing approach for other languages (e.g., F# uses `fantomas` with no project-level config required).

**REPL: csharprepl**
Provides an interactive C# REPL with syntax highlighting and IntelliSense. Integrates cleanly with iron.nvim's `repl_definition`.

**Consolidate into `dotnet.lua`**
F# iron.nvim config currently lives in `lua/plugins/fsharp.lua`. Moving it alongside the new C# REPL config into `lua/plugins/dotnet.lua` keeps all .NET REPL configuration co-located and consistent.

---

## Prerequisites (user-installed)

```sh
dotnet tool install -g csharp-ls
dotnet tool install -g csharpier
dotnet tool install -g csharprepl
```
