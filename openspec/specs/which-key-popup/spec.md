## Purpose

Provides a context-sensitive popup (via `folke/which-key.nvim`) that displays available keymaps when the user pauses after a prefix key. Makes the full keymap surface discoverable without leaving the editor.

## Requirements

### Requirement: Popup appears on leader pause
When the user presses `<leader>` and pauses without typing a second key, a popup SHALL appear listing all available `<leader>` keymaps with their descriptions and group labels.

#### Scenario: Leader popup on pause
- **WHEN** the user presses `<leader>` and waits (default which-key delay)
- **THEN** a popup appears showing all registered `<leader>` keymaps with descriptions

#### Scenario: Popup disappears on continued typing
- **WHEN** the user continues typing a keymap sequence without pausing
- **THEN** the popup does not appear and the keymap executes normally

### Requirement: Group labels for prefix clusters
Multi-key `<leader>` prefixes SHALL be labelled as named groups in the popup.

#### Scenario: Claude group
- **WHEN** the user presses `<leader>g` and pauses
- **THEN** the popup shows a group labelled "Claude" containing `<leader>gc*` keymaps

#### Scenario: OpenSpec group
- **WHEN** the user presses `<leader>o` and pauses
- **THEN** the popup shows a group labelled "OpenSpec" containing `<leader>os*` keymaps

### Requirement: All keymaps have descriptions
Every keymap defined in the config SHALL have a `desc` field so the which-key popup is fully populated with no blank or raw-key entries for `<leader>` keymaps.

#### Scenario: No undescribed leader keymaps
- **WHEN** the which-key popup is open on `<leader>`
- **THEN** every entry shows a human-readable description, not a blank or raw command string
