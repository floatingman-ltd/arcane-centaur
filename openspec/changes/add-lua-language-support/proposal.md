## Why

Lua is the primary configuration language for this Neovim setup, yet it currently has no LSP, no formatter, and no filetype-specific editor settings. Adding first-class Lua support improves the experience of editing the config itself and any Lua scripts in the repo.

## What Changes

- Add `lua_ls` (lua-language-server) to `lua/config/lsp.lua` with Neovim-aware workspace library settings
- Add `stylua` formatter for Lua files in `lua/plugins/conform.lua`
- Add `after/ftplugin/lua.lua` for per-buffer indent and editor settings

## Capabilities

### New Capabilities

- `lua-lsp`: Configure `lua_ls` with `on_attach` and Neovim runtime library so go-to-definition, hover, rename, and diagnostics work in `.lua` files
- `lua-formatting`: Register `stylua` as the formatter for `ft=lua` in conform.nvim
- `lua-ftplugin`: Per-buffer filetype settings for Lua (indent width, `nospell`, etc.)

### Modified Capabilities

<!-- none -->

## Impact

- `lua/config/lsp.lua` — new server setup block
- `lua/plugins/conform.lua` — new `lua` entry in `formatters_by_ft`
- `after/ftplugin/lua.lua` — new file
- `readme.md` and docs — Language Support table updated; no new guide needed (Lua is the config language, not a project language)
- External dependency: `lua-language-server` binary must be on `$PATH` (installable via system package manager or Mason); `stylua` binary must be on `$PATH`
