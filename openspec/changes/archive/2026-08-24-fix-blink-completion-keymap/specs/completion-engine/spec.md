## MODIFIED Requirements

### Requirement: Completion ergonomics preserved

The completion menu SHALL use a single keymap that behaves identically in insert mode and on the command line. `<CR>` SHALL NOT be bound to accept a completion in either mode, preserving the no-auto-select behavior: opening the menu SHALL NOT highlight or insert any item, and a completion SHALL only be committed by an explicit accept keystroke.

The shared keymap SHALL be:

| Key | Action |
|---|---|
| `<C-n>` | Show the completion menu when it is closed; select the next item when it is open |
| `<C-p>` | Select the previous item |
| `<C-y>` | Accept the selected item, or the top item when none is selected |
| `<C-e>` | Cancel — dismiss the menu and restore the typed text |
| `<C-k>` | Show the documentation window for the selected item |
| `<C-b>` / `<C-f>` | Scroll the documentation window up / down |

The manual trigger SHALL be a plain `Ctrl`-plus-letter chord rather than a chord involving `Alt` or `Space`, both of which the host console reserves.

#### Scenario: Enter never accepts a completion

- **WHEN** the completion menu is visible in insert mode and the user presses `<CR>`
- **THEN** a newline SHALL be inserted
- **AND** no completion item SHALL be accepted, whether or not an item is highlighted

#### Scenario: Navigate and accept

- **WHEN** the menu is visible and the user presses `<C-n>` then `<C-y>`
- **THEN** the next item SHALL be selected and accepted

#### Scenario: The trigger key opens the menu without selecting

- **WHEN** the completion menu is closed and the user presses `<C-n>`
- **THEN** the menu SHALL open
- **AND** no item SHALL be highlighted

#### Scenario: The trigger key selects once the menu is open

- **WHEN** the completion menu is already open and the user presses `<C-n>`
- **THEN** the next item SHALL be selected
- **AND** the menu SHALL NOT be re-opened or reset

#### Scenario: Accept without navigating

- **WHEN** the menu is visible with no item highlighted and the user presses `<C-y>`
- **THEN** the top item SHALL be accepted

#### Scenario: Cancel restores the typed text

- **WHEN** the menu is visible and the user presses `<C-e>`
- **THEN** the menu SHALL be dismissed
- **AND** the text the user typed SHALL be restored

#### Scenario: Scroll the documentation window

- **WHEN** the user presses `<C-b>` or `<C-f>` with the documentation window visible
- **THEN** it SHALL respectively scroll up and scroll down

#### Scenario: The documentation window is reachable

Keys that scroll the documentation window are meaningless if the window can never open. The
configuration SHALL provide at least one way to open it.

- **WHEN** the user selects a completion item whose source supplies documentation
- **THEN** the documentation window SHALL become visible without requiring a keystroke
- **AND** the user SHALL also be able to open it explicitly with `<C-k>`

#### Scenario: Switching the documentation window between timed and on-demand

- **WHEN** the user runs `:BlinkDocsToggle`
- **THEN** the automatic documentation window SHALL be enabled or disabled for the current session
- **AND** the new state SHALL be reported to the user
- **AND** `<C-k>` SHALL continue to open the window in either state
- **AND** a new session SHALL start with the automatic window enabled

#### Scenario: The manual trigger reaches Neovim under WSL

- **WHEN** the user presses the manual completion trigger in a Windows-hosted console under WSL
- **THEN** the keystroke SHALL reach Neovim and open the completion menu
- **AND** the trigger SHALL NOT be a combination the host console reserves for itself, such as `Alt-Space` or `Ctrl-Space`

#### Scenario: Documented keys match the configuration

- **WHEN** a keymap documented for the completion menu is pressed
- **THEN** it SHALL perform the documented action
- **AND** no documentation surface SHALL assert a completion keybinding that is not bound in `lua/plugins/blink.lua`

### Requirement: Command-line completion

blink.cmp SHALL complete on the command line: search (`/`, `?`) from buffer words, and Ex command-line (`:`) from filesystem paths and Ex commands. The command line SHALL use the same completion keymap as insert mode rather than a separate preset, and `<CR>` SHALL remain bound to executing the command.

#### Scenario: Ex command-line completion

- **WHEN** the user types `:` followed by a partial path or command
- **THEN** path and command candidates SHALL be offered

#### Scenario: Search completion

- **WHEN** the user types `/` followed by a partial word
- **THEN** buffer-word candidates SHALL be offered

#### Scenario: Accept key is the same on the command line

- **WHEN** the completion menu is visible at the `:` prompt and the user presses `<C-y>`
- **THEN** the selected candidate SHALL be accepted into the command line
- **AND** the same key SHALL accept in insert mode

#### Scenario: Enter still executes the command

- **WHEN** the completion menu is visible at the `:` prompt and the user presses `<CR>`
- **THEN** the command line SHALL be executed
