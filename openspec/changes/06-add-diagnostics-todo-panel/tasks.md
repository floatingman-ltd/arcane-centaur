## 1. trouble.nvim

- [x] 1.1 Create `lua/plugins/trouble.lua` with `folke/trouble.nvim`, `version = "*"`, `cmd = "Trouble"`, and `opts = {}` (no quickfix takeover).
- [x] 1.2 Define `<leader>x` keymaps: `xx` (project diagnostics), `xX` (buffer diagnostics), `xs` (symbols), `xr` (LSP refs), `xl` (loclist), `xq` (quickfix). Verify the v3 command-argument syntax against the installed version.
- [x] 1.3 Do NOT remap `[d`/`]d` or `<leader>e`.

## 2. todo-comments.nvim

- [x] 2.1 Create `lua/plugins/todo-comments.lua` with `folke/todo-comments.nvim`, `dependencies = { "nvim-lua/plenary.nvim" }`, `event = { "BufReadPost", "BufNewFile" }`, `opts = {}`.
- [x] 2.2 Define `<leader>xt` (`:TodoTrouble`) and `<leader>xT` (`:TodoFzfLua`). Do NOT map `]t`/`[t` (reserved for vim-unimpaired).

## 3. which-key

- [x] 3.1 Register `{ "<leader>x", group = "Trouble" }` in `lua/plugins/which-key.lua`'s `wk.add`. **Coordination:** if `add-dotnet-debug-test` has already added its `<leader>b` group, append this entry to the existing `wk.add({ ... })` list rather than replacing the call (both groups coexist).

## 4. Validation

- [ ] 4.1 `:Lazy sync` — trouble.nvim and todo-comments.nvim install cleanly.
- [ ] 4.2 In a file with LSP diagnostics: `<leader>xx` opens the project panel, `<leader>xX` the buffer view; selecting an entry jumps to it.
- [ ] 4.3 Confirm `[d`/`]d`/`<leader>e` are unchanged.
- [ ] 4.4 Add `-- TODO:` / `-- FIXME:` comments: confirm highlighting + signs.
- [ ] 4.5 `<leader>xT` lists todos via fzf-lua; `<leader>xt` lists them in trouble.
- [ ] 4.6 Confirm vim-unimpaired `]t`/`[t` still do tag navigation.
- [x] 4.7 `find . -name '*.lua' -print0 | xargs -0 luac -p` — passes clean.

## 5. Documentation

- [x] 5.1 Update `docs/modules/ROOT/pages/editor/code-intelligence.adoc` with the trouble `<leader>x*` panel maps and the todo list maps.
- [x] 5.2 Add the `<leader>x*` and `<leader>xt`/`xT` maps to `docs/modules/ROOT/pages/editor/keybindings.adoc`, with a note that `]t`/`[t` remain vim-unimpaired tag maps.
- [x] 5.3 Updated `docs/modules/ROOT/pages/other/architecture.adoc` (trouble.nvim + todo-comments.nvim added to Navigation & UI table) and `CLAUDE.md` (diagnostics panel + TODO annotation conventions noted).
