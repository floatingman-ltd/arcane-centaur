## MODIFIED Requirements

### Requirement: Forced popup preview keymap always available
Because markdown is rendered in the buffer itself, a popup showing the same content is redundant. `,pp` SHALL instead toggle in-buffer rendering, flipping between rendered output and the raw markup, so the source can be read and edited on demand. A floating popup SHALL remain reachable — via `,p` in console environments and via the `:MarkdownPopup` command in any environment — and SHALL NOT depend on any external binary, so it can never fail for want of one.

#### Scenario: Toggling rendering off reveals the raw source
- **WHEN** the user presses `,pp` in a markdown buffer that is currently rendered
- **THEN** rendering SHALL be disabled for that buffer and the raw markup SHALL be shown

#### Scenario: Toggling rendering back on
- **WHEN** the user presses `,pp` again in the same buffer
- **THEN** rendering SHALL be restored

#### Scenario: The popup remains available
- **WHEN** the user runs `:MarkdownPopup` in a markdown buffer
- **THEN** the floating popup SHALL open displaying the rendered markdown
- **AND** it SHALL work in both GUI and console environments

#### Scenario: No external binary required
- **WHEN** either the toggle or the popup is used on a machine with no markdown-rendering binary installed
- **THEN** it SHALL work normally
- **AND** no warning notification about a missing binary SHALL be shown

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
