## ADDED Requirements

### Requirement: Copilot suggest and explain commands
When Copilot is selected, `:CopilotSuggest` and `:CopilotExplain` SHALL send the command range, the active visual selection, or the whole buffer when neither applies, to the `copilot` CLI in non-interactive prompt mode. They SHALL show the response in a floating scratch window that closes with `q` or `<Esc>`.

#### Scenario: Suggest with visual selection
- **WHEN** the user selects lines and runs `:CopilotSuggest`
- **THEN** the selected text SHALL be sent with a "suggest a shell command" prompt and the response SHALL appear in a float titled `copilot suggest`

#### Scenario: Explain whole buffer
- **WHEN** the user runs `:CopilotExplain` with no range and no active selection
- **THEN** the whole buffer SHALL be sent with an "explain this code" prompt and the response SHALL appear in a float

#### Scenario: copilot CLI not installed
- **WHEN** `copilot` is not on `$PATH`
- **THEN** a `vim.notify` error SHALL name the install command and no window SHALL open

#### Scenario: CLI failure
- **WHEN** the `copilot` process exits non-zero
- **THEN** a `vim.notify` error SHALL show the exit code and stderr

### Requirement: Copilot one-shot keymaps
When Copilot is selected, `<leader>gcs` SHALL run `:CopilotSuggest` and `<leader>gce` SHALL run `:CopilotExplain`, in normal and visual mode.

#### Scenario: Visual explain keymap
- **WHEN** the user selects code and presses `<leader>gce`
- **THEN** `:CopilotExplain` SHALL run on the selected lines
