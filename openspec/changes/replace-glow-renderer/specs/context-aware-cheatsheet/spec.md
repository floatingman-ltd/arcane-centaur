## MODIFIED Requirements

### Requirement: Float is dismissible and scrollable
The cheatsheet float SHALL be closed by pressing `q` or `<Esc>` while it is focused. The float SHALL support standard Neovim scroll keys (`Ctrl-d`, `Ctrl-u`, `j`, `k`) for navigating long content. Prose in the float SHALL wrap at word boundaries with no orphaned words, and SHALL reflow when the window is resized.

#### Scenario: Dismiss with q
- **WHEN** the cheatsheet float is focused and the user presses `q`
- **THEN** the float closes and focus returns to the previous window

#### Scenario: Dismiss with Esc
- **WHEN** the cheatsheet float is focused and the user presses `<Esc>`
- **THEN** the float closes and focus returns to the previous window

#### Scenario: Content is scrollable
- **WHEN** the cheatsheet float contains more lines than the window height
- **THEN** the user can scroll through all content using `j`/`k` or `Ctrl-d`/`Ctrl-u`

#### Scenario: Prose wraps without orphaned words
- **WHEN** the cheatsheet float displays a paragraph longer than its width
- **THEN** each line is filled to the available width before wrapping
- **AND** no line contains a single word that would have fitted on the previous line

#### Scenario: Content reflows on resize
- **WHEN** the editor is resized while the cheatsheet float is open
- **THEN** the content re-wraps to the new width

### Requirement: Content files are maintained as plain Markdown
All cheatsheet and guide content SHALL live in plain Markdown files under `cheatsheets/` and `guides/` at the repository root. The files ARE independently maintained from the AsciiDoc / Antora site. Prose in these files SHALL be written as one line per paragraph, without hard-wrapped line breaks, because the renderer reflows text to the float's width.

#### Scenario: cheatsheets/core.md exists and is readable
- **WHEN** the repository is cloned
- **THEN** `cheatsheets/core.md` exists and contains the universal keybinding reference in standard Markdown

#### Scenario: Per-language cheatsheet files exist for all registered filetypes
- **WHEN** a filetype is registered in the Lua mapping table
- **THEN** the corresponding `cheatsheets/<name>.md` file exists in the repository

#### Scenario: Paragraphs are single lines
- **WHEN** a prose paragraph is added to any file under `cheatsheets/`
- **THEN** it is written as a single line, with no hard-wrapped breaks inside the paragraph
