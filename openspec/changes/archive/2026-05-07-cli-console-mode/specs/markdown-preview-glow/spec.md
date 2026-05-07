## ADDED Requirements

### Requirement: Glow plugin loads only in console environments
`glow.nvim` SHALL be loaded by lazy.nvim only when `term.is_console` is `true`, via the
`cond` field. `markdown-preview.nvim` SHALL be loaded only when `term.is_console` is
`false`. Exactly one of the two plugins SHALL be active in any given Neovim session.

#### Scenario: Console session loads glow
- **WHEN** Neovim starts and `term.is_console` is `true`
- **THEN** `glow.nvim` SHALL be loaded and `markdown-preview.nvim` SHALL not be loaded

#### Scenario: GUI session loads markdown-preview
- **WHEN** Neovim starts and `term.is_console` is `false`
- **THEN** `markdown-preview.nvim` SHALL be loaded and `glow.nvim` SHALL not be loaded

### Requirement: Glow renders in a vertical split by default
When invoked, glow SHALL render the current markdown buffer in a vertical split. This
SHALL be the default configuration. The guide SHALL document how to switch to a floating
window.

#### Scenario: Preview opens in vertical split
- **WHEN** the markdown preview command is invoked in a console session
- **THEN** a vertical split SHALL open containing the glow-rendered output

### Requirement: Glow binary check
If the `glow` binary is not found on `$PATH` at preview time, the config SHALL emit a
`WARN` level notification with a clear install instruction. Neovim SHALL not crash.

#### Scenario: glow binary missing
- **WHEN** the markdown preview command is invoked and `glow` is not executable
- **THEN** a WARN notification SHALL be shown with install instructions
- **THEN** no split or float SHALL be opened

### Requirement: Consistent preview keymap across environments
The markdown preview keymap SHALL invoke `:Glow` in console environments and
`:MarkdownPreview` in GUI environments, providing a consistent trigger regardless of
which plugin is active.

#### Scenario: Preview keymap in console
- **WHEN** the preview keymap is triggered in a console session
- **THEN** `:Glow` SHALL be invoked

#### Scenario: Preview keymap in GUI
- **WHEN** the preview keymap is triggered in a GUI session
- **THEN** `:MarkdownPreview` SHALL be invoked
