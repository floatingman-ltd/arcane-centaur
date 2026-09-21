## 1. Detection flag

- [x] 1.1 Add a local `detect_remote()` helper to `lua/config/terminal.lua`, returning `true` when `$SSH_TTY` or `$SSH_CONNECTION` is present
- [x] 1.2 Extend `detect_remote()` with the tmux fallback: when `$TMUX` is set, both SSH variables are absent, and `vim.fn.executable("tmux") == 1`, run `tmux show-environment SSH_CONNECTION` and treat a result whose first character is not `-` as remote
- [x] 1.3 Guard the fallback on `vim.v.shell_error == 0` so a failed query reads as local rather than remote, and confirm no error surfaces in `:messages`
- [x] 1.4 Expose `M.is_remote = detect_remote()` beside `M.is_wsl` and `M.is_console`, with a comment naming both the tmux limitation it solves and its independence from `is_console`
- [x] 1.5 Syntax-check: `find . -name '*.lua' -print0 | xargs -0 luac -p`

## 2. Input timing

- [x] 2.1 Set `o.ttimeoutlen = term.is_remote and 100 or 50` in `lua/options.lua`, with a comment recording why the remote value is higher
- [x] 2.2 Confirm `timeout` and `ttimeout` are left unset, since both are already `1` by default — do not add the two no-op lines from issue #188
- [x] 2.3 Verify headlessly that `ttimeoutlen` is `50` on this local machine and `timeoutlen` is still `1000`

## 3. Statusline repaint

- [x] 3.1 Add an `options.refresh` table to `lua/plugins/lualine.lua` setting `statusline`, `tabline` and `winbar` to `term.is_remote and 5000 or 1000`
- [x] 3.2 Leave `options.refresh.events` unset, at lualine's default. Install `User GitSignsUpdate` and `DiagnosticChanged` as dedicated autocommands in a `LualineAsyncRefresh` augroup from the spec's `config` function, each calling `require("lualine").refresh()`
- [x] 3.3 Do **not** put those two in `options.refresh.events`. lualine formats that list into `autocmd <group> <events> <pattern> <cmd>`, so the space in `User GitSignsUpdate` splits the event list and everything after it becomes the pattern
  > **Defect found and fixed here, 2026-09-10.** The first implementation did add both to `refresh.events`, restating all ten defaults so the index-wise deep merge would not drop any. Inspecting the registered autocommands showed all ten real events bound to the patterns `GitSignsUpdate`/`DiagnosticChanged` rather than `*`, `DiagnosticChanged` not registered as an event at all, and the command mangled to `* call v:lua...`. That would have stopped the statusline refreshing on cursor movement — silently, and a worse regression than the staleness the change set out to fix. Reworked to dedicated autocommands; `refresh.events` now resolves to exactly the ten defaults, every one with pattern `*`.
- [x] 3.4 Confirm at runtime that `refresh.events` holds exactly the ten defaults, that no autocommand in lualine's refresh augroups has a non-`*` pattern, and that both dedicated autocommands are registered and fire without error
- [x] 3.5 Verify headlessly that `refresh.statusline` is `1000` locally and `5000` with `$SSH_TTY` set

## 4. Documentation

- [x] 4.1 Add `is_remote` to the `terminal.lua` flag list in `docs/modules/ROOT/pages/other/architecture.adoc` (the row at the `terminal.lua` entry)
- [x] 4.2 Document the detection rule, the tmux fallback, and the deliberate negative for non-interactive commands, in the Console Detection section or a sibling section
- [x] 4.3 State explicitly that `is_remote` and `is_console` are independent, and that neither implies the other
- [x] 4.4 Build the docs site (`./docker/antora/run.sh antora-playbook.yml`) and check the rendered page for AsciiDoc errors

## 5. Validation

- [x] 5.1 Add a `## Change · add-remote-session-profile` section to `openspec/TEST_PLAN.md` with branch name, prerequisites, and numbered `Prepare` / `Validate` / `Raise PR & merge` / `Post-merge` subsections
- [ ] 5.2 Validate locally in a live Neovim session: `is_remote` false, `ttimeoutlen` 50, lualine refresh 1000, statusline content unchanged
- [ ] 5.3 Validate over a real SSH session: `is_remote` true, `ttimeoutlen` 100, lualine refresh 5000
- [ ] 5.4 Validate in a tmux session started **before** the SSH connection, which is the case the fallback exists for: `is_remote` must still read true
- [ ] 5.5 Validate in a local tmux session outside SSH: `is_remote` must read false
- [ ] 5.6 Feel-test `<Esc>` latency on the remote session and record the verdict; drop to 75 ms if 100 ms is intolerable
- [ ] 5.7 Confirm git hunk counts update promptly at the 5000 ms interval — edit a tracked file, stop moving the cursor, and watch the counts change without waiting five seconds
- [ ] 5.8 Confirm diagnostic counts update promptly under the same conditions, using a file that produces an LSP diagnostic
- [x] 5.9 Measure and record the tmux query's startup cost, so the design's claim that it is negligible rests on a number
- [ ] 5.10 Tick each `- [ ]` in the TEST_PLAN section only once genuinely confirmed, logging any defect and its fix inline as a blockquote note

## 6. Close out

- [ ] 6.1 Delete the `#187`/`#188`/`#189` portions of the priority entry in `recommendations/ideas.md`, per that file's rule that shipped work is deleted rather than archived; leave `#190`, `#191` and `#192`
- [ ] 6.2 Add any deferred eyes-on work to `openspec/DEFERRED_VERIFICATION.md` — in particular the mosh question, if it is still open
- [ ] 6.3 Close GitHub issues #189, #188 and #187 with a reference to the merged PR
- [ ] 6.4 Archive the change (`openspec archive`), then immediately write the `remote-session-profile` Purpose by hand — `openspec archive` leaves a `TBD` placeholder that deltas cannot fill, and 14 specs already carry one
