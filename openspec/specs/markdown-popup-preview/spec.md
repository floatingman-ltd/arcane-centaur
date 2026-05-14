# markdown-popup-preview Specification

## Purpose
Define markdown preview behavior so markdown buffers always provide a forced popup preview via `,pp`, ensure `glow.nvim` loads in all environments, and preserve the existing smart-routing behavior of `,p`.
## Requirements
### Requirement: Forced popup preview keymap always available
The config SHALL provide a `,pp` keymap in markdown buffers that opens the glow.nvim floating popup preview unconditionally, regardless of whether a graphical display is available.

#### Scenario: Popup preview in GUI terminal
- **WHEN** the user presses `,pp` in a markdown buffer inside a GUI-capable terminal (e.g. GNOME Terminal, WSL Terminal)
- **THEN** the glow.nvim floating popup opens displaying the rendered markdown

#### Scenario: Popup preview in console mode
- **WHEN** the user presses `,pp` in a markdown buffer in a headless/TTY environment
- **THEN** the glow.nvim floating popup opens (same behaviour as `,p` in that environment)

#### Scenario: glow binary absent
- **WHEN** the user presses `,pp` and the `glow` binary is not installed
- **THEN** a warning notification is shown and no popup is opened

### Requirement: glow.nvim loads in all environments
`glow.nvim` SHALL be loaded by lazy.nvim whenever a markdown buffer is opened, regardless of whether `$DISPLAY` or `$WAYLAND_DISPLAY` is set.

#### Scenario: glow available in GUI terminal
- **WHEN** Neovim is running in a GUI-capable terminal with `$DISPLAY` set
- **THEN** `:Glow` is a valid command (glow.nvim is loaded)

#### Scenario: glow available in console mode
- **WHEN** Neovim is running in a headless/TTY environment
- **THEN** `:Glow` is a valid command (unchanged from current behaviour)

### Requirement: Existing ,p smart-routing unchanged
The `,p` keymap SHALL continue to route to `MarkdownPreviewToggle` in GUI environments and to `Glow` in console environments, exactly as before this change.

#### Scenario: ,p in GUI environment routes to browser
- **WHEN** the user presses `,p` in a GUI-capable terminal
- **THEN** `MarkdownPreviewToggle` is invoked (browser preview)

#### Scenario: ,p in console routes to glow
- **WHEN** the user presses `,p` in a headless/TTY environment
- **THEN** `Glow` is invoked (popup preview)

