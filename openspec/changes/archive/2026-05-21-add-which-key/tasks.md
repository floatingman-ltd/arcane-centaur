## 1. Plugin Installation

- [x] 1.1 Create `lua/plugins/which-key.lua` with `folke/which-key.nvim` spec, `opts = {}`, and a `config` function that registers group labels for `<leader>gc` (Copilot) and `<leader>os` (OpenSpec)

## 2. Add Missing Descriptions — Core Keymaps

- [x] 2.1 Add `desc` to window navigation keymaps in `lua/keymaps.lua` (`<C-h/j/k/l>`)
- [x] 2.2 Add `desc` to window resize keymaps in `lua/keymaps.lua` (`<C-Up/Down/Left/Right>`)
- [x] 2.3 Add `desc` to visual mode keymaps in `lua/keymaps.lua` (indent, move block, replace without clipboard)
- [x] 2.4 Add `desc` to file tree keymaps in `lua/keymaps.lua` (`<leader>n`, `<C-n>`, `<C-t>`, `<C-f>`)

## 3. Add Missing Descriptions — LSP Keymaps

- [x] 3.1 Add `desc` to all keymaps in the `on_attach` function in `lua/config/lsp.lua`

## 4. Add Missing Descriptions — Filetype Keymaps

- [x] 4.1 Add `desc` to `<localleader>p` and `<localleader>pp` keymaps in `after/ftplugin/markdown.lua`
- [x] 4.2 Add `desc` to all three keymaps in `after/ftplugin/haskell.lua` (`<space>cl`, `<space>hs`, `<space>ea`)

## 5. Validation

- [x] 5.1 Syntax-check all modified Lua files with `find . -name '*.lua' -print0 | xargs -0 luac -p`
- [x] 5.2 Open Neovim, press `<leader>` and pause — confirm popup appears with descriptions and group labels
- [x] 5.3 Update `docs/modules/ROOT/pages/editor/keybindings.adoc` to note which-key popup availability
