## ADDED Requirements

### Requirement: Avante claude provider configured
`avante.nvim` SHALL be configured with a `claude` provider that uses the Claude API, reading the key from the `ANTHROPIC_API_KEY` environment variable and defaulting to the `claude-3-5-haiku-20241022` model for cost-effectiveness.

#### Scenario: Claude provider uses ANTHROPIC_API_KEY
- **WHEN** avante is switched to the `claude` provider and `ANTHROPIC_API_KEY` is set
- **THEN** it SHALL authenticate to the Claude API using that key
- **THEN** requests SHALL use the `claude-3-5-haiku-20241022` model unless overridden in `lua/plugins/avante.lua`

### Requirement: Keymap to open avante with claude provider
`<leader>ac` SHALL switch the active avante provider to `claude` and open the avante interface.

#### Scenario: Leader-ac switches to claude and opens
- **WHEN** `<leader>ac` is pressed
- **THEN** the avante provider SHALL be set to `claude`
- **THEN** the avante interface SHALL open

### Requirement: Keymap to open avante with current provider
`<leader>aa` SHALL open the avante interface without changing the active provider.

#### Scenario: Leader-aa opens with current provider
- **WHEN** `<leader>aa` is pressed
- **THEN** the avante interface SHALL open using whatever provider was last active
