## ADDED Requirements

### Requirement: claudecode.nvim loads only when Claude is selected
`coder/claudecode.nvim` SHALL load, and its `<leader>gcc/gcf/gcb/gcv/gca/gcr` maps SHALL be bound, only when `config.ai_agent` selects Claude.

#### Scenario: Claude selected
- **WHEN** `$NVIM_AI_AGENT` is unset
- **THEN** `<leader>gcc` SHALL toggle a Claude Code session exactly as before this change

#### Scenario: Copilot selected
- **WHEN** `NVIM_AI_AGENT=copilot`
- **THEN** `:ClaudeCode` SHALL NOT exist and none of claudecode's maps SHALL be bound
