# markdown-native-rendering Specification

## Purpose
TBD - created by archiving change replace-glow-renderer. Update Purpose after archive.
## Requirements
### Requirement: Markdown renders in-editor without an external binary
Markdown SHALL be rendered inside Neovim, using the editor's own treesitter parsers, with no external binary invoked. No preview surface SHALL depend on the `glow` binary being present on `$PATH`, and no preview surface SHALL emit a "binary not found" notification.

#### Scenario: Preview works with no glow binary installed
- **WHEN** the user opens any markdown preview surface on a machine where `glow` is not on `$PATH`
- **THEN** the markdown SHALL render normally
- **AND** no warning about a missing binary SHALL be shown

#### Scenario: No external process is spawned
- **WHEN** a markdown preview surface is opened
- **THEN** rendering SHALL be performed in-editor
- **AND** no child process SHALL be spawned to produce the rendered output

### Requirement: Prose wraps correctly and reflows
Rendered prose SHALL wrap at word boundaries, at any window width, with no word placed alone on a line while the preceding line has room for it. Because wrapping is performed by the editor rather than baked into pre-rendered output, rendered content SHALL reflow when the window is resized.

#### Scenario: A long paragraph wraps without orphaned words
- **WHEN** a rendered surface displays a paragraph longer than the window width
- **THEN** every line SHALL be filled to the available width before wrapping
- **AND** no line SHALL contain a single word that would have fitted on the previous line

#### Scenario: Wrapping is correct at any width
- **WHEN** the same paragraph is rendered at several different window widths
- **THEN** each rendering SHALL wrap correctly
- **AND** correctness SHALL NOT depend on the chosen width

#### Scenario: Content reflows on resize
- **WHEN** the editor window is resized while a rendered surface is open
- **THEN** the content SHALL re-wrap to the new width

### Requirement: One rendering path serves every markdown surface
The cheatsheet, the mini-guides, and the forced popup preview SHALL share a single rendering entry point, so their behaviour cannot diverge. Each SHALL present the rendered markdown in a centred floating window with a border, dismissible with `q` or `<Esc>`.

#### Scenario: All surfaces render identically
- **WHEN** the same markdown content is displayed through the cheatsheet and through the popup preview
- **THEN** both SHALL render it identically

#### Scenario: Floats are consistently dismissible
- **WHEN** any of these floats is focused and the user presses `q` or `<Esc>`
- **THEN** the float SHALL close and focus SHALL return to the previous window

### Requirement: Tables remain legible
Rendered tables SHALL be visually distinguishable from surrounding prose, not presented as raw pipe-delimited text. A table wider than the float MAY wrap, since the editor cannot simultaneously wrap prose and scroll tables in one window; this is an accepted trade-off and SHALL be documented.

#### Scenario: A cheatsheet table renders as a table
- **WHEN** the cheatsheet is opened
- **THEN** its keybinding tables SHALL render with visible column structure

#### Scenario: Tables fit the default float
- **WHEN** the cheatsheet is opened at a typical terminal width
- **THEN** cheatsheet tables SHALL fit within the float without wrapping

