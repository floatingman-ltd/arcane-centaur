## ADDED Requirements

### Requirement: Suggest command
The plugin SHALL provide a `:CopilotSuggest` command that passes the current visual selection (or whole buffer when no selection is active) as context to `gh copilot suggest` and displays the response in a floating scratch window.

#### Scenario: Suggest with visual selection
- **WHEN** the user selects lines in visual mode and runs `:CopilotSuggest`
- **THEN** the selected text is sent to `gh copilot suggest` and the response is shown in a floating window

#### Scenario: Suggest with no selection
- **WHEN** the user runs `:CopilotSuggest` with no active visual selection
- **THEN** the entire buffer content is sent to `gh copilot suggest` and the response is shown in a floating window

#### Scenario: gh CLI not installed
- **WHEN** `gh` is not found on `$PATH`
- **THEN** the system SHALL emit a `vim.notify` error and abort without opening a window

### Requirement: Explain command
The plugin SHALL provide a `:CopilotExplain` command that sends the current visual selection (or whole buffer) to `gh copilot explain` and displays the explanation in a floating scratch window.

#### Scenario: Explain selected code
- **WHEN** the user selects code and runs `:CopilotExplain`
- **THEN** the selected text is sent to `gh copilot explain` and the explanation is shown in a floating window

#### Scenario: Explain whole buffer
- **WHEN** `:CopilotExplain` is run with no selection
- **THEN** the buffer content is sent and the explanation is shown

### Requirement: Keymap bindings
The integration SHALL expose `<leader>gcs` for suggest and `<leader>gce` for explain in normal and visual mode via `lua/keymaps.lua`.

#### Scenario: Normal mode suggest keymap
- **WHEN** the user presses `<leader>gcs` in normal mode
- **THEN** `:CopilotSuggest` is triggered with the full buffer

#### Scenario: Visual mode explain keymap
- **WHEN** the user presses `<leader>gce` in visual mode
- **THEN** `:CopilotExplain` is triggered with the selected lines
