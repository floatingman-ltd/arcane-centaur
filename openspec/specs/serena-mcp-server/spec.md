## ADDED Requirements

### Requirement: OpenCode MCP declaration
`opencode.json` in the repo root SHALL declare Serena as a local MCP server so that OpenCode can use its semantic code-intelligence tools.

#### Scenario: Server starts with OpenCode
- **WHEN** OpenCode is launched in this directory
- **THEN** it SHALL start Serena via `serena start-mcp-server --context ide --project-from-cwd` and make its tools available

#### Scenario: Serena not installed
- **WHEN** the `serena` binary is not on `$PATH`
- **THEN** OpenCode SHALL log the failure and continue without Serena's tools; no editor crash

### Requirement: OpenCode launch command configuration
The Serena entry in `opencode.json` SHALL use the `serena` binary (installed via `uv tool install serena-agent`) with the `ide` context and `--project-from-cwd` so the `.serena/project.yml` in the repo root is picked up automatically.

#### Scenario: ide context active
- **WHEN** Serena starts under the `ide` context
- **THEN** basic file/search/shell tools are suppressed in favour of OpenCode's built-ins, and semantic tools (find_symbol, rename_symbol, replace_symbol_body, etc.) are exposed

### Requirement: Copilot MCP declaration
`lua/plugins/copilot.lua` SHALL declare Serena in `vim.g.copilot_mcp_servers` so that `copilot.vim` can also route code-intelligence requests to it.

#### Scenario: Global binary preferred
- **WHEN** `serena` is found on `$PATH`
- **THEN** the config SHALL spawn it directly to avoid startup latency

#### Scenario: Serena not running
- **WHEN** Serena is not installed or not reachable
- **THEN** `copilot.vim` SHALL skip the server gracefully with no editor error

### Requirement: Serena project configuration
A `.serena/project.yml` SHALL exist in the repo root declaring `project_name: nvim` and `languages: [lua]` so the Lua language server is started automatically for both integrations.

#### Scenario: Lua LSP auto-download
- **WHEN** Serena starts and `lua-language-server` is not on `$PATH`
- **THEN** Serena SHALL download it automatically; no manual installation step is required

### Requirement: Documentation
Installation prerequisites (`uv`, `serena-agent`) SHALL be documented in `readme.md` and `docs/guides/ai-tools.md`.

#### Scenario: Readme documents prerequisites
- **WHEN** a user reads the Serena section of `readme.md`
- **THEN** they SHALL find the `uv tool install -p 3.13 serena-agent@latest --prerelease=allow` install command and a note that `lua-language-server` is downloaded automatically on first run
