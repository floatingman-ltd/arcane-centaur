## Why

Lua is the primary configuration language for Neovim, and users who extend this config or develop plugins in Lua have no language-server support, no format-on-save, and no filetype-specific editor settings. Adding first-class Lua support closes this gap for the most common editing language in the repo.

## What Changes

- Add `lua_ls` (lua-language-server) LSP configuration in `lua/config/lsp.lua`
- Add `stylua` as the formatter for Lua in `lua/plugins/conform.lua`, with format-on-save
- Add `after/ftplugin/lua.lua` with indent settings (2-space) and localleader keymaps

## Capabilities

### New Capabilities

- `lua-lsp`: Language server support for Lua via `lua_ls`, providing diagnostics, hover docs, go-to-definition, and rename
- `lua-formatting`: Format-on-save for Lua files using `stylua` via conform.nvim
- `lua-ftplugin`: Filetype settings for Lua — 2-space indentation and any Lua-specific keymaps

### Modified Capabilities

<!-- No existing specs require changes -->

## Impact

- `lua/config/lsp.lua`: new `lspconfig.lua_ls.setup{}` call
- `lua/plugins/conform.lua`: add `lua` to `formatters_by_ft` and `ft` list; add `stylua` formatter
- `after/ftplugin/lua.lua`: new file for filetype-local settings
- External prerequisite: `lua-language-server` binary must be on `$PATH`; `stylua` binary must be on `$PATH`
- No breaking changes; additive only
