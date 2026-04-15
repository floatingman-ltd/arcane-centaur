## 1. LSP Setup

- [ ] 1.1 Add `lspconfig.lua_ls.setup{ on_attach = on_attach }` to `lua/config/lsp.lua`
- [ ] 1.2 Verify `lua-language-server` is documented as a prerequisite in `docs/guides/lua.md` (create file if it doesn't exist)

## 2. Formatting

- [ ] 2.1 Add `"lua"` to the `ft` list in `lua/plugins/conform.lua` so conform lazy-loads for Lua
- [ ] 2.2 Add `lua = { "stylua" }` entry to `formatters_by_ft` in `lua/plugins/conform.lua`
- [ ] 2.3 Document `stylua` as a prerequisite in `docs/guides/lua.md`

## 3. Filetype Plugin

- [ ] 3.1 Create `after/ftplugin/lua.lua` with `shiftwidth=2`, `tabstop=2`, `softtabstop=2`, and `expandtab` set as buffer-local options

## 4. Documentation

- [ ] 4.1 Create `docs/guides/lua.md` covering prerequisites (`lua-language-server`, `stylua`), available features (LSP keymaps, format-on-save), and indent settings
- [ ] 4.2 Update `readme.md` Language Support table to reflect full Lua support (LSP + formatting)
- [ ] 4.3 Update `docs/cheatsheets/index.md` if a Lua cheatsheet is added

## 5. Validation

- [ ] 5.1 Syntax-check all modified Lua files with `luac -p` (or `:luafile %` in Neovim)
- [ ] 5.2 Open a `.lua` file in Neovim and confirm `lua_ls` attaches (`:LspInfo`)
- [ ] 5.3 Save a Lua file and confirm `stylua` formats it
- [ ] 5.4 Open a Lua buffer and confirm `shiftwidth` is 2 (`:set shiftwidth?`)
