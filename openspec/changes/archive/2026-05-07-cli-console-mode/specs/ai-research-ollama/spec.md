## ADDED Requirements

### Requirement: Avante ollama provider configured
`avante.nvim` SHALL be configured with an `ollama` vendor pointing to
`http://127.0.0.1:11434`. The default model SHALL be `llama3.1:8b`. The ollama provider
SHALL be the default active provider on startup.

#### Scenario: Avante starts with ollama provider
- **WHEN** Neovim starts and avante.nvim is loaded
- **THEN** the active provider SHALL be `ollama`
- **THEN** requests SHALL be sent to `http://127.0.0.1:11434`

### Requirement: Keymap to open avante with ollama provider
`<leader>ao` SHALL switch the active avante provider to `ollama` and open the avante
interface.

#### Scenario: Leader-ao switches to ollama and opens
- **WHEN** `<leader>ao` is pressed
- **THEN** the avante provider SHALL be set to `ollama`
- **THEN** the avante interface SHALL open

### Requirement: Ollama unavailability surfaced in avante buffer
If the ollama service is not reachable at request time, avante SHALL display the HTTP
error in its interface. Neovim SHALL not crash.

#### Scenario: Ollama service not running
- **WHEN** `<leader>ao` opens avante and a question is submitted
- **THEN** if the ollama endpoint is unreachable, an error SHALL be shown in the avante buffer
- **THEN** Neovim SHALL remain functional
