## ADDED Requirements

### Requirement: MCP server declaration
The config SHALL declare the Serena MCP server in `vim.g.copilot_mcp_servers` inside `lua/plugins/copilot.lua` so that `copilot.vim` can route code-intelligence requests to it.

#### Scenario: Server declared at startup
- **WHEN** Neovim starts and `copilot.vim` loads
- **THEN** `vim.g.copilot_mcp_servers` SHALL contain an entry for Serena with `stdio` transport and the correct launch command

#### Scenario: Serena not running
- **WHEN** Serena is not installed or not reachable
- **THEN** `copilot.vim` SHALL skip the server gracefully with no editor error

### Requirement: Launch command configuration
The Serena entry SHALL use `npx -y @oramasearch/serena` as the default launch command, with the workspace root (`vim.fn.getcwd()`) passed as the working directory.

#### Scenario: npx launch
- **WHEN** Copilot initiates an MCP request to Serena
- **THEN** the server process SHALL be spawned via `npx -y @oramasearch/serena` in the current workspace root

#### Scenario: Global install override
- **WHEN** `serena` is found on `$PATH` (global npm install)
- **THEN** the config SHALL prefer the global binary over `npx` to avoid startup latency

### Requirement: Documentation
Installation prerequisites (Node.js, `npx` or global serena package) SHALL be documented in `readme.md` and `docs/guides/ai-tools.md`.

#### Scenario: Readme documents prerequisites
- **WHEN** a user reads the Serena section of `readme.md`
- **THEN** they SHALL find the install command and a note about the Node.js requirement
