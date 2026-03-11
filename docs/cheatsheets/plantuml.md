# PlantUML Cheatsheet

**LocalLeader** = `,` in PlantUML buffers

→ Back to [main cheatsheet](index.md) · Full guide: [../guides/diagrams.md](../guides/diagrams.md)

## Preview & Export

| Keys | Mode | Action |
|---|---|---|
| `,p` | Normal | Render and open diagram as **SVG** in browser (`PumlPreview`) |
| `,s` | Normal | Export diagram to an **SVG file** alongside the source (`PumlExportSvg`) |

## User Commands

| Command | Description |
|---|---|
| `:PumlPreview` | Encode the current buffer and open it as SVG at `http://localhost:8080/svg/<encoded>` |
| `:PumlExportSvg` | Encode the current buffer, fetch SVG from the Docker server, and save it as `<stem>.svg` |

Both commands encode the buffer using the PlantUML server's native `~1` hex
format (pure Lua — no Python or other external tool required), then open or
download the result from the Docker server.
`curl` must be available for `:PumlExportSvg`.

## Fenced Code Blocks in Markdown

PlantUML diagrams embedded in Markdown fenced code blocks are rendered as SVG
when using the two export workflows:

| Workflow | How SVG is used |
|---|---|
| `,p` in Markdown | Browser preview via `markdown-preview.nvim` (rendered by Docker server) |
| `,dp` in Markdown | PDF export — SVG fetched from server, converted to PNG via `rsvg-convert` |

## Prerequisites

The PlantUML Docker server must be running before using any PlantUML command:

```sh
docker compose -f ~/.config/nvim/docker/plantuml-server/docker-compose.yml up -d
```

---

*Keymaps defined in `after/ftplugin/plantuml.lua`. Commands defined in `lua/plugins/plantuml.lua`.*
