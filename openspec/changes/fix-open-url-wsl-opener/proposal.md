## Why

`util.open_url` does nothing visible on this machine, and nothing tells the user so. Every feature that hands the user a URL — `,sp` markdown preview, the AsciiDoc and Antora previews, PlantUML and Marp — is affected.

The cause is opener ordering under WSL, not the console fallback that `recommendations/ideas.md` originally blamed. WSLg sets `DISPLAY=:0` and `WAYLAND_DISPLAY=wayland-0`, so `term.is_console` is `false` and the INFO-notify branch is never reached. Instead `xdg-open` — first in the opener list and executable — wins, finds no graphical browser, falls through to `w3m` launched detached with no tty, and **exits 0**. `explorer.exe`, the one opener that works here, is fourth in the list and never tried; `wslview` is not installed.

Checking the opener's exit status would not have caught it. `xdg-open` reports success after doing nothing.

## What Changes

- Try the Windows openers (`wslview`, `explorer.exe`) **before** the Linux ones when `term.is_wsl` is true. Non-WSL systems keep the existing order.
- Put the URL on the system clipboard and echo it on the command line on **every** call, including the success paths. When an opener silently does nothing, the URL is still recoverable rather than lost.
- Keep the console INFO notification and the "no opener found" WARN as they are.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `open-url`: the opener priority becomes platform-dependent rather than fixed, and the URL is surfaced to the user on every call rather than only on the console and no-opener paths.

## Impact

- `lua/config/util.lua` — `M.open_url` only. No call site changes.
- Five callers inherit the behaviour: `lua/config/mdpreview.lua:38`, `lua/config/marp.lua:65`, `lua/plugins/plantuml.lua:36`, `after/ftplugin/asciidoctor.lua:78` and `:141`.
- `openspec/specs/open-url/spec.md` — one MODIFIED requirement.
- Documentation surfaces that describe the opener order or console behaviour.
- No new dependencies. `wslview` remains optional; `explorer.exe` is always present under WSL.
