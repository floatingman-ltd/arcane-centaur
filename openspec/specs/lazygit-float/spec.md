# lazygit-float Specification

## Purpose
Define how LazyGit runs inside Neovim: a floating terminal opened on the current repository or the current file's history, files edited from LazyGit opening in the same Neovim, colours taken from the active TokyoNight style, editor state refreshed when LazyGit exits, and the user's own LazyGit configuration left in effect and untouched.
## Requirements
### Requirement: LazyGit opens in a floating terminal for the current repository

The config SHALL provide `<leader>gg` and `:LazyGit` to open `lazygit` in a centred floating terminal window over the editor. The LazyGit process SHALL run with its working directory at the root of the git repository containing the current buffer's file, or, if the buffer has no file or is not in a repository, the repository containing Neovim's working directory.

#### Scenario: Open from a file in a repository
- **WHEN** the current buffer is a file inside a git repository and the user presses `<leader>gg`
- **THEN** a floating window opens showing LazyGit for that repository's root

#### Scenario: Buffer outside a repository, cwd inside one
- **WHEN** the current buffer has no file, or its file is not in a repository, and Neovim's working directory is inside a repository
- **THEN** LazyGit opens for the repository containing the working directory

#### Scenario: No repository found
- **WHEN** neither the buffer's file nor Neovim's working directory is inside a git repository
- **THEN** a warning is shown and no window opens

### Requirement: LazyGit opens on the current file's history

The config SHALL provide `<leader>gf` and `:LazyGitFile` to open LazyGit filtered to the commits that touched the current buffer's file.

#### Scenario: Open file history
- **WHEN** the current buffer is a tracked file and the user presses `<leader>gf`
- **THEN** LazyGit opens with its commit list filtered to that file

#### Scenario: Buffer has no file
- **WHEN** the current buffer has no file and the user presses `<leader>gf`
- **THEN** a warning is shown and no window opens

### Requirement: LazyGit keys reach LazyGit

Inside the LazyGit float, `<Esc>` SHALL be delivered to LazyGit rather than switching the terminal to normal mode. This SHALL NOT change `<Esc>` in other terminal buffers.

#### Scenario: Escape cancels inside LazyGit
- **WHEN** a LazyGit menu or prompt is open in the float and the user presses `<Esc>`
- **THEN** LazyGit closes the menu or prompt and the terminal stays in terminal mode

#### Scenario: Escape in another terminal is unchanged
- **WHEN** the user presses `<Esc>` in the `<leader>T` terminal split
- **THEN** the terminal switches to normal mode as before

### Requirement: Editing a file from LazyGit uses the outer Neovim

When the user asks LazyGit to edit a file, the file SHALL open in the Neovim instance that launched LazyGit, in the window that was current before the float opened, and the float SHALL close. No nested Neovim SHALL start.

#### Scenario: Edit a file
- **WHEN** the user selects a file in LazyGit and presses `e`
- **THEN** the float closes and the file is open in the previously current window of the outer Neovim

#### Scenario: Edit at a line
- **WHEN** the user triggers an edit at a specific line from LazyGit (e.g. from a diff hunk)
- **THEN** the file opens in the outer Neovim with the cursor on that line

#### Scenario: Path with a space
- **WHEN** the edited file's path contains a space
- **THEN** that file opens, not a file named after part of the path

### Requirement: User LazyGit config is preserved

Settings applied by this config SHALL be passed only to the LazyGit process launched from Neovim. The user's own LazyGit configuration SHALL still be loaded and SHALL NOT be modified.

#### Scenario: User settings still apply
- **WHEN** the user's LazyGit `config.yml` sets an option this config does not set
- **THEN** LazyGit launched from Neovim honours that option

#### Scenario: Standalone LazyGit unaffected
- **WHEN** the user runs `lazygit` from a shell outside Neovim
- **THEN** it behaves as it did before this change, and the user's `config.yml` is byte-identical to before

### Requirement: LazyGit colours follow the active TokyoNight style

When the active colorscheme is TokyoNight and the terminal supports truecolor, LazyGit SHALL be coloured from that style's palette. Otherwise LazyGit's default colours SHALL be used.

#### Scenario: TokyoNight active
- **WHEN** the colorscheme is `tokyonight-<style>` and LazyGit is opened
- **THEN** LazyGit's borders and selected-line colour come from that style's palette

#### Scenario: Style changed
- **WHEN** the `style` in `lua/plugins/colorscheme.lua` is changed and Neovim restarted
- **THEN** the next LazyGit launch uses the new style's colours

#### Scenario: Console mode
- **WHEN** Neovim is running in console mode (no truecolor)
- **THEN** LazyGit opens with its default colours and no error

### Requirement: Editor state refreshes when LazyGit closes

When the LazyGit process exits, the config SHALL reload buffers whose files changed on disk and refresh gitsigns and nvim-tree if they are loaded.

#### Scenario: Checkout changes an open file
- **WHEN** a file is open in a buffer, and in LazyGit the user checks out a branch where that file differs, then quits LazyGit
- **THEN** the buffer shows the checked-out content without a manual `:e`

#### Scenario: Commit clears gutter signs
- **WHEN** a buffer shows gitsigns change markers, and the user commits those changes in LazyGit and quits
- **THEN** the change markers are gone

#### Scenario: Tree reflects new files
- **WHEN** nvim-tree is open and an action in LazyGit adds or removes files, then LazyGit quits
- **THEN** nvim-tree shows the current file list

### Requirement: Missing LazyGit is reported

If `lazygit` is not executable, the keymaps and commands SHALL show an error naming `lazygit` and the getting-started guide, and SHALL NOT open a window.

#### Scenario: Binary missing
- **WHEN** `lazygit` is not on `$PATH` and the user presses `<leader>gg`
- **THEN** an error is shown and no float or terminal buffer is created

