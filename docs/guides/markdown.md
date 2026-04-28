# Markdown Preview Guide

This guide covers all preview and export options for Markdown files:

- **`glow` CLI preview** — rich terminal-based markdown preview, no browser or Docker required
- **`markdown-preview.nvim`** — single-file browser preview with PlantUML and Mermaid diagram rendering
- **`markserv` Docker server** — project-wide directory preview where cross-page links between `.md` files resolve correctly
- **`mkdnflow.nvim`** — in-editor cross-page link navigation
- **PDF export** — Pandoc-based export with rendered diagrams

For diagrams specifically (PlantUML, Mermaid, PDF export), see **[diagrams.md](diagrams.md)**.  
For MARP presentation slides, see **[presentations.md](presentations.md)**.

---

## Quick Start

### CLI terminal preview — glow (no browser or Docker required)

1. Install [glow](https://github.com/charmbracelet/glow): `sudo snap install glow` or `brew install glow`.
2. Open any `.md` file in Neovim.
3. Press `,gp` to render a terminal preview using glow.
4. Press `q` or `Esc` to close the preview split.

This is the fastest preview option and works over SSH, on TTY consoles, and anywhere a browser is unavailable.

### Single-file preview (no Docker required)

1. Open any `.md` file in Neovim.
2. Press `,p` to toggle the live browser preview.
3. Edit; the preview auto-refreshes in the browser.

### Project-wide preview with cross-page links (requires Docker)

1. Start the markserv container from your markdown project root:
   ```sh
   # One-time build + start
   MD_DIR=/path/to/project \
     docker compose -f ~/.config/nvim/docker/markserv/docker-compose.yml up -d --build
   
   # Subsequent starts (image already built)
   MD_DIR=/path/to/project \
     docker compose -f ~/.config/nvim/docker/markserv/docker-compose.yml up -d
   ```
   If your project root is the directory you launched Neovim from, you can omit `MD_DIR`:
   ```sh
   docker compose -f ~/.config/nvim/docker/markserv/docker-compose.yml up -d
   ```

2. Open any `.md` file and press `,sp` to open it in the markserv server.

3. Click links to other `.md` files — they open and render correctly because
   the whole project directory is served.

4. Edit and save any file; the browser reloads automatically via SSE.

---

## PlantUML Server {#plantuml-server}

The markserv preview server generates `<img>` URLs pointing at
`http://localhost:8080` for `plantuml` fenced blocks.  The browser loads those
images directly from the PlantUML Docker server, so you must start it before
using PlantUML in the markserv preview:

```sh
docker compose -f ~/.config/nvim/docker/plantuml-server/docker-compose.yml up -d
```

The PlantUML server is stateless and starts instantly.  You can leave it running
permanently.  See [diagrams.md](diagrams.md) for the full guide.

---

## Glow CLI Preview (`,gp`)

[glow](https://github.com/charmbracelet/glow) is a terminal-based markdown
renderer from Charm.  It renders the current file in a Neovim terminal split,
providing syntax-highlighted headings, tables, code blocks, and links — all
without a browser or Docker.

### Prerequisites

Install glow via any of these methods:

```sh
# snap (Ubuntu/Linux)
sudo snap install glow

# Homebrew (macOS / Linuxbrew)
brew install glow

# Go
go install github.com/charmbracelet/glow@latest
```

### Usage

Press `,gp` in any markdown buffer.  A horizontal terminal split opens with the
rendered preview.  Press `q` to close the pager, then `:q` or `Ctrl-w c` to
close the split.

### When to use glow

| Situation | Use glow? |
|-----------|-----------|
| SSH session with no graphical browser | ✅ Yes |
| TTY console / headless server | ✅ Yes |
| Quick syntax-highlighted read of a single file | ✅ Yes |
| Diagrams (PlantUML, Mermaid) | ❌ Use `,p` or `,sp` (browser) |
| Cross-page link navigation in browser | ❌ Use `,sp` (markserv) |

---

## markdown-preview.nvim (`,p`)

`markdown-preview.nvim` opens a single-file browser preview that syncs with your
cursor position.  It renders:

- Standard Markdown (headings, tables, lists, code blocks)
- **Mermaid** fenced code blocks natively in the browser — no extra server needed
- **PlantUML** fenced code blocks via the PlantUML Docker server on `localhost:8080`

### Limitation — cross-page links

`markdown-preview.nvim` runs a minimal WebSocket server that serves **only the
current buffer**.  Clicking a relative link such as `[other page](other.md)` in
the browser navigates to a URL that the server cannot serve, returning 404.

For projects with multiple interlinked files use the markserv server (`,sp`) instead,
or use `mkdnflow.nvim` (`<CR>`) to navigate between files in the editor.

---

## Markserv Docker Server (`,sp`)

The markserv preview server is a custom Node.js server that renders a whole
directory tree.  Each `.md` file is rendered as GitHub-flavoured HTML on demand.
Because every file in the directory is reachable, relative links between markdown
files resolve correctly.

The server also renders diagrams embedded in fenced code blocks:

- **`plantuml`** fenced blocks are converted to `<img>` tags that fetch SVGs
  from the local PlantUML Docker server on `http://localhost:8080`.
  Start that server first — see [Starting the PlantUML Server](#plantuml-server).
- **`mermaid`** fenced blocks are rendered client-side by Mermaid.js loaded
  from the jsDelivr CDN — no extra server is needed.

### How it works

```
your project/
├── index.md          ← links to guide.md
├── guide.md          ← links to reference.md
└── reference.md
```

Start the container with `MD_DIR` pointing at the project root.  The container
mounts that directory at `/docs` and serves it.  Visiting
`http://localhost:8090/index.md` and clicking `[guide](guide.md)` navigates to
`http://localhost:8090/guide.md` — which the server renders correctly.

### Ports

| Port | Purpose |
|------|---------|
| `8090` | HTTP preview server (live reload via SSE on `/__livereload`) |

### Start / stop commands

```sh
# Start (builds the image on first run; subsequent starts skip the build)
MD_DIR=/path/to/project \
  docker compose -f ~/.config/nvim/docker/markserv/docker-compose.yml up -d --build

# Start without rebuild (image already built)
MD_DIR=/path/to/project \
  docker compose -f ~/.config/nvim/docker/markserv/docker-compose.yml up -d

# Stop
docker compose -f ~/.config/nvim/docker/markserv/docker-compose.yml down
```

> **Tip:** Set `MD_DIR` to the project root — the directory that contains all
> the interlinked markdown files.  If you start Neovim from that directory and
> omit `MD_DIR`, Docker Compose uses `$PWD` automatically.

---

## In-editor Navigation — mkdnflow.nvim

`mkdnflow.nvim` provides in-editor link following so you can navigate between
markdown files without leaving Neovim.

| Key | Action |
|-----|--------|
| `<CR>` | Follow link under cursor — opens the target file in the current window |
| `<BS>` | Go back to the previous file |
| `<Tab>` | Jump to the next link in the buffer |
| `<S-Tab>` | Jump to the previous link in the buffer |

After opening a linked file with `<CR>`, press `,p` to toggle the single-file
preview, or `,sp` to open it in the markserv server.

---

## Keybindings Summary

LocalLeader is `,` in Markdown buffers.

| Keys | Action |
|------|--------|
| `,gp` | Preview in terminal via glow (`GlowPreview` — no browser/Docker needed) |
| `,p` | Toggle `markdown-preview.nvim` single-file browser preview |
| `,sp` | Open current file in markserv Docker server preview (`MdServerPreview`) |
| `<CR>` | Follow link under cursor (mkdnflow — in-editor navigation) |
| `<BS>` | Go back to previous file (mkdnflow) |
| `<Tab>` | Jump to next link in buffer (mkdnflow) |
| `<S-Tab>` | Jump to previous link in buffer (mkdnflow) |
| `,dp` | Export to PDF with PlantUML and Mermaid diagrams rendered (`MdToPdf`) |
| `,mp` | Open MARP slide in preview server |
| `,mx` | Export MARP slide to PowerPoint (`.pptx`) |
| `,mh` | Export MARP slide to HTML |
| `,md` | Export MARP slide to PDF |

→ [Full cheatsheet](../cheatsheets/markdown.md)

---

## Choosing the Right Preview Tool

| Situation | Recommended tool |
|-----------|-----------------|
| Quick CLI preview, SSH, headless, no browser | `,gp` — glow terminal preview |
| Single file, diagrams, cursor sync | `,p` — markdown-preview.nvim |
| Multi-file project, cross-page links, diagrams | `,sp` — markserv Docker server |
| Navigate between linked files in editor | `<CR>` — mkdnflow.nvim |
| Export to PDF with diagram rendering | `,dp` — MdToPdf |
| MARP presentation slides | `,mp` — MARP Docker server |
