## ADDED Requirements

### Requirement: Statusline repaint interval adapts to remote sessions
lualine's `options.refresh` SHALL be set explicitly for `statusline`, `tabline` and `winbar`, and its value SHALL depend on `term.is_remote`: `5000` milliseconds when the session is remote, `1000` milliseconds when it is local. Each timer-driven repaint is terminal output that has to cross the link, so on a slow or metered connection the default interval produces steady background traffic and visible flicker while the buffer is idle.

#### Scenario: Remote session repaints less often when idle
- **WHEN** `term.is_remote` is `true`
- **THEN** `options.refresh.statusline`, `options.refresh.tabline` and `options.refresh.winbar` SHALL each be `5000`

#### Scenario: Local session keeps the default cadence
- **WHEN** `term.is_remote` is `false`
- **THEN** `options.refresh.statusline`, `options.refresh.tabline` and `options.refresh.winbar` SHALL each be `1000`

#### Scenario: Interval governs idle repaints only
- **WHEN** the cursor moves or the mode changes in a remote session
- **THEN** the statusline SHALL repaint on that event without waiting for the interval, because `CursorMoved`, `CursorMovedI` and `ModeChanged` remain in `options.refresh.events`

### Requirement: Components sourcing asynchronous state refresh by event
`options.refresh.events` SHALL include `User GitSignsUpdate` and `DiagnosticChanged` in addition to lualine's defaults. The `diff` component sources hunk counts from `vim.b.gitsigns_status_dict` and the `diagnostics` component reads `vim.diagnostic`; both are populated asynchronously, after the last cursor movement, and neither event is in lualine's default list. Without these events the counts depend on the repaint timer to be noticed, so a longer interval would display stale hunk and error counts for up to its full duration.

#### Scenario: Git hunk counts update while the buffer is idle
- **WHEN** gitsigns finishes computing a diff and publishes `User GitSignsUpdate` while the cursor is stationary in a remote session
- **THEN** the statusline SHALL refresh on that event
- **AND** the displayed added/changed/removed counts SHALL NOT wait for the next repaint interval

#### Scenario: Diagnostic counts update while the buffer is idle
- **WHEN** a language server publishes diagnostics, firing `DiagnosticChanged`, while the cursor is stationary in a remote session
- **THEN** the statusline SHALL refresh on that event
- **AND** the displayed error and warning counts SHALL NOT wait for the next repaint interval

#### Scenario: Repaint frequency is not increased while typing
- **WHEN** the user is typing in insert mode
- **THEN** the added events SHALL NOT cause more repaints than the status quo, because `CursorMovedI` is already in the default event list and fires on every keystroke
