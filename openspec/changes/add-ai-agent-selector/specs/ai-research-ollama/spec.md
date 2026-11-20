## MODIFIED Requirements

### Requirement: Avante ollama provider configured
`avante.nvim` SHALL be configured with an `ollama` provider pointing to
`http://127.0.0.1:11434`. The default model SHALL be `qwen2.5:0.5b` (a small model chosen so it
runs on limited-RAM machines). The ollama provider SHALL be avante's default active provider on startup on every machine. It SHALL be the **only** provider when Claude is selected by `config.ai_agent`. When Copilot is selected, a `copilot` provider SHALL also be available (see `avante-runtime`).

#### Scenario: Avante starts with ollama provider
- **WHEN** Neovim starts and avante.nvim is loaded
- **THEN** the active provider SHALL be `ollama` with model `qwen2.5:0.5b`
- **THEN** requests SHALL be sent to `http://127.0.0.1:11434`
