## ADDED Requirements

### Requirement: New change command
The integration SHALL provide a `:OpenspecNew` command that prompts for a change name and runs `openspec new change "<name>"`, displaying the result in a bottom split scratch buffer.

#### Scenario: Create new change
- **WHEN** the user runs `:OpenspecNew` and enters a name
- **THEN** `openspec new change "<name>"` is executed in the repo root and output is shown in a split

#### Scenario: Empty name rejected
- **WHEN** the user cancels the input prompt or submits an empty name
- **THEN** the command SHALL abort with no side effects

### Requirement: Status command
The integration SHALL provide a `:OpenspecStatus` command that runs `openspec status` (or `openspec status --change "<name>"` when a change name is supplied) and shows the output in a bottom split.

#### Scenario: Global status
- **WHEN** `:OpenspecStatus` is run with no argument
- **THEN** `openspec status` output is shown in a split

#### Scenario: Change-scoped status
- **WHEN** `:OpenspecStatus <name>` is run with a change name argument
- **THEN** `openspec status --change "<name>"` output is shown in a split

### Requirement: List command
The integration SHALL provide an `:OpenspecList` command that runs `openspec list` and shows available changes in a split.

#### Scenario: List all changes
- **WHEN** `:OpenspecList` is run
- **THEN** `openspec list` output is shown in a read-only split buffer

### Requirement: Keymap bindings
The integration SHALL expose `<leader>osn` (new), `<leader>oss` (status), `<leader>osl` (list) in normal mode via `lua/keymaps.lua`.

#### Scenario: Status keymap
- **WHEN** the user presses `<leader>oss`
- **THEN** `:OpenspecStatus` is triggered

#### Scenario: List keymap
- **WHEN** the user presses `<leader>osl`
- **THEN** `:OpenspecList` is triggered
