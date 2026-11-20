## ADDED Requirements

### Requirement: Copilot CLI terminal session
When Copilot is selected, a `copilot` CLI session SHALL run in a native Neovim terminal split. `<leader>gcc` SHALL toggle the split's window without stopping the job, and `<leader>gcf` SHALL focus it, opening it first if needed. Only one session SHALL exist per Neovim instance.

#### Scenario: Toggle starts and hides the session
- **WHEN** the user presses `<leader>gcc` with no session running
- **THEN** a vertical split SHALL open running `copilot`
- **WHEN** the user presses `<leader>gcc` again
- **THEN** the split SHALL close and the `copilot` job SHALL keep running

#### Scenario: Focus reopens the same session
- **WHEN** the session window is closed and the user presses `<leader>gcf`
- **THEN** the split SHALL reopen on the same terminal buffer, in terminal-insert mode

#### Scenario: copilot CLI not installed
- **WHEN** `copilot` is not on `$PATH` and the user presses `<leader>gcc`
- **THEN** a `vim.notify` error SHALL name the missing binary and its install command, and no split SHALL open

### Requirement: Send context to the Copilot session
`<leader>gcb` SHALL type an `@` mention of the current buffer's path, relative to the cwd, into the session. Visual `<leader>gcv` SHALL type the selected lines into the session without submitting them. Both SHALL start the session if it is not running.

#### Scenario: Add buffer
- **WHEN** the user presses `<leader>gcb` in `lua/keymaps.lua`
- **THEN** `@lua/keymaps.lua ` SHALL appear on the session's input line

#### Scenario: Send selection
- **WHEN** the user selects lines and presses `<leader>gcv`
- **THEN** the selected text SHALL appear in the session input, and the visual `gc` comment operator SHALL NOT fire

### Requirement: No diff accept/reject maps under Copilot
`<leader>gca` and `<leader>gcr` SHALL NOT be mapped when Copilot is selected.

#### Scenario: Diff maps absent
- **WHEN** Copilot is selected and the user presses `<leader>gc` and pauses
- **THEN** the which-key popup SHALL NOT list `a` or `r` entries
