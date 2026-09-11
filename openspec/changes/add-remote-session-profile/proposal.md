## Why

`lua/options.lua` already adapts to its environment — `term.is_wsl` picks `win32yank`, `term.is_console` picks OSC 52 — but there is no notion of "this session is remote", so anything that should behave differently over SSH has to test for it itself. Two behaviours want it now (lualine's repaint interval and `ttimeoutlen`), and more will: anything that shells out to a browser, repaints on a timer, or assumes walking the filesystem is cheap.

Bundling GitHub issues #189, #188 and #187 is not just convenience. #189 is the enabler, and having the flag changes what the other two should do: #188's trade-off ("higher values make leaving insert mode feel sluggish") disappears once the value can be conditional, and #187 is only safe once the components that update asynchronously are made event-driven.

## What Changes

- **Add `term.is_remote`** to `lua/config/terminal.lua`, alongside `is_wsl` and `is_console`. Detected from `$SSH_TTY`/`$SSH_CONNECTION`, with a `tmux show-environment SSH_CONNECTION` fallback when `$TMUX` is set and neither variable is present.
- **Set `ttimeoutlen` explicitly and conditionally** — `100` when remote, `50` when local — rather than #188's unconditional `100`. Both branches are written out so the value is recorded rather than inherited.
- **Set lualine's `refresh` explicitly and conditionally** — `5000` when remote, `1000` when local, for statusline, tabline and winbar.
- **Add `User GitSignsUpdate` and `DiagnosticChanged` to lualine's `refresh.events`.** This is a correctness fix that the longer interval makes necessary, not an optional extra — see below.
- **Document the flag** in `docs/modules/ROOT/pages/other/architecture.adoc`, which already carries the `terminal.lua` flag list.

Not breaking. Every new value equals the current effective behaviour when the session is local, so a local session is unchanged by construction.

Three findings from grounding the issues against the code, each of which narrows or redirects what the issue asked for:

- **#188's snippet contains two no-ops.** `timeout` and `ttimeout` are already `1` in the live config (Neovim's defaults, confirmed headlessly). Only `ttimeoutlen` needs setting, so the diff is one line per branch rather than three.
- **#187's premise is narrower than it reads.** lualine's default `refresh.events` already includes `CursorMoved`, `CursorMovedI` and `ModeChanged`, so the 1000 ms timer is only the *idle* fallback. Raising it will not reduce traffic while actively editing; it addresses idle repaint only. The issue's stated benefit is real but smaller than "repaints roughly once a second".
- **#187 would introduce a defect without the event additions.** The gitsigns `diff` source and the `diagnostics` component both read state that arrives asynchronously, *after* the last cursor event. Neither `User GitSignsUpdate` nor `DiagnosticChanged` is in lualine's default event list, so at 5000 ms those counts could sit stale for up to five seconds. This is the caveat `recommendations/ideas.md` flagged for #187, now identified precisely.

## Capabilities

### New Capabilities

- `remote-session-profile`: detection of a remote session as a single flag on `terminal.lua`, the documented limits of that detection, and the input-timing behaviour derived from it (`ttimeoutlen`). Deliberately distinct from `console-detection`, which answers "is a display available?" rather than "is this session remote?" — the two are independent, and conflating them is the defect #191 exists to fix.

### Modified Capabilities

- `statusline`: gains a requirement that lualine's repaint interval adapts to `term.is_remote`, and that components sourcing asynchronous state are refreshed by event rather than by timer. Existing requirements for what the statusline displays are unchanged.

## Impact

| Area | Change |
|---|---|
| `lua/config/terminal.lua` | new `M.is_remote`, one detection helper |
| `lua/options.lua` | `ttimeoutlen` set, conditional on `term.is_remote` |
| `lua/plugins/lualine.lua` | `options.refresh` table added, conditional; `refresh.events` extended |
| `docs/.../other/architecture.adoc` | `terminal.lua` flag list and Console Detection section gain `is_remote` |
| `openspec/TEST_PLAN.md` | new `## Change · add-remote-session-profile` section |

**No new dependencies.** tmux is not required: `$TMUX` is only ever set by tmux itself, so the fallback is unreachable when tmux is absent, and an `executable("tmux")` guard covers `$TMUX` set with the binary missing. Where tmux *is* in use the query costs one subprocess at startup, inside tmux only.

**Runtime behaviour changes, so manual validation in a live session is required** before push, per the repo's standing practice. Two steps cannot be verified headlessly and need eyes on: the `ttimeoutlen` feel-test (whether `<Esc>` latency is acceptable), and confirming the git/diagnostics counts still update promptly at the 5000 ms interval.

**Follow-on, explicitly out of scope.** `is_remote` is the flag #191 will need when it reworks `terminal.lua` from "which terminal is this?" to "what can the display do?", but this change does not touch the capability lists or the `detect()` name table.
