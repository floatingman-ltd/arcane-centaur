## ADDED Requirements

### Requirement: Cheatsheet float opens from any buffer
Pressing `<leader>?` in Normal mode SHALL open a centred, bordered floating window containing the context-aware cheatsheet content. The float SHALL be reachable from any buffer regardless of filetype.

#### Scenario: Open cheatsheet from a generic buffer
- **WHEN** the user presses `<leader>?` in a Normal-mode buffer with no recognised filetype
- **THEN** a floating window opens containing the universal core section only

#### Scenario: Open cheatsheet from a Lisp buffer
- **WHEN** the user presses `<leader>?` in a buffer with filetype `lisp`, `clojure`, `scheme`, or `fennel`
- **THEN** a floating window opens containing the universal core section followed by the Lisp/Conjure/vim-sexp section

#### Scenario: Open cheatsheet from an F# buffer
- **WHEN** the user presses `<leader>?` in a buffer with filetype `fsharp`
- **THEN** a floating window opens containing the universal core section followed by the F# / iron.nvim section

#### Scenario: Open cheatsheet from a Haskell buffer
- **WHEN** the user presses `<leader>?` in a buffer with filetype `haskell`
- **THEN** a floating window opens containing the universal core section followed by the Haskell / haskell-tools section

#### Scenario: Open cheatsheet from a Markdown buffer
- **WHEN** the user presses `<leader>?` in a buffer with filetype `markdown`
- **THEN** a floating window opens containing the universal core section followed by the Markdown workflow section

### Requirement: Universal core section always present
The floating window SHALL always display a universal core section covering LSP bindings, window/split navigation, git (fugitive, gitsigns, diffview), GitHub Copilot, visual editing, system clipboard, formatting, and auto-completion.

#### Scenario: Core content visible regardless of filetype
- **WHEN** the cheatsheet float is opened from any buffer
- **THEN** LSP keybindings (gd, K, gr, leader+rn, leader+ca, leader+e, [d, ]d) are present in the float content

#### Scenario: Core content visible for unknown filetype
- **WHEN** the cheatsheet float is opened from a buffer whose filetype has no mapping (e.g. `text`, `sh`, ``)
- **THEN** the float displays core content and no language-specific section

### Requirement: Language section appended for known filetypes
For filetypes with a registered cheatsheet file the float SHALL append that file's content after the core section. Multiple filetypes MAY map to the same cheatsheet file (e.g. `lisp`, `clojure`, `scheme`, `fennel` all map to `cheatsheets/lisp.md`).

#### Scenario: Filetype mapping resolves to correct file
- **WHEN** the user opens the cheatsheet in a `janet` buffer
- **THEN** the content from `cheatsheets/janet.md` is appended below the core section
- **AND** content from other language files (lisp.md, fsharp.md, etc.) is NOT shown

#### Scenario: Multiple filetypes share one cheatsheet file
- **WHEN** the user opens the cheatsheet in a `scheme` buffer
- **THEN** the content from `cheatsheets/lisp.md` is shown (same as for `lisp` or `clojure` filetypes)

### Requirement: Mini-guide shortcuts visible and navigable
When the current filetype's mapping includes one or more guide slugs, the user SHALL be able to open a separate guide picker with `<leader>?g`. The picker SHALL list the registered guide slugs for the current buffer's filetype, and selecting one entry SHALL open the guide content in a new floating window.

#### Scenario: Guide picker lists guides for filetype with guides
- **WHEN** the user presses `<leader>?g` in a `lisp` buffer
- **THEN** a guide picker opens listing the registered guide slugs for `lisp`

#### Scenario: No guides are offered for filetype with empty guide list
- **WHEN** the user presses `<leader>?g` in a `scheme` buffer where the guide list is empty
- **THEN** no guide is opened and no selectable guide entries are presented

#### Scenario: Selecting a guide from the picker opens the guide
- **WHEN** the user presses `<leader>?g` and selects the first listed guide
- **THEN** a new float opens with the content of the selected guide file

#### Scenario: Cancelling the picker does nothing
- **WHEN** the user presses `<leader>?g` and dismisses the picker without selecting a guide
- **THEN** nothing happens; the current window state remains unchanged

### Requirement: Float is dismissible and scrollable
The cheatsheet float SHALL be closed by pressing `q` or `<Esc>` while it is focused. The float SHALL support standard Neovim scroll keys (`Ctrl-d`, `Ctrl-u`, `j`, `k`) for navigating long content.

#### Scenario: Dismiss with q
- **WHEN** the cheatsheet float is focused and the user presses `q`
- **THEN** the float closes and focus returns to the previous window

#### Scenario: Dismiss with Esc
- **WHEN** the cheatsheet float is focused and the user presses `<Esc>`
- **THEN** the float closes and focus returns to the previous window

#### Scenario: Content is scrollable
- **WHEN** the cheatsheet float contains more lines than the window height
- **THEN** the user can scroll through all content using `j`/`k` or `Ctrl-d`/`Ctrl-u`

### Requirement: Content files are maintained as plain Markdown
All cheatsheet and guide content SHALL live in plain Markdown files under `cheatsheets/` and `guides/` at the repository root. Files SHALL be glow-readable as a side-effect of their format. The files ARE independently maintained from the AsciiDoc / Antora site.

#### Scenario: cheatsheets/core.md exists and is readable
- **WHEN** the repository is cloned
- **THEN** `cheatsheets/core.md` exists and contains the universal keybinding reference in standard Markdown

#### Scenario: Per-language cheatsheet files exist for all registered filetypes
- **WHEN** a filetype is registered in the Lua mapping table
- **THEN** the corresponding `cheatsheets/<name>.md` file exists in the repository
