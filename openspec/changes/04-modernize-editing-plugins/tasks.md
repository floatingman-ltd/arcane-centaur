## 1. Statusline: vim-airline → lualine

- [x] 1.1 Create `lua/plugins/lualine.lua` with `nvim-lualine/lualine.nvim` (`event = "VeryLazy"`), `theme = "tokyonight"`, `globalstatus = true`, `icons_enabled = true`, and sections for mode, branch + diff (gitsigns), diagnostics, filetype, and position.
- [x] 1.2 Remove the `"vim-airline/vim-airline"` bare spec from `lua/plugins/init.lua`.

## 2. Surround: vim-surround → nvim-surround

- [x] 2.1 Create `lua/plugins/nvim-surround.lua` with `kylechui/nvim-surround` (`version = "*"`, `event = "VeryLazy"`, `opts = {}`).
- [x] 2.2 Remove the `"tpope/vim-surround"` bare spec from `lua/plugins/init.lua`.

## 3. Remove redundant tpope plugins

- [x] 3.1 Delete `lua/plugins/vim-commentary.lua`.
- [x] 3.2 Confirmed nothing references `:Commentary` Ex command (`grep -rn "Commentary" --include="*.lua" .` → clean).
- [x] 3.3 Remove the `"tpope/vim-sensible"` bare spec from `lua/plugins/init.lua`.
- [x] 3.4 Left `"tpope/vim-repeat"` and `"tpope/vim-unimpaired"` in place.

## 4. Validation

- [ ] 4.1 `:Lazy sync` — confirm `vim-airline`, `vim-surround`, `vim-sensible`, `vim-commentary` are removed and `lualine.nvim`, `nvim-surround` install without errors.
- [ ] 4.2 Confirm the lualine statusline renders mode, git branch, diff hunk counts, diagnostics, filetype, and cursor position.
- [ ] 4.3 Confirm surround ops: `ysiw"` adds quotes, `cs"'` changes them, `ds"` deletes them, and `.` repeats the last surround.
- [ ] 4.4 Confirm native commenting: `gcc` toggles the current line, `gc` + a motion toggles a range, both dot-repeatable.
- [ ] 4.5 Confirm `vim-unimpaired` still works and dot-repeats (e.g. `yos` toggles spell, `]q`/`[q` walk the quickfix).
- [ ] 4.6 Confirm no startup errors and no missing-option regressions from removing vim-sensible.
- [x] 4.7 Run Lua syntax check: `find . -name '*.lua' -print0 | xargs -0 luac -p`.

## 5. Documentation

- [x] 5.1 Update `docs/modules/ROOT/pages/editor/editing.adoc` to describe nvim-surround (`ys`/`cs`/`ds`) and native `gc` commenting, replacing vim-surround / vim-commentary references.
- [x] 5.2 Note lualine in `docs/modules/ROOT/pages/other/architecture.adoc`; replaced vim-airline.
- [x] 5.3 Grepped `CLAUDE.md` and docs — no stale airline/commentary/surround/sensible references found.
