# Tasks: Add IDE Layout

## 1. Terminal toggle fixes (lua/keymaps.lua)

- [x] 1.1 Change `toggle_terminal` to use `botright split` so the terminal opens full-width regardless of focused window
- [x] 1.2 Set `winfixheight` on the terminal window when created (keep `resize 15`, buffer reuse, `startinsert`)

## 2. IDE layout assembly (lua/keymaps.lua)

- [x] 2.1 Add `ide_layout()`: record current window → `NvimTreeOpen` → ensure terminal visible (reuse window-scan; `stopinsert` after opening) → restore focus to editor window (fallback `wincmd t` + `wincmd l`)
- [x] 2.2 Add `<leader>L` keymap with desc "IDE layout: tree + editor + terminal"

## 3. Layout stability

- [x] 3.1 Add `:Bd` user command in lua/keymaps.lua: switch windows showing the buffer to alternate/next listed buffer (or empty) before `:bdelete`
- [x] 3.2 Add `QuitPre` autocmd in lua/plugins/nvim-tree.lua config (augroup `ide_layout`): close nvim-tree/terminal when they would be the only windows left; ignore floating windows

## 4. Documentation

- [x] 4.1 Update docs/modules/ROOT/pages/editor/keybindings.adoc: add `<leader>L` and `:Bd`; note `<leader>t` is now full-width
- [x] 4.2 Update docs/modules/ROOT/pages/editor/navigation.adoc: rewrite terminal section (full-width, persistent shell), add IDE layout subsection with ASCII diagram, document tree-expansion fixes
- [x] 4.3 Update cheatsheets/core.md: add `<leader>L` and `:Bd` to the tree/terminal block

## 5. Validation

- [x] 5.1 Run `find . -name '*.lua' -print0 | xargs -0 luac -p` (all Lua syntax-clean)
- [x] 5.2 Manual verification per spec scenarios: `<leader>L` assembly + idempotency, `<leader>t` from tree (full-width), shell persistence across toggles, `:Bd` keeps layout, `:q` last-window behavior, floats (Glow/which-key/Conjure HUD) unaffected, terminal height stable when splitting
