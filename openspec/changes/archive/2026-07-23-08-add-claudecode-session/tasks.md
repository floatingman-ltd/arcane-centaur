## 1. Verify upstream behavior (do first)

- [x] 1.1 Read the claudecode.nvim README: terminal.provider options are "auto", "snacks", "native", "external", "none"; "native" works without snacks. Commands: `ClaudeCode` (toggle), `ClaudeCodeFocus`, `ClaudeCodeAdd`, `ClaudeCodeSend`, `ClaudeCodeDiffAccept`, `ClaudeCodeDiffDeny`. No required dependencies beyond the plugin itself.

## 2. Add claudecode.nvim

- [x] 2.1 Created `lua/plugins/claudecode.lua` with `coder/claudecode.nvim`, `opts.terminal = { provider = "native" }`, no snacks dependency declared.
- [x] 2.2 Defined `keys` under `<leader>gc`: `gcc` (toggle), `gcf` (focus), `gcb` (add buffer), `gcv` (send selection, visual), `gca` (accept diff), `gcr` (reject diff via `ClaudeCodeDiffDeny`).
- [x] 2.3 `lua/config/claude_cli.lua` and its `<leader>gcs`/`<leader>gce` maps left unchanged.
- [x] 2.4 Existing `{ "<leader>gc", group = "Claude" }` which-key entry covers all new maps — no new which-key group needed.

## 3. Validation

- [ ] 3.1 `:Lazy sync` — claudecode.nvim installs and snacks.nvim is NOT pulled in.
- [ ] 3.2 `<leader>gcc` starts a session in a native terminal and the `claude` CLI connects.
- [ ] 3.3 Visually select lines, `<leader>gcv` — selection reaches the session; `<leader>gcb` adds the current file.
- [ ] 3.4 Ask Claude to edit a file; `<leader>gca`/`<leader>gcr` accept/reject the diff.
- [ ] 3.5 Confirm `<leader>gcs`/`<leader>gce` (claude_cli) and `<leader>aa`/`<leader>ao`/`<leader>ac` (avante) still work.
- [x] 3.6 `find . -name '*.lua' -print0 | xargs -0 luac -p` — passes clean.

## 4. Documentation

- [x] 4.1 Updated `docs/modules/ROOT/pages/ai/ai-tools.adoc` with a Claude Code Session section comparing it to one-shot CLI and avante, listing the `<leader>gc*` maps, and noting native-terminal/snacks-free.
- [x] 4.2 Updated `docs/modules/ROOT/pages/ai/ai-tools-cheatsheet.adoc` with the `<leader>gcc`/`gcf`/`gcb`/`gcv`/`gca`/`gcr` maps alongside the existing `<leader>gcs`/`gce`.
- [x] 4.3 Updated `CLAUDE.md` AI assistance section to mention claudecode.nvim as the persistent-session option.
- [x] 4.4 Updated `docs/modules/ROOT/pages/other/architecture.adoc` (claudecode.nvim in AI & Automation table).
