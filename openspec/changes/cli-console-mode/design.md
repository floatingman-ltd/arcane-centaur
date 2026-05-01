## Context

The configuration already has a `terminal.lua` capability-detection module that exposes
`term.has_nerd_font`, `term.has_undercurl`, and `term.name`. Several tools — markdown
preview, PlantUML rendering, and URL opening — all funnel through `util.open_url`, which
assumes a graphical browser is available. When neither `$DISPLAY` nor `$WAYLAND_DISPLAY`
is set (physical TTY, SSH session, headless CI, remote server) all of these paths fail
silently or produce no useful output.

The AI research gap is orthogonal to console detection: there is currently no Q&A
assistant at all. `github/copilot.vim` provides inline completion only; no chat or
question-answering interface exists. This change adds `avante.nvim` for all environments
with two explicitly switchable backends.

## Goals / Non-Goals

**Goals:**
- All existing GUI paths work exactly as before — zero regression
- `term.is_console` is the single source of truth for routing decisions
- Every tool has a working, useful output in a console environment
- avante.nvim is available in all environments (GUI and console alike)
- ollama runs as a persistent Docker service consistent with existing `docker/` services

**Non-Goals:**
- Automatic network detection to choose between ollama and Copilot backends
- RAG / document ingestion for ollama
- Replacing `markdown-preview.nvim` — it stays, glow is an additional path
- Supporting GPU acceleration beyond a documented opt-in annotation in the compose file
- Web browsing (w3m, lynx) — the research story is Q&A only

## Decisions

### D1 — Console detection: environment variables only, no manual flag

`term.is_console` is derived purely from the absence of `$DISPLAY` and
`$WAYLAND_DISPLAY`:

```lua
M.is_console = (vim.env.DISPLAY or "") == ""
            and (vim.env.WAYLAND_DISPLAY or "") == ""
```

**Alternatives considered:**
- `$TERM == "linux"` — too narrow; misses SSH sessions where `$TERM` is `xterm-256color`
- `vim.g.cli_mode` manual flag — rejected; user confirmed "no GUI is the trigger", not
  intentional preference
- Checking for `xdg-open` / `open` executables — unreliable; both can be present on
  headless servers without a running display

This check correctly handles: physical TTY, SSH without X forwarding, headless Docker
containers, and tmux on a server (where `$DISPLAY` is unset). It correctly leaves GUI
tmux sessions (where the outer terminal has set `$DISPLAY`) on the GUI path.

---

### D2 — Markdown console preview: `glow.nvim` plugin, lazy-loaded with `cond`

Use `ellisonleao/glow.nvim` rather than shelling out to `glow` directly. The plugin
manages a floating window, handles buffer lifecycle, and exposes a `:Glow` command.
Loaded only when `is_console` via lazy.nvim's `cond` field:

```lua
{ "ellisonleao/glow.nvim", ft = { "markdown" }, cond = function() return term.is_console end }
```

`markdown-preview.nvim` is symmetrically conditioned on `not is_console` so exactly one
of the two plugins loads per session.

The ftplugin `after/ftplugin/markdown.lua` maps the preview key to `:Glow` when
`is_console` and to `:MarkdownPreview` otherwise, keeping the keymap consistent across
environments.

**Layout default: vertical split.** `glow.nvim` is configured with `width` and the
`pager = false` option to render into a vertical split rather than a float. This is set
via `vim.g.glow_use_pager = false` and a `style` option in the plugin opts. The default
can be switched to a floating window by setting `vim.g.glow_border = "rounded"` and
removing the split configuration — documented in `docs/guides/cli-console-mode.md`.

**Alternatives considered:**
- `:terminal glow %` in a split — works but no plugin management, no filetype integration
- `mdcat` CLI — less widely available than glow; glow has better colour rendering
- Floating window as default — rejected in favour of split for long-document readability

**Prerequisite:** `glow` binary must be installed (`apt install glow` /
`brew install glow`). The config checks `vim.fn.executable("glow")` and emits a WARN
notification at preview time if missing.

---

### D3 — PlantUML ASCII: parallel function using `/utxt/` endpoint, scratch buffer

The existing Docker server (`localhost:8080`) already supports:
- `/png/<encoded>` — PNG (current path)
- `/txt/<encoded>` — plain ASCII art
- `/utxt/<encoded>` — Unicode box-drawing art (preferred)

A new `puml_preview_ascii()` function mirrors `puml_preview()` but:
1. Builds the `/utxt/` URL instead of `/png/`
2. Uses `vim.fn.system("curl -s <url>")` to fetch the text response
3. Opens a scratch buffer (`buftype=nofile`, `bufhidden=wipe`) in a vertical split and
   writes the response lines into it

`:PumlPreviewAscii` is always registered (useful in GUI too). When `is_console`,
`:PumlPreview` is aliased to `PumlPreviewAscii` rather than the PNG path.

**Alternatives considered:**
- Local `plantuml.jar -tutxt` invocation — requires Java locally; the Docker server is
  already running and has no additional dep
- `ditaa` — different tool, different diagram language; out of scope

---

### D4 — avante.nvim: two named providers, explicit switching via keymaps

avante.nvim supports a `vendors` table for custom providers and a `provider` field for
the active one. Both `ollama` and `copilot` are first-class avante providers.

Configuration shape:

```lua
opts = {
  provider = "ollama",           -- offline-first default
  vendors = {
    ollama = {
      endpoint = "http://127.0.0.1:11434",
      model    = "llama3.1:8b",  -- default; switch to "llama3.2:3b" on low-RAM machines
    },
  },
  -- copilot provider uses existing github/copilot.vim auth automatically
}
```

Keymaps (global, `<leader>`-prefixed, defined in `lua/plugins/avante.lua`):

| Key | Action |
|---|---|
| `<leader>aa` | Open avante with current provider |
| `<leader>ao` | Switch to ollama provider + open |
| `<leader>ac` | Switch to copilot provider + open |

Switching is implemented via `require("avante").switch_provider("<name>")` followed by
`require("avante").open()`.

**Alternatives considered:**
- Auto-detect provider based on network availability — rejected; user explicitly wants
  manual control
- Two separate plugins (gen.nvim + CopilotChat.nvim) — more plugins, inconsistent UX,
  no unified interface
- `<localleader>` keymaps — rejected; AI research is global, not filetype-specific

---

### D5 — ollama Docker service: named volume, loopback-only, CPU default

Follows the exact pattern of `docker/plantuml-server/docker-compose.yml`:

```yaml
services:
  ollama:
    image: ollama/ollama
    ports:
      - "127.0.0.1:11434:11434"
    volumes:
      - ollama_models:/root/.ollama
    restart: unless-stopped
    # GPU (NVIDIA) — uncomment to enable:
    # deploy:
    #   resources:
    #     reservations:
    #       devices:
    #         - driver: nvidia
    #           count: 1
    #           capabilities: [gpu]

volumes:
  ollama_models:
```

Port bound to `127.0.0.1` only — consistent with other services, no LAN exposure.
Named volume ensures models (2–8 GB each) survive `docker compose down`.
GPU support is opt-in via commented annotation; no runtime detection attempted.

Models are not pulled automatically. The guide instructs the user to run:
```
docker compose exec ollama ollama pull llama3.1:8b
```

---

### D6 — `util.open_url` console branch: notify, don't fail silently

When `is_console`, skip all opener attempts and emit a `vim.notify` at `INFO` level with
the URL. This is expected behaviour (not an error), so `WARN` would be misleading.

```lua
if term.is_console then
  vim.notify("open_url: " .. url, vim.log.levels.INFO)
  return
end
```

This surfaces the URL so the user can act on it (copy, open in w3m manually, etc.)
rather than the current behaviour of exhausting all openers and emitting a WARN only
after all fail.

## Risks / Trade-offs

- **`glow` not installed** → `PumlPreview` / Glow keymap emits WARN at use time; lazy.nvim
  will still load the plugin. Mitigation: executable check in preview functions with a
  clear install instruction in the notification.

- **ollama service not running** → avante ollama provider will error on first request.
  Mitigation: documented startup steps in `docs/guides/cli-console-mode.md`; avante
  surfaces the HTTP error in its buffer rather than crashing Neovim.

- **avante.nvim dependency surface** → avante requires `nvim-lua/plenary.nvim`,
  `MunifTanjim/nui.nvim`, `stevearc/dressing.nvim`, and optionally `nvim-web-devicons`.
  `plenary` and `nvim-web-devicons` may already be pulled in transitively; `nui.nvim` and
  `dressing.nvim` are new. All are small, stable plugins. Mitigation: declare them
  explicitly as `dependencies` in the avante plugin spec so lazy.nvim manages versions.

- **`is_console` false positive in unusual terminals** → A terminal emulator that does
  not set `$DISPLAY` (rare but possible) would incorrectly activate console mode.
  Mitigation: acceptable edge case; the console path is always functional, just not the
  default preference.

- **avante.nvim API churn** → avante is actively developed; `switch_provider` API may
  change. Mitigation: pin to a specific tag in the lazy.nvim spec; update on demand.

## Migration Plan

1. Merge branch `cli-console-mode` into `main`
2. Install `glow` binary on any machine where console mode is used
3. Start ollama service: `docker compose -f ~/.config/nvim/docker/ollama/docker-compose.yml up -d`
4. Pull a model: `docker compose exec ollama ollama pull llama3.1:8b`
5. Reopen Neovim — lazy.nvim installs avante.nvim and glow.nvim on next startup
6. No rollback required: all changes are additive; removing the branch reverts to
   the pre-change state with no residual side effects (Docker volume can be pruned
   separately if desired)


