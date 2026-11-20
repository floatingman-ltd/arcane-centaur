## Context

Today `<leader>gc` belongs to Claude. `claudecode.nvim` (`lua/plugins/claudecode.lua`) binds `gcc/gcf/gcb/gcv/gca/gcr` eagerly in `init`. `claude_cli` (`lua/config/claude_cli.lua`, set up from `init.lua`) provides `gcs/gce`, which are bound in `lua/keymaps.lua`. which-key labels the group "Claude" in both normal and visual mode (`lua/plugins/which-key.lua:103,136`). Avante is Ollama-only.

`95acd42` removed `copilot.vim`, `lua/config/copilot_cli.lua`, the `<C-J>`/`<M-f>` accept maps and the avante copilot provider. The old CLI wrapper ran `copilot -sp <prompt>`. Copilot was removed to consolidate on Claude, with no technical failure recorded (`recommendations/tried-and-backed-out.md`).

Two machines are involved: this laptop (Claude) and a client AVD-hosted WSL instance (Copilot). Each machine has its own shell rc, so an environment variable distinguishes them without a tracked per-machine file.

## Goals / Non-Goals

**Goals:**
- One environment variable chooses the agent; unset means today's behaviour exactly.
- Only the selected agent's plugins load and only its maps exist, so which-key never shows the other agent's keys.
- The Copilot machine gets the same `<leader>gc` layout as the Claude machine wherever there is an equivalent.

**Non-Goals:**
- Running both agents in one session, or switching agents without restarting Neovim.
- An editor-aware Copilot session with an MCP diff protocol. claudecode.nvim's protocol is Claude-specific.
- Copilot Chat (`CopilotChat.nvim`). The agentic surface is the `copilot` CLI.
- Changing Avante's default provider. Ollama stays the default on both machines.

## Decisions

### D1. Selector: `$NVIM_AI_AGENT`, read once, in `lua/config/ai_agent.lua`

The module exposes `M.name` (`"claude"` or `"copilot"`), `M.is_claude`, `M.is_copilot`, and `M.label` (`"Claude"` / `"Copilot"`). Matching is case-insensitive. An unrecognised value produces a `vim.notify` warning and falls back to `claude`.

- *Alternative: an untracked `lua/local.lua`*. Rejected by the user. It also has to be created by hand on each machine, and it moves under the `publish-as-lazy-distribution` restructure, while an environment variable does not.
- *Alternative: auto-detect from which CLI is on `$PATH`*. Rejected: a machine with both installed would get a surprise, and the choice depends on the engagement, not on what is installed.

It lives in `lua/config/` next to `terminal.lua`, which already holds read-once environment flags. The distribution restructure moves `lua/config/*` wholesale, so this module moves with it.

### D2. Gating via lazy.nvim `cond` plus guarded `init`

`cond = function() return require("config.ai_agent").is_copilot end` (and the inverse) on `claudecode.nvim` and `copilot.vim`. lazy.nvim does not run `init` for a spec whose `cond` is false, so claudecode's eager maps disappear with it. This is the same mechanism `markdown-preview.nvim` already uses with `term.is_console`.

`claude_cli` / `copilot_cli` are not plugins. `init.lua` calls the selected module's `setup()`, and `keymaps.lua` binds `gcs/gce` to the selected commands.

### D3. Copilot session: a native terminal split running `copilot`

`lua/config/copilot_session.lua` owns one terminal buffer and job.
- `<leader>gcc` toggles a right-hand vertical split: it opens the window (starting `copilot` if the job is not running) or closes the window without stopping the job.
- `<leader>gcf` focuses the split, opening it if needed, and enters terminal-insert.
- `<leader>gcb` sends `@<path relative to cwd> ` to the job with `chansend`. The Copilot CLI's `@` file mention adds the file as context. *Verify against the installed CLI version before ticking.*
- Visual `<leader>gcv` sends the selected lines, wrapped in a fenced block with the file path, without a trailing newline, so the user can add a question before submitting.
- `<leader>gca/gcr` are not mapped.
- Text sent while the CLI is still starting is dropped by its TUI (seen in a headless run on Copilot CLI 1.0.54), so sends are queued until the terminal has been quiet for 600 ms after its first output, with a 15 s cap. Multi-line text goes as a bracketed paste so its newlines do not submit it.

The maps are bound eagerly at startup, as `CLAUDE.md` requires for `<leader>gcv`: visual `gc` is a native operator, so the prefix has to be known before which-key builds its triggers.

- *Alternative: a terminal plugin (toggleterm, snacks)*. Rejected: `claudecode-session` already chose the native provider to avoid a snacks dependency, and the module is about 80 lines.

### D4. One-shot commands: restore `copilot_cli.lua`

Restore from `95acd42^`, removing the duplicated `open_float` (use `util.open_float`). `get_context_text` moves to `util.context_text` so `claude_cli` and `copilot_cli` share it, including the fix for stale `'<`/`'>` marks.

The argv is `copilot -s --available-tools= -p <prompt>` (checked against Copilot CLI 1.0.54). `--available-tools=` gives the model no tools, so a one-shot question from the editor can never edit files or run commands. That replaces `--allow-all-tools`, which `--help` says non-interactive mode requires. On this laptop the account's Copilot policy denies the request (`Access denied by policy settings`, printed on stdout), so the success path has to be verified on the client. The failure path is why errors fall back to stdout when stderr is empty.

### D5. Inline completion: `copilot.vim` with the old maps

`github/copilot.vim`, `cond` on Copilot, `event = "InsertEnter"`. Maps from `95acd42^`: insert `<C-J>` accept (with `vim.g.copilot_no_tab_map = true`, so `<Tab>` stays with blink/indent) and `<M-f>` accept-word. blink's keymap has `preset = "none"` and binds neither key; `<C-j>` is bound in normal mode only (`lua/keymaps.lua:17`). The old `copilot_mcp_servers` Serena block is not restored, because copilot.vim does not run agent tools. Serena belongs to the CLI's own MCP config.

### D6. Avante: conditional `copilot` provider

When Copilot is selected, `opts.providers.copilot = {}` (avante's built-in copilot provider reads copilot.vim's stored OAuth token), and `<leader>ac` switches to it and opens. `provider` stays `"ollama"`. When Claude is selected, neither the provider nor `<leader>ac` is added, so the "no `<leader>ac`" decision on the Claude machine still holds.

### D7. which-key label from the selector

`group("<leader>gc", ai_agent.label)` in both modes. The `<leader>gc` group then reads "Claude" or "Copilot", and the descriptions (`Claude: …` / `Copilot: …`) agree with it.

## Risks / Trade-offs

- [Copilot CLI flags or `@` mention syntax differ from 2026-06 knowledge] → D3/D4 verification tasks check them against `copilot --help` on the client machine before ticking.
- [Avante's copilot provider uses Copilot's chat API from a third-party client. The client's Copilot policy may not allow that] → The provider only takes effect on `<leader>ac`, and Ollama stays the default. Check the client's policy before using it; it can be dropped without touching the other three surfaces.
- [`$NVIM_AI_AGENT` is not set in the environment Neovim starts from (GUI launcher, a tmux server started earlier)] → The fallback is Claude, which shows "Claude" in which-key on the Copilot machine and is immediately visible. Document setting it in the shell rc and restarting tmux.
- [Both agents' code paths can rot, because each machine exercises only one] → Each path gets its own TEST_PLAN section. Validate with `NVIM_AI_AGENT=copilot nvim` on this laptop as well as on the client.

## Migration Plan

Nothing to migrate on this laptop. On the client: install the `copilot` CLI, add `export NVIM_AI_AGENT=copilot` to the shell rc, restart Neovim, run `:Lazy install` (copilot.vim), then `:Copilot setup`. Rollback: unset the variable.

## Open Questions

- Does the installed Copilot CLI have an IDE/MCP integration mode comparable to claudecode.nvim's? If so, a later change could replace D3's terminal-typing approach. This change does not depend on the answer.
