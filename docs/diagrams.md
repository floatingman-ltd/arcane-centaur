# Working with Diagrams (Markdown + PlantUML)

This configuration supports architectural and documentation diagrams through two complementary workflows:

| Workflow | Plugin(s) | Preview |
|---|---|---|
| PlantUML in Markdown code fences | [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim) | Browser (via Docker server) |
| Standalone `.puml` files | [plantuml-syntax](https://github.com/aklt/plantuml-syntax) + custom `:PumlPreview` | Browser (via Docker server) |

Both workflows route rendering through a local PlantUML Docker server at `http://localhost:8080`. No local Java or PlantUML binary is needed.

Treesitter parsers (`markdown`, `markdown_inline`, `plantuml`) provide syntax highlighting and text objects for both file types.

[marksman](https://github.com/artempyanykh/marksman) LSP is configured for Markdown, providing cross-file link completion and diagnostics.

## Prerequisites

| Dependency | Purpose | Install hint |
|---|---|---|
| **PlantUML Docker server** | Render `.puml` diagrams | `docker run -d -p 8080:8080 plantuml/plantuml-server` |
| **Node.js / npm** | Build step for markdown-preview.nvim | `sudo apt install nodejs npm` |
| **python3** | Encode `.puml` buffers for the server API | Pre-installed on most Linux distros |
| **xdg-open** | Open rendered diagram URLs in the browser | Pre-installed on most Linux desktops |
| **marksman** *(optional)* | Markdown LSP | `sudo apt install marksman` / `brew install marksman` |

## Quick Start

### Markdown with embedded PlantUML

1. Start your PlantUML Docker server:

   ```sh
   docker run -d -p 8080:8080 plantuml/plantuml-server
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

1. Open or create a `.puml` file:

   ```sh
   nvim sequence.puml
   ```

2. Write your diagram:

   ```plantuml
   @startuml
   Alice -> Bob : Hello
   Bob --> Alice : Hi there
   @enduml
   ```

3. Press **`,p`** to render and open the diagram in your browser via the Docker server.

## Keybindings

`localleader` is **`,`** for both `markdown` and `plantuml` buffers.

| Keys | Filetype | Action |
|---|---|---|
| `,p` | markdown | Toggle browser preview (`MarkdownPreviewToggle`) |
| `,p` | plantuml | Render and open diagram in browser (`PumlPreview`) |

## How PumlPreview Works

The `:PumlPreview` command (defined in `lua/plugins/plantuml.lua`) reads the current buffer, encodes it using PlantUML's deflate + base64 encoding scheme via `python3`, then constructs the URL:

```
http://localhost:8080/png/<encoded>
```

This URL is opened with `xdg-open`. The Docker server renders the diagram and serves it as a PNG directly in your browser.

## Configuration

The Docker server URL is hardcoded to `http://localhost:8080`. To change it, update these two locations:

| File | Setting |
|---|---|
| `lua/plugins/markdown.lua` | `vim.g.mkdp_preview_options.plantuml_server` |
| `lua/plugins/plantuml.lua` | URL string in the `puml_preview` function |

## LSP (marksman)

The `marksman` LSP server provides:
- **Link completion** — auto-complete `[text](path)` links to other files
- **Diagnostics** — broken links and malformed references are flagged inline
- **Go-to-definition** (`gd`) — jump to linked documents

See [readme.md](../readme.md#lsp-support) for the shared LSP keybindings.

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
