## Why

The git tooling here (vim-fugitive, gitsigns, diffview) covers staging, blame and diffs, but nothing gives a single screen of status, branches, commits and stash with guided rebase, cherry-pick and stash handling. LazyGit does, and running it inside the editor keeps that workflow in the same session as the files it changes.

## What Changes

- Add `lua/config/lazygit.lua`: opens `lazygit` in a floating terminal window over the editor. No plugin.
- `<leader>gg` opens LazyGit for the repository of the current buffer. A second map opens it filtered to the current file's history (`lazygit -f <file>`).
- Pressing `e` on a file inside LazyGit opens that file in the surrounding Neovim and closes the float, instead of starting a nested Neovim.
- LazyGit is coloured to match the active TokyoNight style.
- When the float closes, changed buffers are reloaded and gitsigns and nvim-tree are refreshed, so commits, checkouts and resets made in LazyGit show immediately.
- The LazyGit settings this needs are passed only to the instance launched from Neovim. The user's own LazyGit config is still loaded and is not modified.
- `lazygit` becomes a documented host prerequisite (GitHub release; Ubuntu 24.04 has no apt package). It is not containerised: it is a host CLI the editor calls, like `git`.
- vim-fugitive, gitsigns and diffview are unchanged.

## Capabilities

### New Capabilities

- `lazygit-float`: launching LazyGit in a floating terminal from Neovim — keymaps, repository and file-history modes, editing files in the outer Neovim, TokyoNight colours, refresh on close, and behaviour when `lazygit` is missing or the buffer is not in a repository.

### Modified Capabilities

None. `docs-getting-started` already requires every shared external tool to be documented; adding `lazygit` to it is a docs update under that existing requirement.

## Impact

- New: `lua/config/lazygit.lua`, wired from `init.lua` via `setup()`.
- Keymaps: `<leader>gg` and one more `<leader>g` key, both currently unused.
- Docs: new `editor/git/lazygit.adoc` page and nav entry, git rows in `editor/keybindings.adoc`, `lazygit` in `getting-started.adoc` prerequisites and feature→dependency table.
- `openspec/TEST_PLAN.md`: new change section.
- Host dependency: `lazygit` binary on `$PATH`.
- No change to `lazy-lock.json`.
