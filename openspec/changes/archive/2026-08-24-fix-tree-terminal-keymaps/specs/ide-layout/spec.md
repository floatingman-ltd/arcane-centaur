## MODIFIED Requirements

### Requirement: Full-width terminal toggle
The terminal toggle (`<leader>T`) SHALL open the terminal in a full-width split at the bottom of the editor (`botright`), regardless of which window has focus when invoked. `<leader>t` SHALL NOT toggle the terminal; it is reserved for the file tree toggle.

#### Scenario: Toggle from the file tree
- **WHEN** the cursor is in the nvim-tree window and `<leader>T` is pressed
- **THEN** the terminal opens as a full-width bottom split, not inside the tree column

#### Scenario: Toggle from an editor window
- **WHEN** the cursor is in an editor window and `<leader>T` is pressed
- **THEN** the terminal opens as a full-width bottom split below all vertical splits

#### Scenario: The old terminal key no longer opens a terminal
- **WHEN** `<leader>t` is pressed
- **THEN** the file tree SHALL toggle
- **AND** no terminal window SHALL be opened

## ADDED Requirements

### Requirement: File tree keymaps
The file tree SHALL be reachable by keymap without entering a command. `<leader>t` SHALL toggle the tree open and closed, and SHALL be the only toggle. `<leader>n` and `<C-n>` SHALL open the tree without closing it. No global `<C-t>` binding SHALL be provided, because nvim-tree claims `<C-t>` buffer-locally inside the tree window and a global mapping cannot close the tree from there. Every one of these keymaps SHALL carry a `desc` so which-key surfaces it, and SHALL match what the documentation states.

#### Scenario: Toggle the tree with the leader key

- **WHEN** `<leader>t` is pressed and the file tree is closed
- **THEN** the file tree SHALL open
- **WHEN** `<leader>t` is pressed again
- **THEN** the file tree SHALL close

#### Scenario: Open-only bindings do not close the tree

- **WHEN** `<leader>n` or `<C-n>` is pressed while the tree is already open
- **THEN** the tree SHALL remain open

#### Scenario: Documented tree keymaps match the configuration

- **WHEN** a file tree keymap documented in the guides or the `<leader>?` cheatsheet is pressed
- **THEN** it SHALL perform the documented action
- **AND** no documentation surface SHALL assert a file tree keybinding that is not bound in `lua/keymaps.lua`
