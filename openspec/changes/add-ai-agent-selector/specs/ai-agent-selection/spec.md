## ADDED Requirements

### Requirement: Agent selected by environment variable
`lua/config/ai_agent.lua` SHALL read `$NVIM_AI_AGENT` once at startup, case-insensitively. Unset, empty or `claude` SHALL select Claude, and `copilot` SHALL select GitHub Copilot. Any other value SHALL raise a `vim.notify` warning naming the value and SHALL select Claude.

#### Scenario: Unset selects Claude
- **WHEN** Neovim starts with `$NVIM_AI_AGENT` unset
- **THEN** `require("config.ai_agent").name` SHALL be `"claude"` and no warning SHALL be shown

#### Scenario: Copilot selected
- **WHEN** Neovim starts with `NVIM_AI_AGENT=Copilot`
- **THEN** `require("config.ai_agent").name` SHALL be `"copilot"`

#### Scenario: Unrecognised value
- **WHEN** Neovim starts with `NVIM_AI_AGENT=gemini`
- **THEN** a warning naming `gemini` SHALL be shown and the selected agent SHALL be `"claude"`

### Requirement: Exactly one agent active per session
Only the selected agent's plugins SHALL load and only its `<leader>gc` maps and user commands SHALL exist. The other agent's plugins, commands and maps SHALL be absent.

#### Scenario: Claude session has no Copilot surface
- **WHEN** Claude is selected
- **THEN** `copilot.vim` SHALL NOT be loaded, `:CopilotSuggest` SHALL NOT exist, and no `<leader>gc` map description SHALL begin with `Copilot`

#### Scenario: Copilot session has no Claude surface
- **WHEN** Copilot is selected
- **THEN** `claudecode.nvim` SHALL NOT be loaded, `:ClaudeSuggest` and `:ClaudeCode` SHALL NOT exist, and no `<leader>gc` map description SHALL begin with `Claude`
