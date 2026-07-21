# ai-research-claude Specification

## Purpose
Avante.nvim's online research backend: a `claude` provider that talks to the Claude API (via `ANTHROPIC_API_KEY`), switchable with `<leader>ac`, alongside the offline ollama provider.
## Requirements
### Requirement: Keymap to open avante with current provider
`<leader>aa` SHALL open the avante interface without changing the active provider.

#### Scenario: Leader-aa opens with current provider
- **WHEN** `<leader>aa` is pressed
- **THEN** the avante interface SHALL open using whatever provider was last active

