## 1. Remove Copilot / OpenCode files

- [x] 1.1 Delete `opencode.json` and `.opencode/`
- [x] 1.2 Delete `.github/copilot-instructions.md`, `.github/prompts/`, `.github/skills/`
- [x] 1.3 Delete `lua/plugins/copilot.lua` and `lua/config/copilot_cli.lua`
- [x] 1.4 Remove Copilot references from `lua/keymaps.lua`, `lua/options.lua`, `lua/plugins/which-key.lua`

## 2. Port workflows to Claude Code

- [x] 2.1 Port the 8 `openspec-*` skills + `add-neovim-feature` + `add-learning-lesson` to `.claude/skills/`
- [x] 2.2 Rewrite internal `/opsx:*` cross-references to the new skill slash-command names
- [x] 2.3 Point the `add-neovim-feature` skill's preflight at `CLAUDE.md` instead of `copilot-instructions.md`
- [x] 2.4 Add `CLAUDE.md` project guidance at the repo root

## 3. Update documentation

- [x] 3.1 Rewrite `docs/modules/ROOT/pages/ai/ai-tools.adoc` (Copilot CLI → Claude CLI; Serena → Claude Code; Avante copilot → claude provider)
- [x] 3.2 Update `docs/modules/ROOT/pages/ai/ai-tools-cheatsheet.adoc`
- [x] 3.3 Update `docs/modules/ROOT/pages/other/architecture.adoc` (file-structure tables; `.github/` and `.claude/` sections)
- [x] 3.4 Update `editor/keybindings.adoc`, `editor/navigation.adoc`, `index.adoc`, `getting-started.adoc`

## 4. Update specs (this change)

- [x] 4.1 Remove `copilot-cli-integration`; add `claude-cli-integration`
- [x] 4.2 Remove `ai-research-copilot`; add `ai-research-claude`
- [x] 4.3 Modify `serena-mcp-server` (OpenCode/Copilot MCP declarations → Claude Code declaration; docs path)
- [x] 4.4 Modify incidentally-affected specs: `which-key-popup` (group → Claude), `learning-lesson-skill` (skill → `.claude/skills/`), `context-aware-cheatsheet` (core → Claude CLI), `docs-nav-structure` (AI & Automation → AI Tools)
- [x] 4.5 `openspec validate remove-copilot-opencode --strict` passes

## 5. Verify

- [x] 5.1 `luac -p` passes on all Lua files; no dangling requires to deleted modules
- [x] 5.2 Serena MCP confirmed available to Claude Code via `~/.claude.json` (`claude mcp list` → `serena ✓ Connected`)
