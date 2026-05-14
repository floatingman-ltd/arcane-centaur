# git-diff-view Specification

## Purpose
TBD - created by archiving change add-diffview. Update Purpose after archive.
## Requirements
### Requirement: Side-by-side diff view for working tree changes
The plugin SHALL open a tabbed diff panel showing all changed files side-by-side via `:DiffviewOpen`. The panel SHALL list changed files in a file panel on the left and render a two-pane diff on the right.

#### Scenario: Open diff view from keymap
- **WHEN** the user presses `<leader>gD` in normal mode
- **THEN** Neovim opens a new tab with the diffview panel showing all unstaged and staged changes

#### Scenario: Open diff view against a specific ref
- **WHEN** the user runs `:DiffviewOpen HEAD~3`
- **THEN** diffview opens showing all changes between HEAD~3 and the working tree

#### Scenario: Close diff view from keymap
- **WHEN** the user presses `<leader>gX` in normal mode
- **THEN** the diffview tab closes and focus returns to the previous buffer

### Requirement: Per-file commit history with diffs
The plugin SHALL display a file's git history with per-commit diffs via `:DiffviewFileHistory`. When invoked on the current file, the history panel SHALL list commits that touched that file.

#### Scenario: Open file history from keymap
- **WHEN** the user presses `<leader>gH` in normal mode while editing a file
- **THEN** diffview opens a history panel listing commits that changed the current file

#### Scenario: View diff for a history entry
- **WHEN** the user selects a commit in the history panel
- **THEN** the right pane renders the diff for that commit on the current file

### Requirement: Plugin lazy-loaded on commands
The plugin SHALL be registered with lazy.nvim using `cmd` lazy-loading so it does not add startup time.

#### Scenario: Plugin not loaded at startup
- **WHEN** Neovim starts without invoking any diffview command or keymap
- **THEN** diffview.nvim is NOT loaded into memory (`:Lazy` shows it as not loaded)

#### Scenario: Plugin loads on first keymap use
- **WHEN** the user presses `<leader>gD` for the first time in a session
- **THEN** diffview.nvim loads and the diff view opens without error

### Requirement: Keybindings documented in git cheatsheet
All diffview keymaps SHALL be listed in `docs/cheatsheets/git.md` under a dedicated diffview.nvim section.

#### Scenario: Cheatsheet contains diffview section
- **WHEN** a user reads `docs/cheatsheets/git.md`
- **THEN** they find a section titled "diffview.nvim" with rows for `<leader>gD`, `<leader>gH`, and `<leader>gX`

