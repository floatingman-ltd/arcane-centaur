## Requirements

### Requirement: Glow plugin is available in all environments
`glow.nvim` SHALL be loaded by lazy.nvim whenever markdown filetypes are opened, regardless
of `term.is_console`. `markdown-preview.nvim` SHALL continue to load only when
`term.is_console` is `false`.

#### Scenario: Console session loads glow only
- **WHEN** Neovim starts and `term.is_console` is `true`
- **THEN** `glow.nvim` SHALL be loaded and `markdown-preview.nvim` SHALL not be loaded

#### Scenario: GUI session loads glow and markdown-preview
- **WHEN** Neovim starts and `term.is_console` is `false`
- **THEN** both `glow.nvim` and `markdown-preview.nvim` SHALL be loaded

### Requirement: Glow renders in a floating popup by default
When invoked, glow SHALL render the current markdown buffer in a centered floating popup.
This SHALL be the default configuration.

#### Scenario: Preview opens in floating popup
- **WHEN** the markdown preview command is invoked in a console session
- **THEN** a centered floating popup SHALL open containing the glow-rendered output

### Requirement: Glow binary check
If the `glow` binary is not found on `$PATH` at preview time, the config SHALL emit a
`WARN` level notification with a clear install instruction. Neovim SHALL not crash.

#### Scenario: glow binary missing
- **WHEN** the markdown preview command is invoked and `glow` is not executable
- **THEN** a WARN notification SHALL be shown with install instructions
- **THEN** no split or float SHALL be opened

### Requirement: Consistent preview keymap across environments
The markdown preview keymap SHALL invoke `:Glow` in console environments and
`:MarkdownPreviewToggle` in GUI environments, providing a consistent trigger regardless of
environment.

#### Scenario: Preview keymap in console
- **WHEN** the preview keymap is triggered in a console session
- **THEN** `:Glow` SHALL be invoked

#### Scenario: Preview keymap in GUI
- **WHEN** the preview keymap is triggered in a GUI session
- **THEN** `:MarkdownPreviewToggle` SHALL be invoked
