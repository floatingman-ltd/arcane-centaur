## MODIFIED Requirements

### Requirement: Group labels for prefix clusters
Multi-key `<leader>` prefixes SHALL be labelled as named groups in the popup.

#### Scenario: Claude group
- **WHEN** the user presses `<leader>g` and pauses
- **THEN** the popup shows a group labelled "Claude" containing `<leader>gc*` keymaps

#### Scenario: OpenSpec group
- **WHEN** the user presses `<leader>o` and pauses
- **THEN** the popup shows a group labelled "OpenSpec" containing `<leader>os*` keymaps
