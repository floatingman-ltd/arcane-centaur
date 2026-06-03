## Why

GitHub Copilot and OpenCode have been retired from this configuration in favour of Claude. The in-editor "suggest/explain" commands now shell out to the `claude` CLI instead of the Copilot CLI; Avante's online backend is now the Claude API provider instead of the `github/copilot.vim` provider; the Serena MCP server is now declared for Claude Code (in `~/.claude.json`) instead of OpenCode (`opencode.json`) and `copilot.vim`; and the OpenSpec/feature workflows now live as Claude Code skills under `.claude/skills/`.

The implementing files have already been removed on branch `chore/remove-copilot-opencode`, but the OpenSpec source of truth still describes the old Copilot/OpenCode capabilities. This change retires those specs and records the Claude replacements so the specs match the code.

## What Changes

- **Remove** the `copilot-cli-integration` capability — `:CopilotSuggest` / `:CopilotExplain` (backed by the `copilot` CLI in `lua/config/copilot_cli.lua`) no longer exist.
- **Add** the `claude-cli-integration` capability — `:ClaudeSuggest` / `:ClaudeExplain` in `lua/config/claude_cli.lua`, backed by `claude -p` (Claude Code auth, no API key), bound to `<leader>gcs` / `<leader>gce`.
- **Remove** the `ai-research-copilot` capability — Avante's `copilot` provider (using `github/copilot.vim` auth) no longer exists.
- **Add** the `ai-research-claude` capability — Avante's `claude` provider (Claude API via `ANTHROPIC_API_KEY`, model `claude-3-5-haiku`), opened with `<leader>ac`; `<leader>aa` opens with the current provider.
- **Modify** the `serena-mcp-server` capability — drop the OpenCode (`opencode.json`) and `copilot.vim` (`vim.g.copilot_mcp_servers`) MCP declarations; Serena is now declared for Claude Code in `~/.claude.json`. Update the documentation requirement to the AsciiDoc docs path.
- **Modify** capabilities incidentally invalidated by the above:
  - `which-key-popup` — the `<leader>gc*` group is now labelled "Claude" (was "Copilot").
  - `learning-lesson-skill` — the skill now lives at `.claude/skills/add-learning-lesson/SKILL.md` (was `.github/skills/`), invocable as `/add-learning-lesson`.
  - `context-aware-cheatsheet` — the universal core section now lists the Claude CLI (was GitHub Copilot).
  - `docs-nav-structure` — the AI & Automation nav group covers AI Tools (the Copilot entry is gone).

## Impact

Files already removed on the branch:

- `opencode.json`, `.opencode/`
- `.github/copilot-instructions.md`, `.github/prompts/`, `.github/skills/`
- `lua/plugins/copilot.lua`, `lua/config/copilot_cli.lua`

Files added / changed on the branch:

- `lua/config/claude_cli.lua` — `:ClaudeSuggest` / `:ClaudeExplain`
- `lua/plugins/avante.lua` — `claude` provider replaces `copilot`
- `lua/keymaps.lua`, `lua/options.lua`, `lua/plugins/which-key.lua` — Copilot references removed
- `CLAUDE.md` — new project guidance for Claude Code
- `.claude/skills/` — OpenSpec + feature workflows ported from `.github/skills/`
- `docs/modules/ROOT/pages/ai/ai-tools.adoc` (+ cheatsheet), `other/architecture.adoc`, `editor/keybindings.adoc`, `editor/navigation.adoc`, `index.adoc`, `getting-started.adoc` — updated to describe Claude

Serena MCP for Claude Code is configured at the user level in `~/.claude.json`, independent of the deleted `opencode.json`.

## Out of scope

- `readme.adoc` (root) is a stale, auto-generated artifact (`:source: readme.md`) that predates the Antora docs restructure and references the old `docs/guides|cheatsheets/` layout. It is not part of the Antora site and is left for a separate cleanup (likely deletion).
