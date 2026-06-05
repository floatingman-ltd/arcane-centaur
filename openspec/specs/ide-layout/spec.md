# ide-layout Specification

## Purpose
Define the expected IDE layout experience in Neovim: a persistent full-width terminal panel at the bottom, nvim-tree file explorer on the left, and editor windows on the right. Covers terminal toggle behaviour, one-keystroke layout assembly, layout-preserving buffer deletion, and guardrails that keep the layout stable across normal editing operations.

## Requirements

### Requirement: Full-width terminal toggle
The terminal toggle (`<leader>t`) SHALL open the terminal in a full-width split at the bottom of the editor (`botright`), regardless of which window has focus when invoked.

#### Scenario: Toggle from the file tree
- **WHEN** the cursor is in the nvim-tree window and `<leader>t` is pressed
- **THEN** the terminal opens as a full-width bottom split, not inside the tree column

#### Scenario: Toggle from an editor window
- **WHEN** the cursor is in an editor window and `<leader>t` is pressed
- **THEN** the terminal opens as a full-width bottom split below all vertical splits

### Requirement: Persistent shell across toggles
The terminal toggle SHALL reuse a single shell buffer: closing the terminal window MUST NOT terminate the shell process, and reopening MUST redisplay the same buffer with its scrollback, history, and any running job intact.

#### Scenario: Toggle off and on
- **WHEN** the terminal is toggled closed and then toggled open again
- **THEN** the same shell session is shown with prior scrollback preserved

#### Scenario: Shell exited by user
- **WHEN** the user exits the shell (or wipes the terminal buffer) and toggles the terminal open
- **THEN** a new shell is started

### Requirement: Stable terminal height
The terminal window SHALL keep its height (15 lines) when other windows are opened or closed (`winfixheight`).

#### Scenario: Opening another split
- **WHEN** the terminal is visible and a new horizontal split is opened elsewhere
- **THEN** the terminal window remains 15 lines tall

### Requirement: One-keystroke IDE layout assembly
A keymap (`<leader>L`) SHALL assemble the IDE layout — nvim-tree on the left, editor on the right, full-width terminal at the bottom — and return focus to the editor window. The operation MUST be idempotent: invoking it when the layout (or part of it) already exists SHALL NOT create duplicate windows.

#### Scenario: Assemble from a plain editor session
- **WHEN** `<leader>L` is pressed in a session with only an editor window
- **THEN** nvim-tree opens on the left, the terminal opens full-width at the bottom, and focus is in the editor window

#### Scenario: Invoke when layout already assembled
- **WHEN** `<leader>L` is pressed while tree and terminal are already visible
- **THEN** no additional windows are created and focus is in the editor window

### Requirement: Layout-preserving buffer delete
A `:Bd` user command SHALL delete the current buffer while keeping its window open (showing another listed buffer, or an empty one), so the window layout survives.

#### Scenario: Delete a buffer in the assembled layout
- **WHEN** `:Bd` is run in the editor window while tree and terminal are visible
- **THEN** the buffer is deleted, the editor window remains, and nvim-tree stays at its configured width

### Requirement: Tree never left as the last window
When quitting would leave only the nvim-tree window (and/or the terminal panel) on screen, those windows SHALL be closed as well so nvim-tree never remains expanded to full width.

#### Scenario: Quit the last editor window
- **WHEN** `:q` is run in the only editor window while nvim-tree (and optionally the terminal) is open
- **THEN** Neovim does not leave nvim-tree as a lone full-width window

#### Scenario: Quit with multiple editor windows open
- **WHEN** `:q` is run in one of several editor windows
- **THEN** only that window closes and the remaining layout is untouched

### Requirement: Floating UIs unaffected
The IDE layout SHALL NOT alter the behavior or extent of floating windows (Glow previews, which-key hints, Conjure HUD/eval popups, cheatsheet popups, Claude CLI scratch window).

#### Scenario: Popup over the assembled layout
- **WHEN** a Glow preview or which-key hint is triggered while the IDE layout is assembled
- **THEN** the float renders above the splits at its usual size and position
