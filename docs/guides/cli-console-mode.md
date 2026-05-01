# Console Mode Guide

This guide covers how the configuration adapts when no graphical display is available — physical TTY, SSH sessions without X forwarding, and headless servers — and documents the AI research assistant that works in all environments.

## Console Detection

The configuration detects console mode via a single boolean flag:

```lua
local term = require("config.terminal")
if term.is_console then ...
```

`is_console` is `true` when **both** `$DISPLAY` and `$WAYLAND_DISPLAY` are
unset. It is `false` when either is set, which covers:

| Environment | `$DISPLAY` | `$WAYLAND_DISPLAY` | `is_console` |
|---|---|---|---|
| Physical TTY (`$TERM=linux`) | unset | unset | `true` |
| SSH without X forwarding | unset | unset | `true` |
| tmux on headless server | unset | unset | `true` |
| X11 GUI terminal | set (e.g. `:0`) | unset | `false` |
| Wayland GUI terminal | unset | set (e.g. `wayland-0`) | `false` |
| tmux inside GUI terminal | set (outer terminal sets it) | — | `false` |

No manual override flag is needed. If the detection is wrong for your setup,
file an issue.

## Markdown Preview — Glow

In console sessions, `:MarkdownPreview` (which opens a browser) is replaced by
[glow](https://github.com/charmbracelet/glow), which renders Markdown with
colour and tables in a floating popup window.

### Prerequisites

Install the `glow` binary:

```sh
# Debian / Ubuntu (via Charmbracelet apt repo)
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://repo.charm.sh/apt/gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" \
  | sudo tee /etc/apt/sources.list.d/charm.list
sudo apt update && sudo apt install glow

# macOS
brew install glow

# Other: https://github.com/charmbracelet/glow#installation
```

Neovim will emit a `WARN` notification at preview time if `glow` is not found
on `$PATH` — it will not crash.

### Usage

The preview keymap is consistent across environments:

| Key | Console | GUI |
|---|---|---|
| `,p` | `:Glow` — floating popup with rendered Markdown | `:MarkdownPreviewToggle` — opens in browser |

Press `q` or `<Esc>` to close the popup.

### Customising the popup

Override the glow options in `lua/plugins/markdown.lua` to adjust the
appearance (border style, max dimensions):

```lua
opts = {
  border = "rounded",   -- "shadow", "none", "double", "solid", "single"
  width  = 120,         -- max popup width in columns
  height = 80,          -- max popup height in lines
  pager  = false,
},
```

## PlantUML ASCII Preview

`:PumlPreviewAscii` fetches plain ASCII art from the PlantUML Docker server's
`/txt/` endpoint and writes it into a scratch buffer in a vertical split. It is
available in all environments (GUI and console alike).

In console mode, `:PumlPreview` is automatically routed to
`:PumlPreviewAscii`. In GUI mode, `:PumlPreview` opens the PNG in the browser
as before.

> **Known limitation:** The current image (`plantuml/plantuml-server:jetty`)
> does not support the `/utxt/` endpoint (Unicode box-drawing characters).
> Output uses plain ASCII (`-`, `|`, `+`) instead. To enable Unicode art,
> switch the docker-compose image to `plantuml/plantuml-server:latest` (or a
> confirmed `/utxt/`-capable tag) and change the endpoint in
> `lua/plugins/plantuml.lua` from `/txt/` back to `/utxt/`.

### Prerequisites

The PlantUML Docker server must be running:

```sh
docker compose -f ~/.config/nvim/docker/plantuml-server/docker-compose.yml up -d
```

### Keymaps (plantuml buffers)

| Key | Action |
|---|---|
| `,p` | `:PumlPreview` — ASCII in console, PNG in GUI |
| `,pa` | `:PumlPreviewAscii` — plain ASCII art, always available |

> `:PumlPreviewAscii` is also useful in GUI when you want the text output without opening a browser.

## Open URL Behaviour

In console mode, `util.open_url` skips all browser-opener attempts and instead emits an `INFO` notification containing the full URL. Copy it and open it manually (e.g. in w3m, or paste it into a GUI browser on another machine).

In GUI mode, the existing behaviour is unchanged: `xdg-open` / `open` / `wslview` / `explorer.exe` are tried in order, and a `WARN` notification is emitted if none are found.

## AI Research — Avante

[avante.nvim](https://github.com/yetone/avante.nvim) provides a Q&A chat
interface inside Neovim. Two backends are available and can be switched at any
time:

| Backend | When to use |
|---|---|
| **ollama** (default) | Offline / air-gapped / low-latency — runs locally via Docker |
| **copilot** | Online — uses the existing `github/copilot.vim` authentication |

> **Version pin:** avante.nvim is pinned to `v0.0.27` in `lua/plugins/avante.lua`.
> The `build = "make"` step downloads prebuilt `.so` binaries from the GitHub
> release. Do not update beyond `v0.0.27` until a newer release publishes Linux
> binaries — running `make` against an unreleased commit produces a
> `"release not found"` error and avante will not load.

### Keymaps (global)

| Key | Action |
|---|---|
| `<leader>aa` | Open avante with the current provider |
| `<leader>ao` | Switch to ollama provider and open avante |
| `<leader>ac` | Switch to copilot provider and open avante |

### Ollama Setup

Ollama runs as a persistent Docker service. **Both commands below are required
on first setup.**

**Step 1 — Start the container** (runs in the background; restarts automatically
on reboot):

```sh
docker compose -f ~/.config/nvim/docker/ollama/docker-compose.yml up -d
```

**Step 2 — Download the model into the running container** (one-time per model;
stored in a named Docker volume so it survives container restarts). Pull the
default 8B model (~4 GB):

```sh
docker compose -f ~/.config/nvim/docker/ollama/docker-compose.yml \
  exec ollama ollama pull llama3.1:8b
```

On low-RAM machines (< 8 GB) use the smaller 3B model instead:

```sh
docker compose -f ~/.config/nvim/docker/ollama/docker-compose.yml \
  exec ollama ollama pull llama3.2:3b
```

Then update `model` in `lua/plugins/avante.lua`:

```lua
model = "llama3.2:3b",
```

#### GPU Acceleration (NVIDIA)

GPU support is opt-in. Open `docker/ollama/docker-compose.yml` and uncomment
the `deploy` block:

```yaml
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          count: 1
          capabilities: [gpu]
```

Requires the [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html).

#### When ollama is unreachable

If the ollama service is not running when you submit a question, avante will
display the HTTP error in its buffer. Neovim will not crash. Start the service
and retry.

### Copilot Backend

No additional setup is required. Avante reuses the credentials already held by
`github/copilot.vim`. If Copilot is not yet authenticated, run `:Copilot setup`
first.
