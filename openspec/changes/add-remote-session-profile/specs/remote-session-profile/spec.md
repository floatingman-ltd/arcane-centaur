## ADDED Requirements

### Requirement: Remote session detection flag
`lua/config/terminal.lua` SHALL expose a boolean flag `M.is_remote` that is `true` when the editing session reaches the user over a network connection rather than a local terminal. The flag SHALL be derived from the presence of `$SSH_TTY` or `$SSH_CONNECTION`, which `sshd` sets for interactive sessions. Other capabilities SHALL branch on this flag rather than testing the environment themselves.

#### Scenario: Interactive SSH session
- **WHEN** `$SSH_TTY` is set by `sshd`
- **THEN** `term.is_remote` SHALL be `true`

#### Scenario: SSH session exposing only SSH_CONNECTION
- **WHEN** `$SSH_TTY` is unset and `$SSH_CONNECTION` is set
- **THEN** `term.is_remote` SHALL be `true`

#### Scenario: Local graphical session
- **WHEN** neither `$SSH_TTY` nor `$SSH_CONNECTION` is set and `$TMUX` is unset
- **THEN** `term.is_remote` SHALL be `false`

#### Scenario: Local physical console
- **WHEN** `$TERM` is `linux`, no display is available, and neither SSH variable is set
- **THEN** `term.is_remote` SHALL be `false`

### Requirement: Remote detection survives a pre-existing tmux session
Environment variables are fixed when a process starts, and tmux cannot update panes that already exist, so a tmux session started before the SSH connection hosts processes with a stale or absent `$SSH_CONNECTION`. When `$TMUX` is set and neither SSH variable is present, detection SHALL consult the tmux server, which refreshes `SSH_CONNECTION` from each attaching client because that variable is in tmux's default `update-environment`. Detection SHALL test only for the presence of a value and SHALL NOT interpret its content, so a value left over from an earlier connection is harmless.

#### Scenario: Neovim started in a tmux pane that predates the SSH connection
- **WHEN** `$TMUX` is set, both SSH variables are absent, and `tmux show-environment SSH_CONNECTION` returns a value
- **THEN** `term.is_remote` SHALL be `true`

#### Scenario: Local tmux session, never reached over SSH
- **WHEN** `$TMUX` is set, both SSH variables are absent, and `tmux show-environment SSH_CONNECTION` returns the name prefixed with `-`, indicating tmux knows it to be unset
- **THEN** `term.is_remote` SHALL be `false`

#### Scenario: tmux binary unavailable
- **WHEN** `$TMUX` is set, both SSH variables are absent, and `tmux` is not executable
- **THEN** `term.is_remote` SHALL be `false`
- **AND** no error SHALL be reported to the user

#### Scenario: tmux is not a dependency
- **WHEN** tmux is not installed
- **THEN** `$TMUX` SHALL be unset, the tmux query SHALL NOT be reached, and detection SHALL rest on the SSH variables alone

### Requirement: Remoteness is independent of console detection
`term.is_remote` and `term.is_console` SHALL be derived independently, and neither SHALL be implemented in terms of the other. `is_console` answers whether a graphical display is available; `is_remote` answers whether the session crosses a network. All four combinations are reachable and SHALL be reported accurately.

#### Scenario: Local session with a display
- **WHEN** `$WAYLAND_DISPLAY` is set and no SSH variable is set
- **THEN** `term.is_console` SHALL be `false` and `term.is_remote` SHALL be `false`

#### Scenario: Headless server reached over SSH
- **WHEN** no display is available and `$SSH_TTY` is set
- **THEN** `term.is_console` SHALL be `true` and `term.is_remote` SHALL be `true`

#### Scenario: Local physical TTY
- **WHEN** no display is available and no SSH variable is set
- **THEN** `term.is_console` SHALL be `true` and `term.is_remote` SHALL be `false`

#### Scenario: Remote session with a forwarded display
- **WHEN** `$DISPLAY` is set by X forwarding and `$SSH_TTY` is set
- **THEN** `term.is_console` SHALL be `false` and `term.is_remote` SHALL be `true`

### Requirement: Key code timeout tolerates a jittery link
`ttimeoutlen` SHALL be set explicitly rather than left at Neovim's default, and its value SHALL depend on `term.is_remote`: `100` milliseconds when the session is remote, `50` milliseconds when it is local. Both branches SHALL be written explicitly so the effective value is recorded in the configuration rather than inherited from a default that may change. `timeout` and `ttimeout` SHALL NOT be set, as both are already enabled by default.

#### Scenario: Remote session tolerates split escape sequences
- **WHEN** `term.is_remote` is `true`
- **THEN** `ttimeoutlen` SHALL be `100`

#### Scenario: Local session keeps escape latency low
- **WHEN** `term.is_remote` is `false`
- **THEN** `ttimeoutlen` SHALL be `50`

#### Scenario: Mapped-sequence timeout is unaffected
- **WHEN** the session is remote
- **THEN** `timeoutlen` SHALL remain at its existing value of `1000`, which governs mapped sequences rather than terminal key codes

### Requirement: Detection behaviour and its limits are documented
The `is_remote` flag SHALL be documented in `docs/modules/ROOT/pages/other/architecture.adoc` alongside the existing `terminal.lua` flags. The documentation SHALL state that the flag is independent of `is_console`, and SHALL record the one known case in which detection is deliberately negative: a non-interactive command, for which `sshd` sets no `SSH_TTY` and where remote-specific behaviour is not wanted.

#### Scenario: Reader looks up how remoteness is determined
- **WHEN** a reader consults the architecture guide's `terminal.lua` flag list
- **THEN** `is_remote` SHALL appear there with its detection rule, including the tmux fallback
- **AND** its independence from `is_console` SHALL be stated

#### Scenario: Non-interactive invocation
- **WHEN** Neovim is run as a non-interactive command over SSH, for which `sshd` sets no `SSH_TTY`
- **THEN** `term.is_remote` SHALL be `false`
- **AND** the documentation SHALL record this as intended rather than as a defect
