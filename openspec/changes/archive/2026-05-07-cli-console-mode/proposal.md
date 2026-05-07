## Why

Several tools in this Neovim configuration assume a GUI environment: markdown preview
launches a browser, PlantUML renders to PNG and opens it via `xdg-open`, and the AI
research story has no answer at all. When running in a headless or console-only
environment — a bare Linux TTY, an SSH session, a remote server without a display — all
of these silently fail or produce no useful output.

This change introduces a first-class CLI/console mode that activates automatically when
no graphical display is detected (`$DISPLAY` and `$WAYLAND_DISPLAY` are both unset). In
that mode every tool routes to a terminal-native alternative. GUI environments are
unchanged. Additionally, an AI research assistant (avante.nvim) is added for all
environments, with explicit backend switching between a local offline LLM (ollama) and
the existing GitHub Copilot connection.

## What Changes

- **`lua/config/terminal.lua`** — add `M.is_console` flag (no `$DISPLAY` and no
  `$WAYLAND_DISPLAY`); covers physical TTY, SSH, and any headless scenario
- **`lua/plugins/markdown.lua`** — when `is_console`, route markdown preview through
  `glow` in a terminal float; when GUI is available keep `markdown-preview.nvim`
- **`lua/plugins/plantuml.lua`** — add `PumlPreviewAscii` command that calls the existing
  Docker server's `/utxt/` endpoint and displays the Unicode art in a scratch buffer;
  when `is_console` this becomes the default `:PumlPreview` behaviour
- **`lua/config/util.lua`** — `open_url` gains a console branch: on `is_console` it
  notifies with the URL rather than silently failing (browser path unchanged for GUI)
- **`lua/plugins/avante.lua`** — new plugin spec for `avante.nvim` with two configured
  providers: `ollama` (local Docker service) and `copilot` (existing GitHub Copilot
  auth); explicit keymaps to open avante and switch provider
- **`docker/ollama/docker-compose.yml`** — new Docker service following the existing
  pattern (`plantuml-server`, `sbcl-swank`); named volume for model persistence; CPU by
  default with commented GPU annotations
- **`docs/guides/cli-console-mode.md`** — setup and usage guide covering: starting the
  ollama service, pulling models, switching avante providers, and using glow / ASCII
  PlantUML
- **`readme.md`** — update Plugin Overview, Keybindings, and Docker Services sections

## Capabilities

### New Capabilities

- `console-detection`: `term.is_console` flag in `terminal.lua` — true when no
  `$DISPLAY` and no `$WAYLAND_DISPLAY`; used by all tools to route to CLI alternatives
- `markdown-preview-glow`: Markdown preview via `glow` in a Neovim terminal float;
  activated automatically when `is_console`
- `plantuml-ascii`: PlantUML diagrams rendered as Unicode art in a scratch buffer via the
  existing Docker server's `/utxt/` endpoint; `:PumlPreviewAscii` always available,
  becomes the default when `is_console`
- `ai-research-ollama`: Offline AI Q&A via avante.nvim backed by the local ollama Docker
  service; `<leader>ao` opens avante with the ollama provider
- `ai-research-copilot`: Web-grounded AI Q&A via avante.nvim backed by GitHub Copilot;
  `<leader>ac` opens avante with the copilot provider
- `ollama-service`: Local LLM daemon as a Docker Compose service in `docker/ollama/`;
  exposes `localhost:11434`; named volume persists downloaded models across restarts

### Modified Capabilities

- `open-url`: `util.open_url` now handles the `is_console` case gracefully (notify with
  URL) instead of silently exhausting all openers and failing

## Impact

- New files: `lua/plugins/avante.lua`, `docker/ollama/docker-compose.yml`,
  `docs/guides/cli-console-mode.md`
- Modified: `lua/config/terminal.lua`, `lua/plugins/markdown.lua`,
  `lua/plugins/plantuml.lua`, `lua/config/util.lua`, `readme.md`
- External prerequisites: `glow` binary (for console markdown preview); `docker` and
  `docker compose` (already required for plantuml-server); ollama Docker service started
  manually per the guide; GitHub Copilot auth already present
- No breaking changes; all GUI paths remain exactly as they are today
