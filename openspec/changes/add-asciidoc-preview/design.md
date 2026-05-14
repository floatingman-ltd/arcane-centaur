## Context

The current Markdown preview stack uses two tools:
- **Glow** (console): renders Markdown in the terminal as a floating popup
- **markdown-preview.nvim** (GUI): opens a live-reload browser preview server

Both are Markdown-only. The `after/ftplugin/markdown.lua` ftplugin wires `,p` and `,pp` to these tools conditionally on `term.is_console`.

AsciiDoc's rendered output is HTML. There is no widely-available terminal AsciiDoc renderer equivalent to Glow. The browser is the natural preview target. The project's established tooling philosophy is Docker-first for external tools (markserv, MARP, PlantUML, md2pdf all use Docker), so `asciidoctor/docker-asciidoctor` is the correct delivery mechanism.

## Goals / Non-Goals

**Goals:**
- `,p` and `,pp` work on `.adoc` files in GUI environments by converting to HTML and opening in the system browser
- Console mode degrades gracefully with a `vim.notify` warning (no crash, no silent failure)
- Conversion runs via `docker run --rm` — no global `asciidoctor` install required
- `after/ftplugin/asciidoc.lua` mirrors the structure of `after/ftplugin/markdown.lua`
- Docker usage is documented in `docker/asciidoctor/`

**Non-Goals:**
- Live-reload / watch mode for `.adoc` files (one-shot conversion is sufficient for preview)
- Terminal/console AsciiDoc rendering (not viable without a purpose-built tool)
- Replacing or wrapping the Markdown preview — `.md` files are unaffected
- Syntax highlighting or LSP for AsciiDoc (separate concern)

## Decisions

### GUI-only preview, console shows notification
AsciiDoc's canonical output is HTML. No terminal renderer exists with comparable fidelity to Glow for Markdown. Attempting to pipe HTML to `w3m`/`lynx` would produce a degraded experience worse than nothing. A clear `vim.notify` in console mode is more honest than a broken preview.

*Alternative considered*: `asciidoctor` → stdout → pipe to `w3m`. Rejected — HTML in a terminal browser strips formatting and defeats the purpose of previewing rich AsciiDoc output.

### `,p` and `,pp` behave identically for AsciiDoc
For Markdown, `,p` toggles (Glow or markdown-preview) and `,pp` forces the Glow popup. For AsciiDoc, there is no persistent server or popup equivalent — both keymaps trigger the same one-shot convert-and-open flow. Keeping both keymaps consistent with Markdown muscle memory avoids confusion.

*Alternative considered*: only map `,p`, omit `,pp`. Rejected — muscle memory from Markdown workflow; omitting `,pp` would cause a "no mapping" error when users try it reflexively.

### Docker over native `asciidoctor`
Using `docker run --rm asciidoctor/docker-asciidoctor` means no Ruby/gem install is needed. Consistent with how markserv, MARP, and PlantUML are delivered. The image is pulled automatically on first use (~200MB, one-time cost).

*Alternative considered*: check for native `asciidoctor` first, fall back to Docker (like the pandoc strategy in the Antora change). Rejected for this change — the Neovim preview is GUI-only and latency is acceptable; Docker-only keeps the implementation simple.

### WSL: `powershell.exe Start-Process` instead of `xdg-open`
On WSL, `xdg-open` exists but has no graphical browser registered (no Linux browser installed). The fix uses `term.is_wsl` to branch: on WSL, `wslpath -w` converts the Linux `/tmp/` output path to a Windows UNC path (`\\wsl.localhost\Ubuntu\tmp\...`), then `powershell.exe -NoProfile -Command "Start-Process '<path>'"` opens it in the Windows default browser. On non-WSL Linux, `xdg-open` is used as before.

*Alternative considered*: `explorer.exe` directly. Rejected — fails on UNC paths. `wslview` (wslu package). Rejected — not installed by default.

### `xdg-open` to launch browser
`xdg-open` is the standard Linux mechanism for opening a file in the default application. It works on GNOME Terminal (the project's recommended terminal) and most Linux desktops without configuration. Output is written to a temp file (`/tmp/asciidoc-preview-<bufnr>.html`).

*Alternative considered*: `$BROWSER` env var. Rejected — not always set; `xdg-open` is more reliable on the target platform.

### Separate `after/ftplugin/asciidoc.lua` file
Follows the existing pattern: `after/ftplugin/markdown.lua` handles `.md`, `after/ftplugin/asciidoc.lua` handles `.adoc`. Filetype-specific behaviour belongs in ftplugin files. No changes to shared config.

## Risks / Trade-offs

- **Docker must be running**: if Docker is not active, the preview silently fails. Mitigated by checking `docker info` before running and surfacing a `vim.notify` error with instructions.
- **First-use image pull delay**: `asciidoctor/docker-asciidoctor` (~200MB) is pulled on first use. Subsequent previews are fast. Mitigated by documenting this in the run script README.
- **`xdg-open` availability**: not available on WSL without additional setup. Acceptable — the project's primary platform is GNOME Terminal on Linux. WSL users can open the temp file manually.
- **Temp file accumulation**: `/tmp/asciidoc-preview-<bufnr>.html` is created per preview. Files in `/tmp` are cleared on reboot. Not a practical concern.
