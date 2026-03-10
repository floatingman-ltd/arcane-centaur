# Working with Presentations (MARP)

[MARP](https://marp.app/) (Markdown Presentation Ecosystem) turns standard Markdown files into slide decks. This configuration adds Neovim commands that use the official [marp-cli Docker image](https://hub.docker.com/r/marpteam/marp-cli/) to **preview** and **export** presentations — no local Node.js or Chromium install required.

| Feature | How it works |
|---|---|
| Live preview | Docker Compose runs a MARP server on `http://localhost:8880` |
| Export to PPTX | `docker run` with `--pptx` flag |
| Export to HTML | `docker run` with `--html` flag |
| Export to PDF | `docker run` with `--pdf` flag |

## Prerequisites

| Dependency | Purpose | Install hint |
|---|---|---|
| **Docker** | Run the MARP CLI container | [docs.docker.com](https://docs.docker.com/get-docker/) |
| **xdg-open** | Open the preview URL in a browser | Pre-installed on most Linux desktops |

## Starting the MARP Preview Server

A Docker Compose file is provided at `docker/marp/docker-compose.yml` using the `marpteam/marp-cli` image. Port 8880 is bound to localhost only (8080 is reserved for the PlantUML server).

```sh
# Start the server (serves the current directory):
docker compose -f ~/.config/nvim/docker/marp/docker-compose.yml up -d

# Or serve a specific slides directory:
MARP_DIR=~/slides docker compose -f ~/.config/nvim/docker/marp/docker-compose.yml up -d

# Stop it when done:
docker compose -f ~/.config/nvim/docker/marp/docker-compose.yml down
```

The server watches for file changes and refreshes automatically.

## Quick Start

1. Start the MARP preview server (if not already running):

   ```sh
   docker compose -f ~/.config/nvim/docker/marp/docker-compose.yml up -d
   ```

2. Open (or create) a Markdown file with the MARP front matter:

   ```sh
   nvim slides.md
   ```

3. Add MARP content:

   ```markdown
   ---
   marp: true
   theme: default
   paginate: true
   ---

   # My Presentation

   Welcome to my slide deck!

   ---

   ## Slide Two

   - Bullet point one
   - Bullet point two

   ---

   ## Slide Three

   ![bg right](image.png)

   Content alongside an image.
   ```

4. Press **`,mp`** to open the live preview in your browser.

5. Press **`,mx`** to export the file to PowerPoint (`.pptx`).

## Keybindings

`localleader` is **`,`** in markdown buffers.

| Keys | Action |
|---|---|
| `,mp` | Open file in MARP preview server (`MarpPreview`) |
| `,mx` | Export to PowerPoint (`.pptx`) (`MarpToPptx`) |
| `,mh` | Export to HTML (`MarpToHtml`) |
| `,md` | Export to PDF (`MarpToPdf`) |
| `,p` | Toggle standard Markdown preview (`MarkdownPreviewToggle`) |

## User Commands

The following commands are available in any markdown buffer:

| Command | Description |
|---|---|
| `:MarpPreview` | Open the current file in the MARP preview server |
| `:MarpToPptx` | Convert the current file to PowerPoint (`.pptx`) |
| `:MarpToHtml` | Convert the current file to a self-contained HTML file |
| `:MarpToPdf` | Convert the current file to PDF |

## How It Works

### Live preview (`:MarpPreview`)

The Docker Compose service starts `marp-cli` in server mode (`-s .`), which serves all Markdown files in the mounted directory as rendered slide decks at `http://localhost:8880/<filename>`. The `:MarpPreview` command opens this URL with `xdg-open`.

### Export (`:MarpToPptx`, `:MarpToHtml`, `:MarpToPdf`)

Each export command runs a one-shot Docker container:

```
docker run --rm --init \
  -v <buffer-dir>:/home/marp/app \
  -e MARP_USER="$(id -u):$(id -g)" \
  marpteam/marp-cli --allow-local-files <file> --pptx
```

The output file is written to the same directory as the source file. The `MARP_USER` environment variable ensures correct file ownership on Linux.

## Configuration

The MARP server port is set to **8880** (to avoid conflict with the PlantUML server on 8080). To change it, update:

| File | Setting |
|---|---|
| `docker/marp/docker-compose.yml` | Host port in `ports` mapping |
| `lua/config/marp.lua` | URL in the `preview` function |

## MARP Markdown Syntax

MARP extends standard Markdown with presentation-specific features:

| Feature | Syntax |
|---|---|
| Enable MARP | `marp: true` in YAML front matter |
| Slide separator | `---` (horizontal rule) |
| Theme | `theme: default` / `gaia` / `uncover` in front matter |
| Pagination | `paginate: true` in front matter |
| Background image | `![bg](image.png)` |
| Split background | `![bg left](image.png)` or `![bg right](image.png)` |
| Header / Footer | `header: "text"` / `footer: "text"` in front matter |
| Scoped directives | `<!-- _class: lead -->` for per-slide overrides |

See the [Marpit documentation](https://marpit.marp.app/) for the full directive reference.
