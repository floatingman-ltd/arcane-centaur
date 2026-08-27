# open-url Specification

## Purpose

Provides `util.open_url`, the single entry point every feature uses to hand a URL to the user.

Its job is to make the URL *reach* the user, which is not the same as launching a process. Every call writes the URL to the `+` register and, whenever an opener is attempted, echoes it through the message history — so the URL is recoverable from `:messages` even when the opener silently does nothing. That has happened: `xdg-open` exits `0` after failing to display anything, and `explorer.exe` opens a folder window for any URL containing `=`.

Opener priority is therefore platform-dependent rather than fixed. Under WSL it is `wslview`, `powershell.exe`, `explorer.exe`, `xdg-open`, `open`; everywhere else `xdg-open`, `open`, `wslview`, `explorer.exe`. The chosen opener must receive the URL unaltered.

When no display is exported and the platform has no native opener, it skips the openers entirely and emits an INFO notification containing the URL, so a console user can copy it rather than watching a silent no-op. WSL is exempt from that short-circuit, since the Windows openers work with or without WSLg. A session with no usable opener at all still produces a WARN with install guidance.

## Requirements
### Requirement: URL opening with console fallback

`util.open_url` SHALL make the URL recoverable on every call, and SHALL attempt to open it in a graphical browser when a display is available.

On every call, regardless of environment or outcome, it SHALL write the URL to the `+` register.

The opener priority SHALL depend on the platform. When `term.is_wsl` is `true` the order SHALL be `wslview`, `powershell.exe`, `explorer.exe`, `xdg-open`, `open`. Otherwise it SHALL be `xdg-open`, `open`, `wslview`, `explorer.exe`. In both cases the first executable opener SHALL be used.

The chosen opener SHALL receive the URL unaltered, including any `=` and `&` characters. `powershell.exe` SHALL be invoked through `Start-Process` with the URL in a single-quoted argument, any literal quote doubled.

When `term.is_console` is `true` **and** `term.is_wsl` is `false`, it SHALL skip all opener attempts and instead emit a `vim.notify` at `INFO` level containing the URL. Under WSL the opener attempts SHALL be made regardless of `term.is_console`, because the Windows openers reach the Windows browser whether or not a display is exported. In every case where openers are attempted, it SHALL echo the URL to the command line through the message history first. The existing WARN notification for "no opener found" in GUI environments SHALL be retained.

#### Scenario: WSL prefers the Windows opener

- **WHEN** `util.open_url(url)` is called, `term.is_console` is `false` and `term.is_wsl` is `true`
- **THEN** `wslview` SHALL be tried first, followed by `powershell.exe`, then `explorer.exe`, and only then `xdg-open` and `open`
- **THEN** the URL SHALL open in the Windows default browser even when no Linux browser is installed

#### Scenario: URL punctuation survives the opener

- **WHEN** `util.open_url(url)` is called under WSL with a URL containing `=` or `&`
- **THEN** the browser SHALL be sent the complete URL, not a truncated or reinterpreted one
- **THEN** `explorer.exe` SHALL NOT be the opener chosen while `wslview` or `powershell.exe` is available, because it does not treat a string containing `=` as a URL

#### Scenario: Non-WSL keeps the Linux-first order

- **WHEN** `util.open_url(url)` is called, `term.is_console` is `false` and `term.is_wsl` is `false`
- **THEN** `xdg-open` SHALL be tried first, followed by `open`, `wslview` and `explorer.exe`

#### Scenario: URL is recoverable after every call

- **WHEN** `util.open_url(url)` is called in any environment
- **THEN** the URL SHALL be written to the `+` register
- **THEN** the URL SHALL be retrievable from `:messages` afterwards

#### Scenario: GUI environment opens browser

- **WHEN** `util.open_url(url)` is called and `term.is_console` is `false`
- **THEN** the first available opener for the platform SHALL be used to open the URL in a browser
- **THEN** the URL SHALL be echoed to the command line, noting that it was copied to the clipboard
- **THEN** no notification SHALL be emitted on success

#### Scenario: Console environment notifies with URL

- **WHEN** `util.open_url(url)` is called, `term.is_console` is `true` and `term.is_wsl` is `false`
- **THEN** a `vim.notify` at `INFO` level SHALL be emitted containing the full URL
- **THEN** no opener command SHALL be attempted
- **THEN** no additional command-line echo SHALL be emitted, the notification already carrying the URL

#### Scenario: WSL without a display still opens the browser

- **WHEN** `util.open_url(url)` is called, `term.is_console` is `true` and `term.is_wsl` is `true`
- **THEN** the console short-circuit SHALL NOT apply
- **THEN** the WSL opener priority SHALL be used, reaching `wslview` or `powershell.exe`
- **THEN** the URL SHALL be echoed to the command line as in any other opener attempt

#### Scenario: GUI environment with no opener found

- **WHEN** `util.open_url(url)` is called and `term.is_console` is `false`
- **WHEN** none of the opener commands are executable
- **THEN** a `WARN` notification SHALL be emitted with the URL and install guidance

