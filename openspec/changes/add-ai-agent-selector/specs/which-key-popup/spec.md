## MODIFIED Requirements

### Requirement: Group labels for prefix clusters
Multi-key `<leader>` prefixes SHALL be labelled as named groups in the popup. The `<leader>gc` group label SHALL be the selected AI agent's name from `config.ai_agent`, in both normal and visual mode.

#### Scenario: Claude group
- **WHEN** Claude is selected and the user presses `<leader>g` and pauses
- **THEN** the popup shows a group labelled "Claude" containing `<leader>gc*` keymaps

#### Scenario: Copilot group
- **WHEN** Copilot is selected and the user presses `<leader>g` and pauses
- **THEN** the popup shows a group labelled "Copilot" containing `<leader>gc*` keymaps

#### Scenario: OpenSpec group
- **WHEN** the user presses `<leader>o` and pauses
- **THEN** the popup shows a group labelled "OpenSpec" containing `<leader>os*` keymaps
