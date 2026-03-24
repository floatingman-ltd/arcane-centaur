# Markdown Cheatsheet (markdown-preview + mkdnflow + markserv + MARP)

**LocalLeader** = `,` in Markdown buffers

→ Back to [main cheatsheet](index.md) · Markdown guide: [../guides/markdown.md](../guides/markdown.md) · Diagrams guide: [../guides/diagrams.md](../guides/diagrams.md) · Presentations guide: [../guides/presentations.md](../guides/presentations.md)

## Cross-page Link Navigation (mkdnflow.nvim)

| Keys | Mode | Action |
|---|---|---|
| `<CR>` | Normal | Follow link under cursor (opens target file in current window) |
| `<BS>` | Normal | Go back to the previous file |
| `<Tab>` | Normal | Jump to the next link in the buffer |
| `<S-Tab>` | Normal | Jump to the previous link in the buffer |

Use `<CR>` to follow a `[text](other-file.md)` link directly in the editor, then press `,p` or `,sp` to open the browser preview for that file. Press `<BS>` to return to the original file.

## Markdown Preview (markdown-preview.nvim)

| Keys | Mode | Action |
|---|---|---|
| `,p` | Normal | Toggle live browser preview (`MarkdownPreviewToggle`) |

The preview auto-refreshes as you edit. **Mermaid fenced code blocks render natively** in the browser — no extra plugin or Docker server required. PlantUML fenced code blocks are rendered via the PlantUML Docker server (`http://localhost:8080`).

**Limitation:** only the current buffer is served; clicking relative links to other `.md` files returns 404. Use the markserv server (`,sp`) for projects with cross-page links.

## Project Preview with Cross-page Links — markserv (requires Docker)

| Keys | Mode | Action |
|---|---|---|
| `,sp` | Normal | Open current file in markserv Docker preview server (`MdServerPreview`) |

The markserv server serves the **entire project directory**, so relative links between
`.md` files resolve correctly in the browser.  It also provides live reload (port 35729)
so the browser refreshes automatically when you save.

The server runs at `http://localhost:8090` via Docker Compose
(`docker/markserv/docker-compose.yml`). Start it from your project root:

```sh
docker compose -f ~/.config/nvim/docker/markserv/docker-compose.yml up -d --build
```

To serve a directory other than `$PWD`, set `MD_DIR`:

```sh
MD_DIR=/path/to/project \
  docker compose -f ~/.config/nvim/docker/markserv/docker-compose.yml up -d --build
```

| Keys | Mode | Action |
|---|---|---|
| `,p` | Normal | Toggle live browser preview (`MarkdownPreviewToggle`) |

The preview auto-refreshes as you edit. **Mermaid fenced code blocks render natively** in the browser — no extra plugin or Docker server required. PlantUML fenced code blocks are rendered via the PlantUML Docker server (`http://localhost:8080`).

## Export to PDF with PlantUML and Mermaid diagrams (requires Docker)

| Keys | Mode | Action |
|---|---|---|
| `,dp` | Normal | Export to PDF, rendering PlantUML and Mermaid diagrams (`MdToPdf`) |

Requires the PlantUML server (`docker/plantuml-server/docker-compose.yml`) and
the `pandoc/extra` Docker image (`docker pull pandoc/extra`). Mermaid blocks are
rendered via the [Kroki](https://kroki.io) public API (internet access required).
The PDF is written to the same directory as the source file. See [../guides/diagrams.md](../guides/diagrams.md#exporting-to-pdf).

## MARP Presentations (requires Docker)

| Keys | Mode | Action |
|---|---|---|
| `,mp` | Normal | Open file in MARP preview server (`MarpPreview`) |
| `,mx` | Normal | Export to PowerPoint (`.pptx`) (`MarpToPptx`) |
| `,mh` | Normal | Export to HTML (`MarpToHtml`) |
| `,md` | Normal | Export to PDF (`MarpToPdf`) |

The MARP preview server runs at `http://localhost:8880` via Docker Compose
(`docker/marp/docker-compose.yml`). Start it manually before using `,mp`:

```sh
docker compose -f ~/.config/nvim/docker/marp/docker-compose.yml up -d
```

## User Commands

| Command | Description |
|---|---|
| `:MarkdownPreviewToggle` | Toggle browser Markdown preview (single file) |
| `:MdServerPreview` | Open current file in markserv Docker server (cross-page links) |
| `:MdToPdf` | Export to PDF, rendering PlantUML and Mermaid diagrams via Docker |
| `:MarpPreview` | Open file in MARP preview server |
| `:MarpToPptx` | Export to PowerPoint (`.pptx`) |
| `:MarpToHtml` | Export to HTML |
| `:MarpToPdf` | Export to PDF (MARP slides only — no PlantUML rendering) |

---

*Link navigation keymaps provided by mkdnflow.nvim (`lua/plugins/mkdnflow.lua`). Preview keymaps defined in `after/ftplugin/markdown.lua`. Markserv command defined in `lua/config/mdpreview.lua`. MARP commands defined in `lua/config/marp.lua`. PDF export command defined in `lua/config/mdpdf.lua`. Preview plugin configured in `lua/plugins/markdown.lua`.*
