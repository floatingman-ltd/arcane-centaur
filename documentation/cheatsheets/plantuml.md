# PlantUML Cheatsheet

**LocalLeader** = `,` in PlantUML buffers

→ Back to [main cheatsheet](index.md) · Full guide: [../guides/diagrams.md](../guides/diagrams.md)

## Preview

| Keys | Mode | Action |
|---|---|---|
| `,p` | Normal | Render and open diagram in browser (`PumlPreview`) |
| `<leader>pa` | Normal | Open ASCII preview popup (`PumlPreviewAscii`) |

## User Command

| Command | Description |
|---|---|
| `:PumlPreview` | Encode the current buffer and open it in the PlantUML Docker server |
| `:PumlPreviewAscii` | Encode the current buffer and show ASCII preview in a floating popup |

The command reads the buffer, encodes it using PlantUML's deflate + base64
scheme via `python3`, then opens the result at `http://localhost:8080/png/<encoded>`
using the first available browser opener (`xdg-open` on Linux, `open` on macOS,
`wslview` or `explorer.exe` on WSL).

## Prerequisites

The PlantUML Docker server must be running before using `:PumlPreview`:

```sh
docker compose -f ~/.config/nvim/docker/plantuml-server/docker-compose.yml up -d
```

---

*Keymaps defined in `after/ftplugin/plantuml.lua`. `:PumlPreview` and `:PumlPreviewAscii` commands defined in `lua/plugins/plantuml.lua`.*
