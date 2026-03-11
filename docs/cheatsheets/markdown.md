# Markdown Cheatsheet (markdown-preview + MARP)

**LocalLeader** = `,` in Markdown buffers

→ Back to [main cheatsheet](index.md) · Full guide: [../guides/diagrams.md](../guides/diagrams.md) · Presentations guide: [../guides/presentations.md](../guides/presentations.md)

## Markdown Preview (markdown-preview.nvim)

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
| `:MarkdownPreviewToggle` | Toggle browser Markdown preview |
| `:MdToPdf` | Export to PDF, rendering PlantUML and Mermaid diagrams via Docker |
| `:MarpPreview` | Open file in MARP preview server |
| `:MarpToPptx` | Export to PowerPoint (`.pptx`) |
| `:MarpToHtml` | Export to HTML |
| `:MarpToPdf` | Export to PDF (MARP slides only — no PlantUML rendering) |

---

*Keymaps defined in `after/ftplugin/markdown.lua`. MARP commands defined in `lua/config/marp.lua`. PDF export command defined in `lua/config/mdpdf.lua`. Plugin configured in `lua/plugins/markdown.lua`.*
