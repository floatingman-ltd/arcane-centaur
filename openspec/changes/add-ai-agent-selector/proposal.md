## Why

Copilot was removed in `95acd42` when Foci moved from Copilot to Claude. A client engagement now runs on Copilot, on an AVD-hosted WSL instance, while this laptop stays on Claude. The same config has to drive either agent, chosen per machine, without a fork or a branch per machine.

## What Changes

- **Add an agent selector**: a `lua/config/ai_agent.lua` module that reads `$NVIM_AI_AGENT` once at startup. Unset or `claude` selects Claude, `copilot` selects GitHub Copilot, and anything else warns and falls back to Claude. On a machine that does not set the variable, behaviour is unchanged.
- **Gate the Claude integrations on the selector**: `claudecode.nvim` and the `claude_cli` commands load and map only when Claude is selected.
- **Restore Copilot, gated the same way**, as four surfaces:
  - **Agentic session**: the `copilot` CLI in a native terminal split on `<leader>gcc` (toggle) and `<leader>gcf` (focus), with `<leader>gcb` (add buffer) and visual `<leader>gcv` (send selection) typing into that terminal. `<leader>gca`/`<leader>gcr` are left unmapped because there is no diff protocol to accept or reject.
  - **One-shot commands**: `:CopilotSuggest`/`:CopilotExplain` on `<leader>gcs`/`<leader>gce`, restored from `lua/config/copilot_cli.lua` at `95acd42^` and rebased onto `util.open_float`.
  - **Inline completion**: `github/copilot.vim`, with the `<C-J>` accept and `<M-f>` accept-word insert maps it had before.
  - **Avante provider**: a `copilot` provider next to `ollama`, with `<leader>ac` to select it and open. Ollama stays the default.
- **which-key**: the `<leader>gc` group is labelled with the selected agent's name ("Claude" or "Copilot").
- **Docs**: the AI guide and cheatsheet describe both agents and how to select one; `getting-started.adoc` lists the `copilot` CLI as a prerequisite on Copilot machines.

Not breaking: with `$NVIM_AI_AGENT` unset, every map, command and plugin is what it is today.

## Capabilities

### New Capabilities

- `ai-agent-selection`: reading `$NVIM_AI_AGENT`, its accepted values and fallback, and the rule that exactly one agent's plugins and maps are active in a session.
- `copilot-session`: the `copilot` CLI terminal session under `<leader>gc`.
- `copilot-cli-integration`: `:CopilotSuggest` / `:CopilotExplain` and their keymaps.
- `copilot-inline-completion`: `copilot.vim` ghost-text completion and its accept maps.

### Modified Capabilities

- `claudecode-session`: loads and maps only when Claude is selected.
- `claude-cli-integration`: commands and keymaps registered only when Claude is selected.
- `avante-runtime`: no longer Ollama-only. A `copilot` provider and `<leader>ac` exist when Copilot is selected, and Ollama remains the default.
- `ai-research-ollama`: the "only provider" clause is relaxed to "default provider".
- `which-key-popup`: the `<leader>gc` group label follows the selected agent.

## Impact

| Area | Change |
|---|---|
| `lua/config/ai_agent.lua` | new: the selector |
| `lua/config/copilot_cli.lua` | restored from `95acd42^`, using `util.open_float` |
| `lua/config/copilot_session.lua` | new: terminal split running `copilot` |
| `lua/plugins/copilot.lua` | new: `copilot.vim`, `cond` on the selector |
| `lua/plugins/claudecode.lua` | `cond` on the selector; `init` maps gated |
| `lua/plugins/avante.lua` | `copilot` provider and `<leader>ac` when Copilot is selected |
| `lua/plugins/which-key.lua` | `<leader>gc` group label from the selector |
| `lua/keymaps.lua`, `init.lua` | `<leader>gcs`/`gce` and `setup()` calls dispatch on the selector |
| `docs/.../ai/` guide + cheatsheet, `getting-started.adoc` | both agents, selection, prerequisites |
| `recommendations/tried-and-backed-out.md` | Copilot row annotated: restored as a per-machine option |
| External | Copilot machines need the `copilot` CLI (`npm install -g @github/copilot`, Node 22+) and `:Copilot setup` once |
