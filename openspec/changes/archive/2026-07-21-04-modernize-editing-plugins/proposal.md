## Why

Four Vimscript-era plugins are declared as bare strings in `lua/plugins/init.lua` (`vim-airline`, `vim-surround`, `vim-sensible`, `vim-commentary`). The best-of-breed evaluation marks all four for replacement or removal:

- **vim-airline** — Vimscript statusline with known startup overhead; configured here with *zero* options and no theme, so it provides almost nothing over a modern Lua statusline. → `nvim-lualine/lualine.nvim` (pure Lua, TokyoNight theme built in, native gitsigns/LSP/diagnostics integration).
- **vim-surround** — Vimscript surround ops needing vim-repeat for dot-repeat. → `kylechui/nvim-surround` (same `ys`/`ds`/`cs` mnemonics, native dot-repeat, Lua).
- **vim-commentary** — superseded by Neovim's built-in `gc` operator (core since 0.10; this config targets ≥ 0.12). The native operator is comment-syntax-aware, dot-repeatable, and `[count]`-aware — identical interface.
- **vim-sensible** — sets defaults Neovim already owns; entirely redundant on 0.12.

Grouping these into one change is deliberate: all four are bare specs in the *same* file, so editing `lua/plugins/init.lua` once avoids the merge friction of four parallel branches each touching the same lines.

**Cross-validation finding that changes the plan: `vim-repeat` STAYS.** The evaluation suggests removing vim-repeat "after the surround swap," but `vim-unimpaired` (a KEEP verdict) depends on vim-repeat for dot-repeat of its `yo`/`]p`/`[e` maps. nvim-surround brings its own dot-repeat, so the surround swap frees nothing. vim-repeat is therefore retained and is explicitly out of scope for removal.

## What Changes

- **Replace** `vim-airline` with `nvim-lualine/lualine.nvim` in a new `lua/plugins/lualine.lua`, themed `tokyonight`, with branch/diff (gitsigns), diagnostics, filetype, and position segments.
- **Replace** `vim-surround` with `kylechui/nvim-surround` in a new `lua/plugins/nvim-surround.lua`, default config (preserves `ys`/`ds`/`cs`).
- **Remove** `vim-commentary` (delete `lua/plugins/vim-commentary.lua` and its bare spec); rely on Neovim's native `gc`/`gcc` operator. No keymap changes — the interface is identical.
- **Remove** `vim-sensible` (delete its bare spec) — redundant on Neovim 0.12.
- **Retain** `vim-repeat` and `vim-unimpaired` unchanged (vim-unimpaired needs vim-repeat).

## Capabilities

### New Capabilities

- `statusline`: an informative Lua statusline (lualine.nvim) showing mode, git branch + hunk counts, diagnostics, filetype, and cursor position, themed to match TokyoNight.
- `surround-text-objects`: add/change/delete surrounding pairs via `ys`/`cs`/`ds` with native dot-repeat (nvim-surround).
- `editor-commenting`: line and motion comment toggling via the native Neovim `gc`/`gcc` operator (no plugin).

### Modified Capabilities

<!-- none — no existing OpenSpec requirement covered airline, surround, commenting, or sensible -->

## Impact

- **`lua/plugins/init.lua`** → remove the `vim-airline`, `vim-surround`, `vim-sensible`, and `vim-commentary` lines. Keep `vim-repeat` and `vim-unimpaired`. (Note: `vim-commentary` actually has its own file — see next.)
- **`lua/plugins/vim-commentary.lua`** → deleted.
- **`lua/plugins/lualine.lua`** → new.
- **`lua/plugins/nvim-surround.lua`** → new.
- **Theme**: lualine reads `theme = "tokyonight"`; `lua/options.lua` already sets `showmode = false`, which pairs correctly with lualine's mode segment.
- **No new global keymaps**; `lua/keymaps.lua` defines no surround or comment maps, so nothing migrates.
- **Independence**: this change is independent of the completion and avante changes; the only shared touch with them is none (they edit different files).

## Prerequisites and sequencing

**Sequence position:** 04 of 08 — Wave A (independent).

- **Hard prerequisites:** none. Edits `lua/plugins/init.lua`, deletes `lua/plugins/vim-commentary.lua`, adds `lua/plugins/lualine.lua` + `lua/plugins/nvim-surround.lua`. No other change touches these files.
- **Not a which-key editor:** this change adds no keymaps, so it does **not** edit `lua/plugins/which-key.lua`. The `<leader>b` (Debug) and `<leader>x` (Trouble) groups are added by `add-dotnet-debug-test` and `add-diagnostics-todo-panel` respectively — no contention here.
- **Implementation wave: A** (independent; parallelizable with the other Wave A changes).

## Out of scope

- Removing `vim-repeat` (blocked by `vim-unimpaired`).
- Migrating `vim-unimpaired` to `mini.bracketed` (evaluation verdict is KEEP).
- Custom lualine sections beyond the standard informative set, or per-window statuslines (`laststatus = 3` is acceptable as configured by lualine's default).
