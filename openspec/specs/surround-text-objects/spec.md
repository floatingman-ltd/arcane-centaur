# surround-text-objects Specification

## Purpose
TBD - created by archiving change 04-modernize-editing-plugins. Update Purpose after archive.
## Requirements
### Requirement: Surround operations via nvim-surround
Add/change/delete-surrounding operations SHALL be provided by `kylechui/nvim-surround`, replacing `vim-surround`, using the `ys`/`cs`/`ds` mnemonics and providing native dot-repeat (no dependency on vim-repeat for surround).

#### Scenario: Add a surrounding pair
- **WHEN** the user runs `ysiw"` on a word
- **THEN** the word SHALL be wrapped in double quotes

#### Scenario: Change a surrounding pair
- **WHEN** the cursor is inside `"text"` and the user runs `cs"'`
- **THEN** the double quotes SHALL become single quotes

#### Scenario: Delete a surrounding pair
- **WHEN** the cursor is inside `(text)` and the user runs `ds(`
- **THEN** the parentheses SHALL be removed

#### Scenario: Surround repeats with dot
- **WHEN** the user performs a surround operation and then presses `.`
- **THEN** the operation SHALL repeat without requiring vim-repeat

#### Scenario: vim-surround removed
- **WHEN** Neovim finishes loading plugins
- **THEN** `:Lazy` SHALL NOT list `vim-surround`

