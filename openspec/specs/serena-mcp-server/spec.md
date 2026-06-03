## Purpose

Configures the Serena symbol-aware code-intelligence MCP server so AI assistants (Claude Code) can perform semantic operations — go-to-definition, find-references, symbol search — in this repository.
## Requirements
### Requirement: Serena project configuration
A `.serena/project.yml` SHALL exist in the repo root declaring `project_name: nvim` and `languages: [lua]` so the Lua language server is started automatically for both integrations.

#### Scenario: Lua LSP auto-download
- **WHEN** Serena starts and `lua-language-server` is not on `$PATH`
- **THEN** Serena SHALL download it automatically; no manual installation step is required

### Requirement: Documentation
Installation prerequisites (`uv`, `serena-agent`) SHALL be documented in `docs/modules/ROOT/pages/ai/ai-tools.adoc`.

#### Scenario: Docs document prerequisites
- **WHEN** a user reads the Serena section of `docs/modules/ROOT/pages/ai/ai-tools.adoc`
- **THEN** they SHALL find the `uv tool install serena-agent` install command and a note that `lua-language-server` is downloaded automatically on first run

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

