## Purpose

Provide offline, local AI assistance in `avante.nvim` through an Ollama provider at
`http://127.0.0.1:11434`, so chat/research works without external API keys, accounts, or network
access. Ollama is avante's only provider.
## Requirements
### Requirement: Avante ollama provider configured
`avante.nvim` SHALL be configured with an `ollama` provider pointing to
`http://127.0.0.1:11434`. The default model SHALL be `qwen2.5:0.5b` (a small model chosen so it
runs on limited-RAM machines). The ollama provider SHALL be avante's **only** provider and the
default active provider on startup.

#### Scenario: Avante starts with ollama provider
- **WHEN** Neovim starts and avante.nvim is loaded
- **THEN** the active provider SHALL be `ollama` with model `qwen2.5:0.5b`
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

