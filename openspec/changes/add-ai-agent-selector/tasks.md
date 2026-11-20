## 1. Selector

- [x] 1.1 Create `lua/config/ai_agent.lua`: read `$NVIM_AI_AGENT` case-insensitively; expose `name`, `is_claude`, `is_copilot`, `label`; warn and fall back to `claude` on an unrecognised value
- [x] 1.2 Headless check: `name` for unset, `Copilot`, and `gemini` (with the warning text)

## 2. Gate Claude

- [x] 2.1 `lua/plugins/claudecode.lua`: add `cond = ai_agent.is_claude`; confirm headlessly that `init` does not run, so its maps are absent, under `NVIM_AI_AGENT=copilot`
- [x] 2.2 `init.lua`: call `config.claude_cli.setup()` only when Claude is selected
- [x] 2.3 `lua/keymaps.lua`: bind `<leader>gcs`/`gce` to the selected agent's commands; replace the "Copilot has been removed" comment

## 3. Copilot one-shot commands

- [x] 3.1 Restore `lua/config/copilot_cli.lua` from `95acd42^`; drop its local `open_float` in favour of `util.open_float`
- [x] 3.2 Check the prompt-mode flags against `copilot --help` on an installed CLI; update the argv and record the CLI version used (1.0.54: `-s --available-tools= -p`; success path unverified here: the account policy denies requests)
- [x] 3.3 `init.lua`: call `config.copilot_cli.setup()` only when Copilot is selected

## 4. Copilot session

- [x] 4.1 Create `lua/config/copilot_session.lua`: single terminal buffer and job, toggle (window only, job survives), focus, missing-binary error
- [x] 4.2 Add-buffer (`@<relpath> `) and send-selection via `chansend`, starting the session if needed; confirm `@` mention syntax against the installed CLI (the TUI footer reads `@ files/sessions`; both sends land on the input line from a cold start)
- [x] 4.3 Bind `<leader>gcc/gcf/gcb` and visual `<leader>gcv` eagerly at startup when Copilot is selected; leave `gca/gcr` unmapped

## 5. Inline completion

- [x] 5.1 Create `lua/plugins/copilot.lua`: `github/copilot.vim`, `cond = ai_agent.is_copilot`, `event = "InsertEnter"`, `vim.g.copilot_no_tab_map = true`, insert `<C-J>` accept and `<M-f>` accept-word with `desc`
- [x] 5.2 Add copilot.vim to `lazy-lock.json` with `:Lazy install` (not `:Lazy sync`) under `NVIM_AI_AGENT=copilot`

## 6. Avante

- [x] 6.1 `lua/plugins/avante.lua`: when Copilot is selected, add `providers.copilot` and a `<leader>ac` map that switches to it and opens; leave `provider = "ollama"`; update the header comment
- [x] 6.2 Drop the provider again after `<leader>ac` failed on the client (design D6): `lua/plugins/avante.lua` back to its `main` version, Avante docs, `CLAUDE.md`, the `avante-runtime`/`ai-research-ollama` deltas removed, the reason recorded in `tried-and-backed-out.md`

## 7. which-key

- [x] 7.1 `lua/plugins/which-key.lua`: label `<leader>gc` with `ai_agent.label` in normal and visual mode

## 8. Docs

- [x] 8.1 `docs/modules/ROOT/pages/ai/ai-tools.adoc`: an agent-selection section (`NVIM_AI_AGENT`, rc file, restart tmux/Neovim), and the Copilot surfaces with prerequisites (`copilot` CLI, `:Copilot setup`)
- [x] 8.2 `ai-tools-cheatsheet.adoc`: the `<leader>gc` table per agent, `<C-J>`/`<M-f>`
- [x] 8.3 `getting-started.adoc`: the `copilot` CLI as a prerequisite on Copilot machines
- [x] 8.4 Update the `CLAUDE.md` AI assistance section and the Copilot row in `recommendations/tried-and-backed-out.md`
- [x] 8.5 Build the Antora site and confirm both pages render

## 9. Validation

- [x] 9.1 `find . -name '*.lua' -print0 | xargs -0 luac -p`
- [x] 9.2 Add `## Change · add-ai-agent-selector` to `openspec/TEST_PLAN.md`, covering both agents (Claude unset on this laptop; `NVIM_AI_AGENT=copilot` on this laptop and on the client)
- [ ] 9.3 Walk every TEST_PLAN step in a live Neovim session and tick only what was confirmed
- [x] 9.4 Mirror the change artifacts onto `main`
