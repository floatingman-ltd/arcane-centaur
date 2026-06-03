## REMOVED Requirements

### Requirement: OpenCode MCP declaration
**Reason**: `opencode.json` has been deleted; OpenCode is no longer used. Serena is now declared for Claude Code (see the added requirement below).

### Requirement: OpenCode launch command configuration
**Reason**: Folded into the Claude Code MCP declaration; the launch command (`serena start-mcp-server --context ide --project-from-cwd`) is unchanged but now lives in `~/.claude.json`.

### Requirement: Copilot MCP declaration
**Reason**: `lua/plugins/copilot.lua` and `vim.g.copilot_mcp_servers` have been removed; `copilot.vim` no longer routes code-intelligence requests to Serena.

## ADDED Requirements

### Requirement: Claude Code MCP declaration
Serena SHALL be declared as a local MCP server for Claude Code (at the user level, in `~/.claude.json`) using the `serena` binary with `serena start-mcp-server --context=claude-code --project-from-cwd`, so that Claude Code can use Serena's semantic code-intelligence tools.

#### Scenario: Server starts with Claude Code
- **WHEN** Claude Code is launched in this directory
- **THEN** it SHALL start Serena via `serena start-mcp-server --context=claude-code --project-from-cwd` and make its tools available

#### Scenario: claude-code context active
- **WHEN** Serena starts under the `claude-code` context
- **THEN** basic file/search/shell tools are suppressed in favour of Claude Code's built-ins, and semantic tools (find_symbol, rename_symbol, replace_symbol_body, etc.) are exposed

#### Scenario: Serena not installed
- **WHEN** the `serena` binary is not on `$PATH`
- **THEN** Claude Code SHALL report the failure and continue without Serena's tools; no crash

## MODIFIED Requirements

### Requirement: Documentation
Installation prerequisites (`uv`, `serena-agent`) SHALL be documented in `docs/modules/ROOT/pages/ai/ai-tools.adoc`.

#### Scenario: Docs document prerequisites
- **WHEN** a user reads the Serena section of `docs/modules/ROOT/pages/ai/ai-tools.adoc`
- **THEN** they SHALL find the `uv tool install serena-agent` install command and a note that `lua-language-server` is downloaded automatically on first run
