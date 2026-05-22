## ADDED Requirements

### Requirement: lua_ls is configured as the Lua LSP server
The config SHALL register `lua_ls` via `lspconfig.lua_ls.setup{}` using the shared `on_attach` function defined in `lua/config/lsp.lua`, providing diagnostics, hover documentation, go-to-definition, references, rename, and code actions in Lua buffers.

#### Scenario: LSP attaches on Lua buffer open
- **WHEN** the user opens a `.lua` file and `lua-language-server` is on `$PATH`
- **THEN** `lua_ls` attaches to the buffer and LSP keymaps (`gd`, `K`, `gr`, `<leader>rn`, `<leader>ca`, `<leader>e`, `[d`, `]d`) are active

#### Scenario: LSP keymaps match other languages
- **WHEN** `lua_ls` attaches to a Lua buffer
- **THEN** all keymaps are identical to those registered by the shared `on_attach` function used for `fsautocomplete`, `marksman`, and `cl_lsp`

#### Scenario: Missing binary does not crash
- **WHEN** `lua-language-server` is not installed or not on `$PATH`
- **THEN** Neovim starts without error and no LSP attaches to Lua buffers
