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

Under WSL, try the Windows openers first:

| Platform | Opener priority |
|---|---|
| WSL | `wslview`, `powershell.exe`, `explorer.exe`, `xdg-open`, `open` |
| Everything else | `xdg-open`, `open`, `wslview`, `explorer.exe` |

The obvious alternative — keep the order and fall through to the next opener when one fails — **does not work here**. `xdg-open` exits 0 after failing to display anything, so there is no failure to detect. Any exit-code scheme would still stop at `xdg-open` and still show nothing. Ordering is the only signal available.

WSL is the one platform where the ordering is unambiguous: `explorer.exe` is always present and always reaches the user's real (Windows) browser, whereas `xdg-open` only works if a Linux browser was separately installed. On native Linux and macOS the current order is already correct, so it is left alone.

`wslview` stays at the front where it exists — it is the purpose-built tool — but is not a dependency, because PowerShell covers every WSL install. See D6 for why `explorer.exe` is no longer the primary despite always being present.

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

### D5 — WSL is exempt from the console short-circuit

`M.is_console` is derived solely from `$DISPLAY`/`$WAYLAND_DISPLAY` (`lua/config/terminal.lua:77`), which treats "no X11 display" as "no browser exists". Under WSL that inference is wrong: `explorer.exe` reaches the Windows browser whether or not WSLg is exporting a display. So WSL *without* WSLg — an ordinary configuration — would emit a notification and never open anything, which is the same class of failure this change exists to fix.

The guard therefore becomes `if term.is_console and not term.is_wsl then`.

This is deliberately narrower than fixing `is_console` itself. That flag is read by six other call sites (`lua/options.lua:81`, `lua/plugins/plantuml.lua:104`, `lua/plugins/markdown.lua:28`, `after/ftplugin/markdown.lua:28`, `after/ftplugin/asciidoctor.lua:13` and `:102`), where "no display" means something different in each case, so redefining it belongs in a change of its own against the `console-detection` capability.

**macOS has the identical flaw and is not being fixed here.** macOS does not set `$DISPLAY` unless XQuartz is running, so `is_console` is `true` there and `open` — which sits in the opener list specifically for macOS — is never reached. The same one-line exemption (`vim.fn.has("mac") == 1`) would fix it, but there is no macOS available to validate against, and shipping an unverifiable behaviour change is worse than logging it. Recorded in `recommendations/ideas.md`.

### D4 — Ordering of the surface relative to the open attempt

Surfacing happens first, unconditionally, rather than only on failure. There is no reliable failure signal to hang it off (D1), so "on failure" is not an implementable option.

### D6 — PowerShell `Start-Process`, not `explorer.exe` or `cmd.exe`

`explorer.exe` was the obvious WSL opener — always present, no dependency — and it is wrong. It refuses to treat a string containing `=` as a URL and opens a File Explorer window instead. Confirmed live on two shapes: a trailing `=` (`.../png/…0G0=`, the padding PlantUML URLs carry) and a mid-query `=` (`google.com/search?q=plantuml`). Both opened a folder.

`cmd.exe /c start ""` is worse. Measured against a local HTTP listener, so the evidence is a logged request rather than an inference:

| Invocation | URL sent | URL the server received |
|---|---|---|
| `explorer.exe` | `?q=plantuml` | *(no request — opened a folder)* |
| `cmd.exe /c start ""` | `?q=a&hl=en&x=1` | `?q=a` |
| `powershell.exe … Start-Process` | `?q=a&hl=en&x=1` | `?q=a&hl=en&x=1` |

`cmd.exe` truncates at the first `&` and opens a **different page** without reporting anything — a silent-wrong-answer failure, the hardest kind to notice. It also tries to execute the remainder (`operable program or batch file`) and emits a UNC warning whenever the cwd is a Linux path.

So the WSL primary is:

```lua
{ "powershell.exe", "-NoProfile", "-NonInteractive", "-Command",
  "Start-Process '" .. url:gsub("'", "''") .. "'" }
```

PowerShell single-quoted strings escape a literal quote by doubling it, which is the only escaping the URL needs there.

This forces the opener table to hold argv *builders* rather than bare command names, since the openers no longer share a single `{ cmd, url }` shape.

`explorer.exe` is retained as a last resort under WSL rather than dropped. It is wrong for URLs containing `=` but correct for those without, and if PowerShell and `wslview` are both missing it is better than nothing — the alternative would fall through to `xdg-open`, which is broken here for a different reason.

## Risks / Trade-offs

- **The clipboard is clobbered on every call.** Accepted, and announced in the echo. A dedicated named register would be non-destructive but nobody would think to look in it.
- **The command line gains a message on every preview.** Minor noise; it is one line and it is the thing that makes the failure recoverable.
- **`explorer.exe` writes a "UNC paths are not supported" note to stderr when the cwd is a Linux path.** The job is detached and its stderr is not captured, so this is invisible in practice — but it means `explorer.exe` should never be used with a filesystem path here, only with the `http://` URLs these callers pass.
- **If the user later installs a Linux browser, WSL will still prefer the Windows one.** Deliberate: under WSL the Windows browser is the one on the visible desktop. Anyone wanting the other order can reorder one table.
- **The WSL exemption means a genuinely headless WSL session now opens a browser instead of notifying.** That is the intended behaviour — `explorer.exe` works there — but it does mean `open_url` no longer has any path that both declines to open and is reachable under WSL. A WSL user who wants the notification instead has no way to ask for it. Nobody has.
- **PowerShell is slow to start** — a few hundred milliseconds against `explorer.exe`'s near-instant launch. The job is detached, so nothing blocks; the browser simply appears a moment later. Correctness is worth more than the latency here, and `wslview` still takes precedence where installed.
- **`explorer.exe` stays in the list while being known-wrong for some URLs.** A user who has neither `wslview` nor PowerShell would get a folder window for a PlantUML URL and no explanation. Judged better than no attempt at all, but it is a degraded path, not a supported one.
- **macOS remains broken and now visibly inconsistent**, since WSL got the exemption and macOS did not. Logged rather than guessed at.
