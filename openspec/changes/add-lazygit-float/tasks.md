## 1. Install LazyGit and confirm its behaviour

- [ ] 1.1 Install `lazygit` from the GitHub release into `~/.local/bin` (no apt package on Ubuntu 24.04). Record the version.
- [ ] 1.2 Confirm `:lua print(vim.fn.exepath("lazygit"))` resolves inside Neovim.
- [ ] 1.3 Confirm against the installed version, and amend `design.md` if any differ: `LG_CONFIG_FILE` takes a comma-separated list merged in order and replaces the default `config.yml`; `lazygit --print-config-dir` prints the config directory; `-f <path>` filters the commit list to a file; `os.edit`, `os.editAtLine` and `os.editInTerminal` exist with `{{filename}}` and `{{line}}` placeholders; the `gui.theme` keys D6 uses exist.
- [ ] 1.4 Record how `{{filename}}` is quoted when substituted, using a path containing a space and one containing a single quote.

## 2. Module skeleton and launch

- [ ] 2.1 Create `lua/config/lazygit.lua` with `setup()`; call it from `init.lua` alongside `claude_cli` and `openspec`.
- [ ] 2.2 Repository root lookup: buffer directory first, then cwd; warn and return when neither is in a repository (D2).
- [ ] 2.3 Missing-binary check: error naming `lazygit` and `getting-started.adoc`, no window (D9).
- [ ] 2.4 Float: 90% of the editor, centred, rounded border, title; `bufhidden = wipe`; resize on `VimResized` while open (D7).
- [ ] 2.5 Start LazyGit with `jobstart(..., { term = true, cwd = root, env = ... })` and enter terminal mode.
- [ ] 2.6 Buffer-local terminal-mode `<Esc>` passthrough so LazyGit receives it (D7).
- [ ] 2.7 `<leader>gg` / `:LazyGit` and `<leader>gf` / `:LazyGitFile` (`-f <path relative to root>`; warn when the buffer has no file), each with a `desc`.

## 3. Generated config

- [ ] 3.1 Write `stdpath("state")/lazygit/nvim.yml` on each launch (D4).
- [ ] 3.2 Build `LG_CONFIG_FILE` as `<user config.yml if present>,<generated file>`, set only in the job's env (D3).
- [ ] 3.3 Theme block from the active TokyoNight palette; omit it when the scheme is not TokyoNight, the palette cannot be loaded, or console mode is active (D6).

## 4. Edit in the outer Neovim

- [ ] 4.1 Pass `LAZYGIT_NVIM_BIN=v:progpath` in the job env; set `os.edit` / `os.editAtLine` to `"$LAZYGIT_NVIM_BIN" --server "$NVIM" --remote-expr` calling `require'config.lazygit'.edit(file, line)`; `os.editInTerminal: false` (D5). Quote the path per the result of 1.4.
- [ ] 4.2 `M.edit(file, line)`: schedule closing the float, return to the window current before it opened, `:edit` the file, jump to `line` if given.

## 5. Refresh on close

- [ ] 5.1 In `on_exit` (scheduled): `:checktime`, gitsigns refresh if loaded, nvim-tree reload if loaded; each step isolated so one failure does not skip the rest (D8).

## 6. Checks

- [ ] 6.1 `find . -name '*.lua' -print0 | xargs -0 luac -p` — no output.
- [ ] 6.2 `stylua --check lua/config/lazygit.lua init.lua`.
- [ ] 6.3 Neovim starts with no errors when `lazygit` is absent from `$PATH`.
- [ ] 6.4 `lazy-lock.json` is unchanged.

## 7. Documentation

- [ ] 7.1 New `docs/modules/ROOT/pages/editor/git/lazygit.adoc`: what it is, install, keys, editing from LazyGit, theme, refresh behaviour, how it relates to fugitive/gitsigns/diffview.
- [ ] 7.2 Add `xref:editor/git/lazygit.adoc[LazyGit]` under *Git* in `docs/modules/ROOT/nav.adoc`.
- [ ] 7.3 `editor/keybindings.adoc`: add LazyGit to the Git row and the Git section, with `<leader>gg` and `<leader>gf`.
- [ ] 7.4 `getting-started.adoc`: add `lazygit` to the per-feature prerequisites and the feature→dependency table, with the GitHub-release install.
- [ ] 7.5 Build the docs site locally (`./docker/antora/run.sh antora-playbook.yml`) and check the new page and nav entry render.

## 8. Test plan

- [ ] 8.1 Add `## Change · add-lazygit-float` to `openspec/TEST_PLAN.md` with Prepare / Validate / Raise PR & merge / Post-merge, one Validate case per spec scenario, including paths with a space, the `<leader>T` `<Esc>` regression check, and console mode.
- [ ] 8.2 Walk every Validate case in a live Neovim session and tick only what is confirmed.
