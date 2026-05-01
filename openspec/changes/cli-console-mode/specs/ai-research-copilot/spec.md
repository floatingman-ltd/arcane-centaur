## ADDED Requirements

### Requirement: Avante copilot provider configured
`avante.nvim` SHALL be configured with a `copilot` provider that uses the existing
`github/copilot.vim` authentication. No additional API key or credential configuration
SHALL be required.

#### Scenario: Copilot provider uses existing auth
- **WHEN** avante is switched to the `copilot` provider
- **THEN** it SHALL authenticate via the credentials already held by `github/copilot.vim`
- **THEN** no separate login or token prompt SHALL appear

### Requirement: Keymap to open avante with copilot provider
`<leader>ac` SHALL switch the active avante provider to `copilot` and open the avante
interface.

#### Scenario: Leader-ac switches to copilot and opens
- **WHEN** `<leader>ac` is pressed
- **THEN** the avante provider SHALL be set to `copilot`
- **THEN** the avante interface SHALL open

### Requirement: Keymap to open avante with current provider
`<leader>aa` SHALL open the avante interface without changing the active provider.

#### Scenario: Leader-aa opens with current provider
- **WHEN** `<leader>aa` is pressed
- **THEN** the avante interface SHALL open using whatever provider was last active
