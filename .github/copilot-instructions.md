# arcane-centaur — Neovim Configuration

## Architecture

`init.lua` loads three modules in order: `options` → `loader` → `keymaps`.

- **`lua/loader/init.lua`** — bootstraps lazy.nvim and imports all plugin specs from `lua/plugins/`
- **`lua/config/`** — non-plugin configuration: `terminal.lua` (capability detection), `lsp.lua` (LSP server setup), `treesitter.lua`
- **`lua/plugins/`** — one file per plugin group, each returns a lazy.nvim spec table
- **`after/ftplugin/`** — filetype-specific overrides (indent settings, localleader, extra keymaps)

Plugin specs use lazy.nvim's `ft = { ... }` field for filetype-based lazy loading. All Lisp/Clojure/Scheme/Fennel plugins load only on those filetypes; F# and Haskell plugins do the same.

## Key Conventions

### Adding a plugin
Create a new file in `lua/plugins/` returning a lazy.nvim spec table, or add a bare string to `lua/plugins/init.lua` for plugins that need no configuration. The loader auto-imports everything in `lua/plugins/` via `{ import = "plugins" }`.

### Terminal capability flags
`lua/config/terminal.lua` exposes `term.has_nerd_font`, `term.has_undercurl`, and `term.name`. Require it early and branch on these flags — do not hardcode terminal-specific behavior elsewhere. GNOME Terminal (VTE) is the default; `vim.g.have_nerd_font` can be forced to `true` in `lua/options.lua` after installing a Nerd Font.

### localleader
All REPL and eval keymaps use `<localleader>` (`,`), set per-filetype in `after/ftplugin/`. Global keymaps use `<leader>` (Space), defined in `lua/keymaps.lua`.

### LSP
All LSP servers share the same `on_attach` function defined in `lua/config/lsp.lua`. Add new servers there with `lspconfig.<server>.setup{ on_attach = on_attach }`.

### Formatting
`lua/plugins/conform.lua` handles format-on-save for Lisp and F# filetypes via `lsp_format = "prefer"`. Add new filetypes to `formatters_by_ft` in that file.

### Colorscheme
TokyoNight "moon" variant. Change the `style` variable at the top of `lua/plugins/colorscheme.lua` to switch variants (`"moon"`, `"storm"`, `"night"`, `"day"`).

## Language Support Summary

| Language | Plugins | LSP | REPL |
|---|---|---|---|
| Common Lisp | Conjure, vim-sexp, parinfer, rainbow-delimiters | `cl_lsp` | Swank (port 4005) |
| Clojure / Scheme / Fennel | same as above | — | Conjure built-in |
| F# | iron.nvim | `fsautocomplete` | `dotnet fsi` |
| Haskell | haskell-tools | haskell-language-server | GHCi |
| Lua | treesitter only | — | — |

## Copilot Model
To change the Copilot model, edit the `config` function in `lua/plugins/copilot.lua` and set `vim.g.copilot_model` to the desired value (e.g. `"gpt-4o"`, `"gpt-4.1"`, `"claude-sonnet-4-5"`).

## Documentation Policy

**All non-documentation changes must also update the relevant documentation.** When adding or changing a plugin, keybinding, LSP server, filetype setting, or any other user-visible behaviour, update the matching docs:

| Change type | Files to update |
|---|---|
| New or changed plugin | `readme.md` (Plugin Overview + Project Structure tables), relevant `docs/guides/*.md`, relevant `docs/cheatsheets/*.md` |
| New or changed keybinding | `readme.md` (General Keybindings), `docs/cheatsheets/index.md`, the specific `docs/cheatsheets/<area>.md` |
| New language support | `readme.md` (Supported Languages table), new `docs/guides/<lang>.md`, new `docs/cheatsheets/<lang>.md` |
| New LSP server | `readme.md` (LSP Support), `docs/guides/<lang>.md` |
| New Docker service | `readme.md` (Working with … section), `docs/guides/<area>.md` |
| Terminal / font changes | `readme.md` (Terminal Auto-Detection table) |

`docs/cheatsheets/index.md` is the single-page keybinding reference. If a new cheatsheet file is added, add a row in its Plugin Cheatsheets table.

## Validation

This repository contains no traditional build system. Validate Lua changes with:

```sh
# Syntax-check all Lua files from the repo root (requires luac, e.g. lua5.4)
find . -name '*.lua' -print0 | xargs -0 luac -p
```

If `luac` is unavailable, use `lua -e 'loadfile("<file>")()'` per file, or open Neovim and run `:luafile %` / `:source %` to surface any runtime errors.

No CI pipelines are configured in this repository; validation is manual.
