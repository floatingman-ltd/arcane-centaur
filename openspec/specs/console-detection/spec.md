## Requirements

### Requirement: Console detection documentation lives in the Architecture guide
The `term.is_console` console detection documentation SHALL be located in
`documentation/guides/architecture.md` and its generated AsciiDoc equivalent.
The Open URL console behaviour documentation SHALL also move there. Neither
SHALL remain in `cli-console-mode.md` (which is being dissolved). All existing
functional requirements for console detection behaviour SHALL remain unchanged.

#### Scenario: Console detection explanation found in architecture guide
- **WHEN** a reader looks for how console mode is detected
- **THEN** the explanation SHALL be in `documentation/guides/architecture.md`
- **THEN** `cli-console-mode.md` SHALL NOT exist as a standalone file

### Requirement: Console environment detection
`terminal.lua` SHALL expose a boolean flag `M.is_console` that is `true` when no
graphical display is available. The flag SHALL be derived solely from the absence of
both `$DISPLAY` and `$WAYLAND_DISPLAY` environment variables. No manual override flag
is used.

#### Scenario: Physical Linux TTY console
- **WHEN** `$DISPLAY` is unset and `$WAYLAND_DISPLAY` is unset and `$TERM` is `linux`
- **THEN** `term.is_console` SHALL be `true`

#### Scenario: SSH session without X forwarding
- **WHEN** `$DISPLAY` is unset and `$WAYLAND_DISPLAY` is unset and `$TERM` is `xterm-256color`
- **THEN** `term.is_console` SHALL be `true`

#### Scenario: tmux on a headless server
- **WHEN** `$TMUX` is set and `$DISPLAY` is unset and `$WAYLAND_DISPLAY` is unset
- **THEN** `term.is_console` SHALL be `true`

#### Scenario: GUI terminal emulator
- **WHEN** `$DISPLAY` is set (e.g. `:0`)
- **THEN** `term.is_console` SHALL be `false`

#### Scenario: Wayland GUI session
- **WHEN** `$WAYLAND_DISPLAY` is set (e.g. `wayland-0`)
- **THEN** `term.is_console` SHALL be `false`

#### Scenario: tmux inside a GUI terminal
- **WHEN** `$TMUX` is set and `$DISPLAY` is also set by the outer GUI terminal
- **THEN** `term.is_console` SHALL be `false`
