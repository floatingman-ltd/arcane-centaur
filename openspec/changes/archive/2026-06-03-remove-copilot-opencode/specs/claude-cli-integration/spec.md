## ADDED Requirements

### Requirement: Suggest command
The plugin SHALL provide a `:ClaudeSuggest` command that passes the current visual selection (or whole buffer when no selection is active) as context to the `claude` CLI (`claude -p`) and displays the response in a floating scratch window.

#### Scenario: Suggest with visual selection
- **WHEN** the user selects lines in visual mode and runs `:ClaudeSuggest`
- **THEN** the selected text is sent to `claude -p` with a "suggest a shell command" prompt and the response is shown in a floating window

#### Scenario: Suggest with no selection
- **WHEN** the user runs `:ClaudeSuggest` with no active visual selection
- **THEN** the entire buffer content is sent and the response is shown in a floating window

#### Scenario: claude CLI not installed
- **WHEN** `claude` is not found on `$PATH`
- **THEN** the system SHALL emit a `vim.notify` error and abort without opening a window

### Requirement: Explain command
The plugin SHALL provide a `:ClaudeExplain` command that sends the current visual selection (or whole buffer) to the `claude` CLI with an "explain this code" prompt and displays the explanation in a floating scratch window.

#### Scenario: Explain selected code
- **WHEN** the user selects code and runs `:ClaudeExplain`
- **THEN** the selected text is sent to `claude -p` and the explanation is shown in a floating window

#### Scenario: Explain whole buffer
- **WHEN** `:ClaudeExplain` is run with no selection
- **THEN** the buffer content is sent and the explanation is shown

### Requirement: Authentication
The commands SHALL rely on Claude Code's built-in authentication and SHALL NOT require an `ANTHROPIC_API_KEY` environment variable.

#### Scenario: No API key required
- **WHEN** the user runs `:ClaudeSuggest` or `:ClaudeExplain` with `claude` authenticated via Claude Code
- **THEN** the command succeeds without any `ANTHROPIC_API_KEY` being set

### Requirement: Keymap bindings
The integration SHALL expose `<leader>gcs` for suggest and `<leader>gce` for explain in normal and visual mode via `lua/keymaps.lua`.

#### Scenario: Normal mode suggest keymap
- **WHEN** the user presses `<leader>gcs` in normal mode
- **THEN** `:ClaudeSuggest` is triggered with the full buffer

#### Scenario: Visual mode explain keymap
- **WHEN** the user presses `<leader>gce` in visual mode
- **THEN** `:ClaudeExplain` is triggered with the selected lines
