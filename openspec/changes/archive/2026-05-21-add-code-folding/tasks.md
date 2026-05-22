## 1. Fold Options

- [x] 1.1 Add fold options to `lua/options.lua`

## 2. LSP Capabilities

- [x] 2.1 In `lua/config/lsp.lua`, build a shared `capabilities` table with fold range support
- [x] 2.2 Pass `capabilities` to all four `vim.lsp.config()` calls in `lua/config/lsp.lua`

## 3. Treesitter Grammar

- [x] 3.1 Add `"c_sharp"` to `ensure_installed` in `lua/plugins/treesitter.lua`

## 4. nvim-ufo Plugin

- [x] 4.1 Create `lua/plugins/ufo.lua` with `kevinhwang91/nvim-ufo` spec (requires `kevinhwang91/promise-async`)
- [x] 4.2 Configure provider chain `{ "lsp", "treesitter", "indent" }` in ufo setup
- [x] 4.3 Configure custom foldtext handler rendering `▸ <opening text> ··· N lines`

## 5. Keymaps

- [x] 5.1 Add `zR` / `zM` keymaps to `lua/keymaps.lua` (delegates to ufo)

## 6. Validation

- [x] 6.1 Syntax-check all modified Lua files
- [x] 6.2 Open a C# file with a `#region` block — confirm region is foldable (manual)
- [x] 6.3 Open a Lua file — confirm function bodies are foldable (manual)
- [x] 6.4 Confirm files open fully expanded (manual)
- [x] 6.5 Update `docs/modules/ROOT/pages/editor/keybindings.adoc` with a Folding section
