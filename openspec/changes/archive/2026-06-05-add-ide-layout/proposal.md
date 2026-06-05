# Add IDE Layout

## Why

The config has all the pieces of an IDE-style workspace (nvim-tree, a persistent terminal toggle) but no way to assemble them in one keystroke, and the layout is fragile: the terminal split opens inside the tree column when focus is in the tree, and closing a buffer (`:bd`) or the last editor window (`:q`) collapses the layout, leaving nvim-tree expanded to full width.

## What Changes

- Terminal toggle (`<leader>t`) opens a **full-width bottom split** (`botright`) regardless of which window has focus, with `winfixheight` so other splits don't re-equalize it. Fixes the latent bug where the terminal opens 30 cols wide inside the tree column.
- New `<leader>L` keymap assembles the IDE layout in one keystroke: nvim-tree left, editor right, full-width terminal bottom — idempotent, returning focus to the editor.
- New `:Bd` layout-preserving buffer delete: the window switches to another buffer before deletion, so the window layout (and the tree's width) survives.
- New autocmd closes nvim-tree when it would be left as the last remaining window after `:q`.
- REPLs are explicitly untouched: Conjure stays a float (HUD); iron.nvim/GHCi keep their own windows. Floating UIs (Glow, which-key, cheatsheet popups) are unaffected by design.

## Capabilities

### New Capabilities
- `ide-layout`: One-keystroke IDE-style workspace assembly (tree + editor + full-width bottom terminal), focus-independent full-width terminal toggle with persistent shell, and layout stability under buffer/window close (`:Bd`, last-window autocmd).

### Modified Capabilities

None — no existing spec covers terminal toggle or tree navigation (verified against `openspec/specs/`).

## Impact

- `lua/keymaps.lua` — terminal section: `botright split` + `winfixheight` fix, new `ide_layout()` + `<leader>L`, new `:Bd` command.
- `lua/plugins/nvim-tree.lua` — last-window autocmd (first autocmd in the repo; `nvim_create_autocmd` + named augroup).
- Docs: `docs/modules/ROOT/pages/editor/keybindings.adoc`, `docs/modules/ROOT/pages/editor/navigation.adoc`, `cheatsheets/core.md`.
- No new plugins; no changes to REPL plugins (`lua/plugins/dotnet.lua`, `lua/plugins/lisp.lua`, `lua/plugins/haskell.lua`).
