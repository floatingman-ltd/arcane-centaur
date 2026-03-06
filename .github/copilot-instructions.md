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
