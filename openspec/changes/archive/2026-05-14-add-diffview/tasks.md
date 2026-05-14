## 1. Plugin Setup

- [x] 1.1 Add `sindrets/diffview.nvim` spec to `lua/plugins/git.lua` with `cmd` lazy-loading and keymaps for `<leader>gD`, `<leader>gH`, and `<leader>gX`
- [x] 1.2 Verify lazy.nvim resolves diffview.nvim and its dependencies (plenary, nvim-web-devicons) without conflicts — run `:Lazy sync` and confirm no errors

## 2. Validation

- [x] 2.1 Confirm `<leader>gD` opens a tabbed diff panel showing working tree changes without error
- [x] 2.2 Confirm `<leader>gH` opens a file history panel for the current buffer
- [x] 2.3 Confirm `<leader>gX` closes the diffview tab and returns focus to the previous buffer
- [x] 2.4 Confirm diffview.nvim is NOT loaded at startup (check `:Lazy` — plugin shows as not loaded until a keymap is used)
- [x] 2.5 Run Lua syntax check: `find . -name '*.lua' -print0 | xargs -0 luac -p`

## 3. Documentation

- [x] 3.1 Add a `## diffview.nvim` section to `docs/cheatsheets/git.md` with a table row for each keymap (`<leader>gD`, `<leader>gH`, `<leader>gX`)
- [x] 3.2 Update `readme.md` Plugin Overview table to include diffview.nvim
