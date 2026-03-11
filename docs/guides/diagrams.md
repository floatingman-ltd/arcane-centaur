# Working with Diagrams (Markdown + PlantUML)

This configuration supports architectural and documentation diagrams through two complementary workflows:

| Workflow | Plugin(s) | Preview |
|---|---|---|
| PlantUML in Markdown code fences | [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim) | Browser (via Docker server) |
| Standalone `.puml` files | [plantuml-syntax](https://github.com/aklt/plantuml-syntax) + custom `:PumlPreview` | Browser (SVG via Docker server) |

Both workflows route rendering through a local PlantUML Docker server at `http://localhost:8080`. No local Java or PlantUML binary is needed.

Treesitter parsers (`markdown`, `markdown_inline`, `plantuml`) provide syntax highlighting and text objects for both file types.

[marksman](https://github.com/artempyanykh/marksman) LSP is configured for Markdown, providing cross-file link completion and diagnostics.

## Prerequisites

| Dependency | Purpose | Install hint |
|---|---|---|
| **PlantUML Docker server** | Render `.puml` diagrams | See [Docker setup](#starting-the-plantuml-server) below |
| **Node.js / npm** | Build step for markdown-preview.nvim | Install via nvm (see below) |
| **curl** | Download SVG files (`:PumlExportSvg`) | Pre-installed on most Linux distros |
| **xdg-open** | Open rendered diagram URLs in the browser | Pre-installed on most Linux desktops |
| **marksman** *(optional)* | Markdown LSP | `sudo apt install marksman` |

### Installing Node.js via nvm

Using [nvm](https://github.com/nvm-sh/nvm) installs the LTS release into a
user-managed prefix — no `sudo` needed for global packages:

```sh
# 1. Install nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash

# 2. Reload your shell
source ~/.bashrc   # or ~/.zshrc

# 3. Install and use the LTS release
nvm install --lts
nvm use --lts

# 4. Persist the default across new shells
nvm alias default lts/*

# 5. Verify
node --version
npm --version
```

> **WSL note:** nvm works identically on WSL — no extra steps required.

## Starting the PlantUML Server

A Docker Compose file is provided at `docker/plantuml-server/docker-compose.yml` using the `plantuml/plantuml-server:jetty` image. Port 8080 is bound to localhost only.

```sh
# Pull and start (runs in the background):
docker compose -f ~/.config/nvim/docker/plantuml-server/docker-compose.yml up -d

# Stop it when done:
docker compose -f ~/.config/nvim/docker/plantuml-server/docker-compose.yml down
```

The server is stateless — no build step or volume is needed. It will be available at `http://localhost:8080` immediately after startup.

## Quick Start

### Markdown with embedded PlantUML

1. Start the PlantUML server (if not already running):

   ```sh
   docker compose -f ~/.config/nvim/docker/plantuml-server/docker-compose.yml up -d
   ```

2. Open (or create) a Markdown file:

   ```sh
   nvim architecture.md
   ```

3. Add a PlantUML diagram in a fenced code block:

   ````markdown
   ## System Overview

   ```plantuml
   @startuml
   actor User
   User -> WebApp : HTTP request
   WebApp -> Database : SQL query
   Database --> WebApp : result set
   WebApp --> User : HTTP response
   @enduml
   ```
   ````

4. Press **`,p`** to open a live browser preview. The preview auto-refreshes as you edit.

### Standalone `.puml` files

1. Ensure the PlantUML server is running (see [Starting the PlantUML Server](#starting-the-plantuml-server)).

2. Open or create a `.puml` file:

   ```sh
   nvim sequence.puml
   ```

3. Write your diagram:

   ```plantuml
   @startuml
   Alice -> Bob : Hello
   Bob --> Alice : Hi there
   @enduml
   ```

4. Press **`,p`** to render and open the diagram as **SVG** in your browser via the Docker server.

5. Press **`,s`** to export the diagram as an **SVG file** (saved as `<stem>.svg` in the same directory).

## SVG Output

All diagram rendering uses the **SVG** format instead of PNG. SVG diagrams are:

- **Resolution-independent** — scale to any size without pixelation
- **Smaller** — typically a fraction of the size of an equivalent PNG
- **Browser-native** — all modern browsers render SVG directly

### SVG in Standalone `.puml` Files

`:PumlPreview` opens `http://localhost:8080/svg/<encoded>` with `xdg-open`. The browser
renders the SVG directly.

`:PumlExportSvg` fetches the same URL via `curl` and saves it as `<stem>.svg` alongside
the source file. The SVG file can be embedded in HTML pages, documentation sites, or
vector graphics editors.

### SVG in Fenced Code Blocks (Markdown)

PlantUML fenced code blocks in Markdown files are rendered in the browser preview by
`markdown-preview.nvim` via the local Docker server. Diagrams are served as SVG through
the server's `/svg/` endpoint.

When exporting Markdown to PDF (`:MdToPdf`), each fenced `plantuml` block is:

1. Encoded and fetched from `http://localhost:8080/svg/<encoded>`
2. Saved as a temporary `.svg` file
3. Converted to PNG via `rsvg-convert` (bundled in `pandoc/extra`) for LaTeX compatibility
4. Embedded in the PDF as a high-quality raster image

## Exporting to PDF

The `:MdToPdf` command exports the current Markdown document to PDF, rendering
all fenced `plantuml` code blocks as images via the local PlantUML server.

### Prerequisites

| Dependency | Purpose |
|---|---|
| **PlantUML Docker server** | Render PlantUML diagrams — must be running on `localhost:8080` |
| **`pandoc/extra` Docker image** | Pandoc + LaTeX PDF engine + `rsvg-convert` |

Pull the image once before first use:

```sh
docker pull pandoc/extra
```

### Usage

1. Ensure the PlantUML server is running (see [Starting the PlantUML Server](#starting-the-plantuml-server)).

2. Open a Markdown file that contains fenced PlantUML blocks:

   ```sh
   nvim architecture.md
   ```

3. Press **`,dp`** (or run `:MdToPdf`) to export to PDF.

   The output file is written to the same directory as the source file with a
   `.pdf` extension (e.g. `architecture.pdf`).

### How It Works

The command runs `pandoc/extra` via `docker run --rm --network=host`. A bundled
Pandoc Lua filter (`docker/md2pdf/plantuml-filter.lua`) intercepts each fenced
`plantuml` code block, encodes it using the PlantUML server's `~1` hex encoding
(pure Lua — no Python needed), and fetches the rendered SVG from
`http://localhost:8080`. For PDF output the SVG is converted to PNG via
`rsvg-convert` before Pandoc's LaTeX PDF engine assembles the document.

```
fenced plantuml block
  → filter hex-encodes content (~1 + hex, pure Lua)
  → HTTP GET localhost:8080/svg/~1<hexencoded>
  → SVG saved to /tmp
  → rsvg-convert SVG → PNG (for PDF/LaTeX output)
  → embedded as image in PDF
```

## Keybindings

`localleader` is **`,`** for both `markdown` and `plantuml` buffers.

| Keys | Filetype | Action |
|---|---|---|
| `,p` | markdown | Toggle browser preview (`MarkdownPreviewToggle`) |
| `,dp` | markdown | Export to PDF with PlantUML diagrams rendered (`MdToPdf`) |
| `,p` | plantuml | Render and open diagram as SVG in browser (`PumlPreview`) |
| `,s` | plantuml | Export diagram to SVG file (`PumlExportSvg`) |

## How PumlPreview Works

The `:PumlPreview` command (defined in `lua/plugins/plantuml.lua`) reads the current buffer and encodes it using the PlantUML server's native **hex encoding** format (`~1` prefix + lowercase hex bytes) — entirely in Lua with no external tools. It then constructs the URL:

```
http://localhost:8080/svg/~1<hexencoded>
```

This URL is opened with `xdg-open`. The Docker server renders the diagram and serves it as an SVG directly in your browser. No Python, Java, or other encoding tool is required.

## Configuration

The Docker server URL is hardcoded to `http://localhost:8080`. To change it, update these two locations:

| File | Setting |
|---|---|
| `lua/plugins/markdown.lua` | `vim.g.mkdp_preview_options.plantuml_server` |
| `lua/plugins/plantuml.lua` | URL string in the `puml_encode` function |

## LSP (marksman)

The `marksman` LSP server provides:
- **Link completion** — auto-complete `[text](path)` links to other files
- **Diagnostics** — broken links and malformed references are flagged inline
- **Go-to-definition** (`gd`) — jump to linked documents

See [readme.md](../../readme.md#lsp-support) for the shared LSP keybindings.

## Diagram Types Supported

PlantUML supports a wide range of diagram types in both workflows:

| Diagram | Keyword |
|---|---|
| Sequence | `@startuml` / `@enduml` |
| Class | `@startuml` with `class` blocks |
| Component | `@startuml` with `component` blocks |
| Activity | `@startuml` with `start` / `stop` |
| Use Case | `@startuml` with `actor` / `usecase` |
| Deployment | `@startuml` with `node` / `artifact` |
| State | `@startuml` with `state` blocks |
| Mind Map | `@startmindmap` / `@endmindmap` |
| Gantt | `@startgantt` / `@endgantt` |
| C4 | `@startuml` with `!include C4_Context.puml` |
