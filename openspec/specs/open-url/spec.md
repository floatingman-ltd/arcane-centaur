# open-url Specification

## Purpose

Provides `util.open_url`, the single entry point every feature uses to hand a URL to the user.
When a display is available it tries the graphical openers in priority order (`xdg-open`, `open`,
`wslview`, `explorer.exe`); when `term.is_console` is `true` it skips them entirely and emits an
INFO notification containing the URL, so a console user can copy it rather than watching a silent
no-op. A GUI session with no usable opener still produces a WARN with install guidance.

## Requirements

### Requirement: URL opening with console fallback
`util.open_url` SHALL attempt to open a URL in a graphical browser when a display is
available, using the existing opener priority (`xdg-open`, `open`, `wslview`,
`explorer.exe`). When `term.is_console` is `true`, it SHALL skip all opener attempts
and instead emit a `vim.notify` at `INFO` level containing the URL. The existing WARN
notification for "no opener found" in GUI environments SHALL be retained.

#### Scenario: GUI environment opens browser
- **WHEN** `util.open_url(url)` is called and `term.is_console` is `false`
- **THEN** the first available opener SHALL be used to open the URL in a browser
- **THEN** no notification SHALL be emitted on success

#### Scenario: Console environment notifies with URL
- **WHEN** `util.open_url(url)` is called and `term.is_console` is `true`
- **THEN** a `vim.notify` at `INFO` level SHALL be emitted containing the full URL
- **THEN** no opener command SHALL be attempted

#### Scenario: GUI environment with no opener found
- **WHEN** `util.open_url(url)` is called and `term.is_console` is `false`
- **WHEN** none of the opener commands are executable
- **THEN** a `WARN` notification SHALL be emitted with the URL and install guidance
