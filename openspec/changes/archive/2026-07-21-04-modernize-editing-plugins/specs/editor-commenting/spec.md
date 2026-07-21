## ADDED Requirements

### Requirement: Comment toggling via the native gc operator
Comment toggling SHALL be provided by Neovim's built-in `gc` operator (core since 0.10), and the `vim-commentary` plugin SHALL be removed. The user-facing interface (`gcc`, `gc{motion}`, visual-mode `gc`) SHALL be unchanged.

#### Scenario: Toggle the current line
- **WHEN** the user presses `gcc` in normal mode
- **THEN** the current line's comment state SHALL toggle using the buffer's comment syntax

#### Scenario: Toggle a motion or selection
- **WHEN** the user presses `gc` with a motion (e.g. `gcip`) or over a visual selection
- **THEN** the targeted lines' comment state SHALL toggle, and the operation SHALL be dot-repeatable

#### Scenario: vim-commentary removed
- **WHEN** Neovim finishes loading plugins
- **THEN** `:Lazy` SHALL NOT list `vim-commentary`, and `lua/plugins/vim-commentary.lua` SHALL NOT exist
