## Context

`M.open_url` in `lua/config/util.lua:51-70` walks a fixed opener list — `xdg-open`, `open`, `wslview`, `explorer.exe` — and fires the first executable one via `vim.fn.jobstart({ cmd, url }, { detach = true })`, with no exit handler.

Measured on this machine (Ubuntu under WSL2, WSLg active):

| Opener | Present | Would work |
|---|---|---|
| `xdg-open` | yes | **no** — no GUI browser installed |
| `open` | yes (symlink to `xdg-open`) | no |
| `wslview` | no | — |
| `explorer.exe` | yes | yes |

`xdg-open` is checked first and is executable, so it always wins. It probes ten browsers, finds none, falls through to `w3m`, which cannot render into a detached job with no tty — and then exits **0**:

```
/usr/bin/xdg-open: 882: x-www-browser: not found
... firefox, iceweasel, seamonkey, mozilla, epiphany, konqueror,
    chromium, chromium-browser, google-chrome — all not found
w3m: Can't load http://127.0.0.1:9999/probe.
xdg-open exit=0
```

Two existing safety nets both fail to catch this. The "no opener found" WARN never fires, because `xdg-open` *is* executable. And the console INFO notification never fires either: WSLg exports `DISPLAY=:0` and `WAYLAND_DISPLAY=wayland-0`, so `term.is_console` (`lua/config/terminal.lua:77`) is `false`.

The original entry in `recommendations/ideas.md` attributed the symptom to that console notification being easy to miss. That diagnosis was wrong — the branch is unreachable here.

## Goals / Non-Goals

**Goals:**

- `,sp` and the other four `open_url` callers actually open a browser under WSL.
- When an opener does nothing, the user still ends up with the URL rather than silence.
- Non-WSL platforms keep the behaviour they have today.

**Non-Goals:**

- Changing `term.is_console`. WSLg's cosmetic `DISPLAY` arguably makes it wrong for other callers too, but that touches the `console-detection` capability and six unrelated call sites — a separate change.
- Verifying that the browser actually rendered the page. Not observable from Neovim.
- Installing a Linux browser or `wslu` to make `xdg-open` work. Reordering is cheaper and has no dependency.

## Decisions

### D1 — Platform-dependent opener order, not exit-code detection

Under WSL, try `wslview` and `explorer.exe` first:

```lua
local openers = term.is_wsl and { "wslview", "explorer.exe", "xdg-open", "open" }
  or { "xdg-open", "open", "wslview", "explorer.exe" }
```

The obvious alternative — keep the order and fall through to the next opener when one fails — **does not work here**. `xdg-open` exits 0 after failing to display anything, so there is no failure to detect. Any exit-code scheme would still stop at `xdg-open` and still show nothing. Ordering is the only signal available.

WSL is the one platform where the ordering is unambiguous: `explorer.exe` is always present and always reaches the user's real (Windows) browser, whereas `xdg-open` only works if a Linux browser was separately installed. On native Linux and macOS the current order is already correct, so it is left alone.

`wslview` stays ahead of `explorer.exe` where it exists — it is the purpose-built tool and handles path translation — but is not a dependency, since `explorer.exe` covers every WSL install.

### D2 — Surface the URL on every call

Before attempting anything, `open_url` writes the URL to the `+` register and echoes it on the command line:

```lua
vim.fn.setreg("+", url)
vim.api.nvim_echo({ { "open_url: " .. url .. " (copied to clipboard)" } }, true, {})
```

`nvim_echo` with `history = true` is chosen over `vim.notify` deliberately: the message lands in `:messages`, so it survives being missed. A notification toast does not. This is what makes the failure mode recoverable — even if a future opener silently no-ops the way `xdg-open` does, the URL is one paste or one `:messages` away.

The clipboard write is unconditional and does clobber whatever the user had copied. That is stated in the echo so it is never a surprise, and it is the behaviour that makes the feature useful — a URL you have to retype is not much better than no URL.

Clipboard support is already configured for this environment: `lua/options.lua:68-80` wires `win32yank.exe` under WSL, with an OSC 52 provider for console sessions.

### D3 — Console path keeps its notification and skips the echo

`term.is_console` still short-circuits before any opener, and still emits the INFO notification containing the URL. It gains the clipboard write but not the echo — the notification already carries the URL, and emitting both would print it twice.

The "no opener found" WARN is unchanged.

### D4 — Ordering of the surface relative to the open attempt

Surfacing happens first, unconditionally, rather than only on failure. There is no reliable failure signal to hang it off (D1), so "on failure" is not an implementable option.

## Risks / Trade-offs

- **The clipboard is clobbered on every call.** Accepted, and announced in the echo. A dedicated named register would be non-destructive but nobody would think to look in it.
- **The command line gains a message on every preview.** Minor noise; it is one line and it is the thing that makes the failure recoverable.
- **`explorer.exe` writes a "UNC paths are not supported" note to stderr when the cwd is a Linux path.** The job is detached and its stderr is not captured, so this is invisible in practice — but it means `explorer.exe` should never be used with a filesystem path here, only with the `http://` URLs these callers pass.
- **If the user later installs a Linux browser, WSL will still prefer the Windows one.** Deliberate: under WSL the Windows browser is the one on the visible desktop. Anyone wanting the other order can reorder one table.
