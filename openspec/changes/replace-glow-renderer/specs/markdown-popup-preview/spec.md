## MODIFIED Requirements

### Requirement: Forced popup preview keymap always available
The config SHALL provide a `,pp` keymap in markdown buffers that opens the floating popup preview unconditionally, regardless of whether a graphical display is available. The popup SHALL be rendered in-editor; it SHALL NOT depend on any external binary, and SHALL therefore never fail for want of one.

#### Scenario: Popup preview in GUI terminal
- **WHEN** the user presses `,pp` in a markdown buffer inside a GUI-capable terminal (e.g. GNOME Terminal, WSL Terminal)
- **THEN** the floating popup opens displaying the rendered markdown

#### Scenario: Popup preview in console mode
- **WHEN** the user presses `,pp` in a markdown buffer in a headless/TTY environment
- **THEN** the floating popup opens (same behaviour as `,p` in that environment)

#### Scenario: No external binary required
- **WHEN** the user presses `,pp` on a machine with no markdown-rendering binary installed
- **THEN** the popup opens and renders normally
- **AND** no warning notification about a missing binary is shown

### Requirement: Existing ,p smart-routing unchanged
The `,p` keymap SHALL continue to route by environment: `MarkdownPreviewToggle` in GUI environments, and the in-editor popup preview in console environments. The routing behaviour is unchanged; only the console-side renderer differs.

#### Scenario: ,p in GUI environment routes to browser
- **WHEN** the user presses `,p` in a GUI-capable terminal
- **THEN** `MarkdownPreviewToggle` is invoked (browser preview)

#### Scenario: ,p in console routes to the in-editor popup
- **WHEN** the user presses `,p` in a headless/TTY environment
- **THEN** the in-editor floating popup preview is opened

## REMOVED Requirements

### Requirement: glow.nvim loads in all environments
**Reason**: `glow.nvim` is removed, so there is no plugin whose loading needs guaranteeing across environments, and `:Glow` is no longer a command.
**Migration**: `:Glow` is replaced by `:MarkdownPopup`, available in markdown buffers in every environment. The guarantee that a popup preview works everywhere is preserved by *Forced popup preview keymap always available* above, and by *Markdown renders in-editor without an external binary* in `markdown-native-rendering`.
