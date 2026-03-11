# Working with Diagrams (Markdown + PlantUML + Mermaid)

This configuration supports architectural and documentation diagrams through three complementary workflows:

| Workflow | Plugin(s) | Preview |
|---|---|---|
| PlantUML in Markdown code fences | [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim) | Browser (via Docker server) |
| Mermaid in Markdown code fences | [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim) | Browser (**built-in, no extra plugin**) |
| Standalone `.puml` files | [plantuml-syntax](https://github.com/aklt/plantuml-syntax) + custom `:PumlPreview` | Browser (via Docker server) |

PlantUML rendering routes through a local PlantUML Docker server at `http://localhost:8080`. Mermaid diagrams are rendered natively by `markdown-preview.nvim`'s browser preview — **no extra plugin or server is required**.

Treesitter parsers (`markdown`, `markdown_inline`, `plantuml`) provide syntax highlighting and text objects for both file types.

[marksman](https://github.com/artempyanykh/marksman) LSP is configured for Markdown, providing cross-file link completion and diagnostics.

## Prerequisites

| Dependency | Purpose | Install hint |
|---|---|---|
| **PlantUML Docker server** | Render `.puml` diagrams | See [Docker setup](#starting-the-plantuml-server) below |
| **Node.js / npm** | Build step for markdown-preview.nvim | Install via nvm (see below) |
| **python3** | Encode `.puml` buffers for the server API | Pre-installed on most Linux distros |
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

### Markdown with embedded Mermaid

Mermaid diagrams are rendered directly by the browser preview — no Docker server or extra plugin is required.

1. Open (or create) a Markdown file:

   ```sh
   nvim architecture.md
   ```

2. Add a Mermaid diagram in a fenced code block:

   ````markdown
   ## Deployment Overview

   ```mermaid
   graph TD
       User -->|HTTP| LoadBalancer
       LoadBalancer --> AppA
       LoadBalancer --> AppB
       AppA --> Database
       AppB --> Database
   ```
   ````

3. Press **`,p`** to open a live browser preview. The Mermaid diagram renders automatically.

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

4. Press **`,p`** to render and open the diagram in your browser via the Docker server.

## Exporting to PDF

The `:MdToPdf` command exports the current Markdown document to PDF, rendering
all fenced `plantuml` and `mermaid` code blocks as PNG images.

### Prerequisites

| Dependency | Purpose |
|---|---|
| **PlantUML Docker server** | Render PlantUML diagrams — must be running on `localhost:8080` |
| **`pandoc/extra` Docker image** | Pandoc + LaTeX PDF engine |
| **Internet access** | Render Mermaid diagrams via the [Kroki](https://kroki.io) public API |

Pull the image once before first use:

```sh
docker pull pandoc/extra
```

> **No internet?** Mermaid blocks will be left as literal code in the PDF if the
> Kroki API is unreachable. PlantUML diagrams are unaffected as they use a local
> server. You can self-host Kroki with Docker to avoid the public API dependency —
> change the `KROKI_BASE_URL` constant at the top of
> `docker/md2pdf/mermaid-filter.lua` to point at your own instance.

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

The command runs `pandoc/extra` via `docker run --rm --network=host`. Two bundled
Pandoc Lua filters process diagram blocks before PDF assembly:

**PlantUML** (`docker/md2pdf/plantuml-filter.lua`) intercepts each fenced
`plantuml` code block, encodes it using PlantUML's deflate + base64 scheme, and
fetches the rendered PNG from `http://localhost:8080`.

**Mermaid** (`docker/md2pdf/mermaid-filter.lua`) intercepts each fenced
`mermaid` code block, encodes it with base64url, and fetches the rendered PNG
from the [Kroki](https://kroki.io) public API.

Pandoc's LaTeX PDF engine then assembles the document with both sets of images
inline.

```
fenced plantuml block                  fenced mermaid block
  → filter encodes content               → filter encodes content
  → HTTP GET localhost:8080/png/<enc>    → HTTP GET kroki.io/mermaid/png/<enc>
  → PNG saved to /tmp                    → PNG saved to /tmp
  → embedded as image in PDF             → embedded as image in PDF
```

## Keybindings

`localleader` is **`,`** for both `markdown` and `plantuml` buffers.

| Keys | Filetype | Action |
|---|---|---|
| `,p` | markdown | Toggle browser preview (`MarkdownPreviewToggle`) |
| `,dp` | markdown | Export to PDF with PlantUML diagrams rendered (`MdToPdf`) |
| `,p` | plantuml | Render and open diagram in browser (`PumlPreview`) |

## How PumlPreview Works

The `:PumlPreview` command (defined in `lua/plugins/plantuml.lua`) reads the current buffer, encodes it using PlantUML's deflate + base64 encoding scheme via `python3`, then constructs the URL:

```
http://localhost:8080/png/<encoded>
```

This URL is opened with `xdg-open`. The Docker server renders the diagram and serves it as a PNG directly in your browser.

## Configuration

The PlantUML server URL is hardcoded to `http://localhost:8080`. To change it, update these two locations:

| File | Setting |
|---|---|
| `lua/plugins/markdown.lua` | `vim.g.mkdp_preview_options.plantuml_server` |
| `lua/plugins/plantuml.lua` | URL string in the `puml_preview` function |

The Mermaid PDF export endpoint defaults to the Kroki public API (`https://kroki.io`). To self-host Kroki, change `KROKI_BASE_URL` at the top of `docker/md2pdf/mermaid-filter.lua`.

## LSP (marksman)

The `marksman` LSP server provides:
- **Link completion** — auto-complete `[text](path)` links to other files
- **Diagnostics** — broken links and malformed references are flagged inline
- **Go-to-definition** (`gd`) — jump to linked documents

See [readme.md](../../readme.md#lsp-support) for the shared LSP keybindings.

## Diagram Types Supported

### PlantUML

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

### Mermaid

Mermaid covers a complementary set of diagram types, all rendered with a
`mermaid` fence in Markdown:

| Diagram | Mermaid keyword |
|---|---|
| Flowchart | `graph TD` / `graph LR` |
| Sequence | `sequenceDiagram` |
| Class | `classDiagram` |
| State | `stateDiagram-v2` |
| Entity-Relationship | `erDiagram` |
| Gantt | `gantt` |
| Pie chart | `pie` |
| Git graph | `gitGraph` |
| Mind map | `mindmap` |
| Timeline | `timeline` |
