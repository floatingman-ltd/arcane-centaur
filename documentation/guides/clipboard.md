# Clipboard Integration Guide

Neovim uses the system clipboard through a **provider** — an external tool (or
terminal escape sequence) that bridges Neovim's registers and the OS clipboard.
This config selects the provider automatically based on the environment.

→ Keybinding reference: [../cheatsheets/editing.md](../cheatsheets/editing.md)

---

## How the provider is chosen

The selection logic is in `lua/options.lua`:

```
WSL + win32yank.exe detected  →  win32yank  (bidirectional, fast)
is_console (no $DISPLAY / $WAYLAND_DISPLAY)  →  OSC 52  (terminal escape)
GUI Linux  →  auto-detected: wl-clipboard → xclip → xsel
```

`clipboard=unnamedplus` is set globally, so the default `y`, `d`, and `p`
operators already target the system clipboard on every platform once the
provider is working.

The `<leader>y` / `<leader>d` / `<leader>p` shortcuts use the explicit `"+`
register as an unambiguous alternative.

---

## GUI Linux — X11

### Tool: xclip or xsel

Neovim checks for `xclip` first, then `xsel`.  Install one of them:

```sh
# Debian / Ubuntu / Mint
sudo apt install xclip

# or xsel
sudo apt install xsel

# Fedora
sudo dnf install xclip

# Arch Linux
sudo pacman -S xclip
```

### Verify

Open Neovim and run:

```vim
:checkhealth
```

Look for the `clipboard` section — it will list which provider was found.
Or from a shell:

```sh
nvim --headless "+checkhealth clipboard" +qa
# review the clipboard section for detected provider/tool status
```

Quick functional test:

```sh
echo "hello" | xclip -selection clipboard
# then in Neovim: <leader>p  — should paste "hello"
```

### Troubleshooting

| Symptom | Fix |
|---|---|
| `clipboard: No provider found` in `:checkhealth` | Install `xclip` or `xsel` |
| Copying works but nothing appears in other apps | Make sure you are copying to `CLIPBOARD` (the `+` register), not `PRIMARY` (the `*` register) |
| Running inside tmux on X11 | Add `set-clipboard on` to `~/.tmux.conf` — tmux intercepts OSC 52 by default |

---

## GUI Linux — Wayland

### Tool: wl-clipboard

```sh
# Debian / Ubuntu / Mint
sudo apt install wl-clipboard

# Fedora
sudo dnf install wl-clipboard

# Arch Linux
sudo pacman -S wl-clipboard
```

`wl-clipboard` provides two binaries: `wl-copy` and `wl-paste`.  Neovim
detects them automatically when `$WAYLAND_DISPLAY` is set.

### Verify

```sh
echo "hello" | wl-copy
wl-paste          # should print: hello
```

Then in Neovim `<leader>p` should paste "hello".

### Wayland + X11 compatibility (XWayland)

If you start Neovim from an XWayland application (e.g. a legacy X11 terminal
inside a Wayland session), `$DISPLAY` may be set but `$WAYLAND_DISPLAY` may
not be inherited.  In that case Neovim falls back to `xclip`/`xsel`.  Either:

- Install both `wl-clipboard` **and** `xclip`, or
- Launch Neovim from a native Wayland terminal (e.g. foot, kitty, Ghostty)
  so that `$WAYLAND_DISPLAY` is inherited.

---

## WSL (Windows Subsystem for Linux)

### Tool: win32yank.exe

`win32yank.exe` is a small Windows utility that reads and writes the Windows
clipboard.  Because it runs as a Windows `.exe`, it is accessible from WSL
without X11 forwarding.

#### Install on the Windows side

Open a **Windows** PowerShell or Command Prompt (not a WSL shell):

```powershell
# Option 1 — Scoop (recommended)
scoop install win32yank

# Option 2 — Chocolatey
choco install win32yank

# Option 3 — Manual
# Download win32yank.exe from https://github.com/equalsraf/win32yank/releases
# Place it anywhere on your Windows PATH, e.g. C:\Windows\System32\
```

#### Make it visible from WSL

WSL inherits the Windows `PATH` by default (controlled by
`appendWindowsPath = true` in `/etc/wsl.conf`).  No extra steps are needed if
you installed via Scoop or Chocolatey.  Verify:

```sh
which win32yank.exe        # should print something like /mnt/c/Users/.../win32yank.exe
win32yank.exe --version    # should print a version string
```

If `which` prints nothing, add the directory containing `win32yank.exe` to
your shell's `$PATH` in `~/.bashrc` / `~/.zshrc`:

```sh
export PATH="$PATH:/mnt/c/path/to/win32yank/directory"
```

#### How the config uses it

When `WSL_DISTRO_NAME` is set and `win32yank.exe` is on `$PATH`, the config
registers it as a custom `vim.g.clipboard` provider that handles both `+` and
`*` registers.  The `--crlf` / `--lf` flags handle the Windows line-ending
difference automatically.

#### Verify

```sh
echo "hello from WSL" | win32yank.exe -i --crlf
win32yank.exe -o --lf     # should print: hello from WSL
```

Then open Notepad on Windows and paste — you should see the text.

> **Tip:** If `win32yank.exe` is not available Neovim falls back to built-in
> provider detection.  On WSL without a running X server this means clipboard
> will silently not work, so installing `win32yank.exe` is strongly recommended.

---

## SSH / TTY / Console — OSC 52

### No external tool required

When Neovim detects no graphical display (`$DISPLAY` and `$WAYLAND_DISPLAY`
are both unset), it uses the **OSC 52** terminal escape sequence
(`ESC ] 52 ; c ; <base64-data> BEL`).  This sequence instructs the **host
terminal** to place data into the system clipboard.

Because the escape sequence travels through the SSH byte stream, OSC 52 copies
directly to the **local machine's clipboard** without X11 forwarding or any
tool on the remote server.

**Minimum requirement:** Neovim ≥ 0.10 (the built-in
`vim.ui.clipboard.osc52` module).

### Terminal support matrix

| Terminal | Copy (→ clipboard) | Paste (← clipboard) | Notes |
|---|---|---|---|
| **Windows Terminal** | ✅ | ❌ | Paste disabled by default for security |
| **Alacritty** | ✅ | ✅ | Full support |
| **kitty** | ✅ | ✅ | Full support |
| **WezTerm** | ✅ | ✅ | Full support |
| **iTerm2** (macOS) | ✅ | ✅ | Enable in Prefs → General → Selection |
| **Ghostty** | ✅ | ✅ | Full support |
| **GNOME Terminal** (VTE) | ❌ | ❌ | VTE does not support OSC 52 |
| **xterm** | ✅ | ✅ | Requires `allowWindowOps: true` in `~/.Xresources` |

> **GNOME Terminal users over SSH:** GNOME Terminal does not support OSC 52.
> You have two options:
> - Connect from a terminal that does support it (Windows Terminal, kitty, etc.)
> - Use X11 forwarding (`ssh -X`) with `xclip`/`xsel` installed on the server

### Paste over SSH

Most terminals block OSC 52 paste for security (to prevent a remote host from
reading your clipboard).  If `<leader>p` does not work in an SSH session, use
the terminal's own paste shortcut to inject from the local clipboard:

| Terminal | Paste shortcut |
|---|---|
| Windows Terminal | `Ctrl+Shift+V` |
| GNOME Terminal | `Ctrl+Shift+V` |
| Alacritty | `Ctrl+Shift+V` (Linux) / `Cmd+V` (macOS) |
| kitty | `Ctrl+Shift+V` |
| Most Linux terminals | `Shift+Insert` |

### tmux inside SSH

tmux intercepts OSC 52 by default and does not forward it to the outer
terminal.  To enable clipboard pass-through, add this to `~/.tmux.conf`:

```sh
set -g set-clipboard on
```

Then reload: `tmux source ~/.tmux.conf`.

With `set-clipboard on`, tmux forwards OSC 52 to the outer terminal, which
then writes to the local clipboard.

### RDP sessions

RDP clipboard is a separate channel from the terminal clipboard.  OSC 52 works
if the RDP client renders a terminal that supports it (e.g. Windows Terminal
running inside an RDP session to a Windows machine).  On Linux desktops inside
RDP (e.g. xrdp + GNOME), you are back in a graphical session so `$DISPLAY` is
set — the config will use `xclip`/`xsel` automatically.

### Verify OSC 52 is working

In an SSH session, run:

```sh
nvim --headless -c 'lua vim.fn.setreg("+","osc52test")' -c 'qa'
```

Then try to paste in the local terminal — if you see `osc52test` it is
working.  Alternatively, open Neovim, type some text, visually select it, and
press `<leader>y`.  Switch to a local application and paste.

---

## Troubleshooting

### `:checkhealth clipboard`

Always start here.  Run `:checkhealth` in Neovim and read the `clipboard`
section:

```
clipboard
  - OK: Clipboard tool found: win32yank      ← WSL, working
  - OK: Clipboard tool found: wl-copy        ← Wayland, working
  - OK: Clipboard tool found: xclip          ← X11, working
  - WARNING: No clipboard tool found         ← need to install one
```

If the provider shows as `OSC 52` there will be no checkhealth entry — OSC 52
is transparent to Neovim's health check system.  Verify it empirically (see above).

### Common issues

| Problem | Likely cause | Fix |
|---|---|---|
| `y` copies but paste in other app is empty | Wrong register — `"*` vs `"+"` | Use `<leader>y` (explicit `"+` register) |
| Works locally, broken in SSH | No clipboard provider on the server | OSC 52 is active in console mode — check terminal support |
| `win32yank.exe: not found` in WSL | Not on `$PATH` | Verify Windows PATH is inherited; export manually if needed |
| OSC 52 works in tmux locally but not over SSH | tmux blocking OSC 52 | Add `set -g set-clipboard on` to `~/.tmux.conf` |
| Wayland — copies but other Wayland apps can't paste | Using X11 xclip instead of wl-clipboard | Check that `$WAYLAND_DISPLAY` is set in the shell that launches Neovim |
