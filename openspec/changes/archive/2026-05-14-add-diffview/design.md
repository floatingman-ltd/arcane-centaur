## Context

The configuration already provides git integration via vim-fugitive (status, blame, log, push, `:Git diff`) and gitsigns.nvim (gutter signs, inline hunk preview, per-hunk stage/reset). Both tools work at the hunk level or produce a plain split diff. There is no way to:

- View all changed files side-by-side in a persistent tabbed panel
- Browse a file's full commit history with diffs
- Navigate merge conflicts with a three-way merge view

diffview.nvim fills this gap with a purpose-built diff UI that wraps Neovim's native diff engine.

## Goals / Non-Goals

**Goals:**
- Add `sindrets/diffview.nvim` via the existing lazy.nvim plugin system
- Provide keymaps for opening the diff panel (`<leader>gD`), file history (`<leader>gH`), and closing the view (`<leader>gX`)
- Integrate into `lua/plugins/git.lua` alongside existing git plugins
- Document all new keybindings in `docs/cheatsheets/git.md`

**Non-Goals:**
- Replace vim-fugitive or gitsigns — diffview complements them
- Custom diffview highlight groups or theme overrides
- CI or automated test coverage for keybindings

## Decisions

### Place spec in `lua/plugins/git.lua`
All git-related plugins live in one file (`lua/plugins/git.lua`). Adding diffview there keeps git tooling consolidated rather than creating a separate file.

*Alternative considered*: separate `lua/plugins/diffview.lua`. Rejected — the file count is not large enough to warrant splitting, and grouping by domain is the existing convention.

### Keymap namespace: `<leader>g` prefix
Existing git keymaps all use `<leader>g` (status, blame, log, diff, push). Diffview maps follow suit: `<leader>gD` (diff view), `<leader>gH` (file history), `<leader>gX` (close). The uppercase letter distinguishes diffview commands from the simpler fugitive equivalents.

*Alternative considered*: separate `<leader>d` namespace. Rejected — it collides with potential debugger bindings and breaks the domain grouping.

### Lazy-load on commands
diffview.nvim is loaded on `cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" }`. This matches the lazy.nvim pattern used by vim-fugitive and avoids startup cost.

### Dependencies
diffview.nvim requires `nvim-lua/plenary.nvim` and optionally `nvim-tree/nvim-web-devicons`. Both are already pulled into the plugin graph by other plugins (fzf-lua, nvim-tree), so no new entries in `lua/plugins/init.lua` are needed.

## Risks / Trade-offs

- **Keymap conflict on `<leader>hD`** (gitsigns "diff this staged") vs new `<leader>gD` (diffview open): no conflict — the prefixes differ. Verify at install time.
- **Two "diff" entry points** (`<leader>gd` fugitive, `<leader>gD` diffview): slight discovery friction. Mitigated by clear descriptions in the cheatsheet.
- **Neovim version floor**: diffview.nvim requires Neovim ≥ 0.9. The project already requires ≥ 0.12, so no floor change needed.
