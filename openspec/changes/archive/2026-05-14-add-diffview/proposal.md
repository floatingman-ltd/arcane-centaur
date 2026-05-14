## Why

The current git workflow (vim-fugitive + gitsigns) covers staging, blame, and inline hunk previews but lacks a side-by-side diff viewer, per-file commit history, and a visual merge conflict tool. diffview.nvim fills this gap with a dedicated tabbed diff UI built on Neovim's diff engine.

## What Changes

- Add `sindrets/diffview.nvim` plugin with lazy.nvim spec in `lua/plugins/git.lua`
- Expose keymaps under `<leader>g` for opening/closing the diff view and file history
- Document new keybindings in `docs/cheatsheets/git.md` and the cheatsheet index

## Capabilities

### New Capabilities

- `git-diff-view`: Side-by-side tabbed diff panel showing all changed files, per-file history (`DiffviewFileHistory`), and merge conflict resolution UI (`DiffviewOpen` with conflict highlighting).

### Modified Capabilities

<!-- none — no existing spec-level requirements change -->

## Impact

- **`lua/plugins/git.lua`**: new plugin spec added alongside vim-fugitive and gitsigns
- **`docs/cheatsheets/git.md`**: new keybinding rows for diffview commands
- **`docs/cheatsheets/index.md`**: updated if a new cheatsheet section is added (no new file needed; git cheatsheet already exists)
- **Dependencies**: `nvim-lua/plenary.nvim` (already pulled by other plugins) and `nvim-tree/nvim-web-devicons` (already present)
- **No breaking changes** to existing fugitive or gitsigns keymaps
