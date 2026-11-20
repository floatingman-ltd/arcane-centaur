## ADDED Requirements

### Requirement: Claude one-shot commands only when Claude is selected
`:ClaudeSuggest`, `:ClaudeExplain` and their `<leader>gcs`/`<leader>gce` maps SHALL be registered only when `config.ai_agent` selects Claude.

#### Scenario: Copilot selected
- **WHEN** `NVIM_AI_AGENT=copilot`
- **THEN** `:ClaudeSuggest` SHALL NOT exist and `<leader>gcs` SHALL run `:CopilotSuggest`
