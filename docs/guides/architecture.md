# Configuration Architecture

This document explains the directory structure of this Neovim configuration —
what each directory and file is for, why it is placed where it is, and how the
pieces fit together at startup.

---

## Startup Order

Neovim always loads files in this sequence:

```
init.lua
  └── lua/options.lua      (vim options and leader keys)
  └── lua/loader/init.lua  (bootstraps lazy.nvim; loads all plugins)
  └── lua/keymaps.lua      (global keymaps)

after/ftplugin/<ft>.lua    (loaded by Neovim automatically when a filetype buffer opens)
```

Everything else is loaded on-demand — either by lazy.nvim when a plugin is
first needed, or by `require()` calls inside plugin config functions.

---

## Root-Level Files

| File | Purpose |
|---|---|
| `init.lua` | Entry point. Requires `options`, `loader`, and `keymaps` in order. Nothing else belongs here. |
| `lazy-lock.json` | Pinned commit hashes for every plugin. Guarantees reproducible installs. Managed by lazy.nvim — commit this file so all machines stay in sync. |
| `readme.md` | Human-readable overview: keybindings, supported languages, plugin list, Docker services. |
| `opencode.json` | Configuration for the opencode-ai editor assistant (separate from Copilot CLI). Points at the Serena MCP server and the Copilot instructions file. |

---

## `lua/` — The Lua Source Tree

All runtime Lua code lives here. Neovim adds `lua/` to the Lua `package.path`
automatically, so `require("config.terminal")` maps to `lua/config/terminal.lua`.

### `lua/options.lua`

Sets `vim.opt.*` values (line numbers, tabs, scroll offset, etc.) and the two
leader keys:

```lua
vim.g.mapleader      = " "   -- Space  (global keymaps)
vim.g.maplocalleader = ","   -- Comma  (filetype keymaps)
```

This file is loaded first so leader keys are defined before any plugin or
keymap tries to reference them.

### `lua/keymaps.lua`

Global `<leader>` keymaps that are not tied to any plugin or filetype. Things
like window navigation, buffer management, and diagnostic shortcuts.

### `lua/loader/init.lua`

Bootstraps [lazy.nvim](https://github.com/folke/lazy.nvim) (downloads it if
missing), then calls `lazy.setup()` with `{ import = "plugins" }`. This tells
lazy.nvim to auto-import every file under `lua/plugins/` as a plugin spec.

### `lua/plugins/` — Plugin Specs

One file per plugin group. Each file returns a lazy.nvim spec table. Examples:

| File | What it configures |
|---|---|
| `init.lua` | Bare-string plugins needing no config (statusline, surround, etc.) |
| `colorscheme.lua` | TokyoNight theme; change `style =` to switch variants |
| `avante.lua` | avante.nvim AI chat (ollama + copilot backends) |
| `conform.lua` | Format-on-save via conform.nvim |
| `copilot.lua` | GitHub Copilot inline completion |
| `fzf-lua.lua` | Fuzzy finder (files, grep, buffers) |
| `git.lua` | Fugitive + Gitsigns |
| `haskell.lua` | haskell-tools.nvim (LSP + GHCi REPL) |
| `lisp.lua` | Conjure, vim-sexp, parinfer, rainbow-delimiters (all Lisp dialects) |
| `markdown.lua` | markdown-preview.nvim (GUI) + glow.nvim (console terminal) |
| `nvim-cmp.lua` | Completion engine |
| `nvim-tree.lua` | File explorer sidebar |
| `plantuml.lua` | PlantUML syntax + ASCII/PNG preview via Docker server |
| `treesitter.lua` | Tree-sitter parsers for syntax highlighting and text objects |

Plugins use `ft = { "markdown" }` (lazy-load on filetype) or
`event = "VeryLazy"` (load after startup) to keep startup time fast.

### `lua/config/` — Non-Plugin Configuration Modules

Reusable Lua modules that are `require()`d by plugin configs or ftplugins.
They do not return lazy.nvim specs.

| File | Purpose |
|---|---|
| `terminal.lua` | Detects the terminal environment: `is_console`, `is_wsl`, `has_nerd_font`, `has_undercurl`. Plugin configs branch on these flags instead of hardcoding terminal-specific behaviour. |
| `lsp.lua` | Shared `on_attach` function and LSP server setup (`lspconfig.<server>.setup{}`). All servers use the same on_attach so keymaps are consistent. |
| `treesitter.lua` | Tree-sitter parser list and configuration (called from `lua/plugins/treesitter.lua`). |
| `util.lua` | Small shared helpers, e.g. `open_url()` which respects `is_console`. |
| `confluence.lua` | `:MdToConfluence`, `:MdFromConfluence`, `:MdConfluenceComments` commands. Requires `CONFLUENCE_EMAIL` + `CONFLUENCE_API_TOKEN` env vars. |
| `jira.lua` | `:JiraCreateIssue`, `:JiraCreateStory` commands. Requires `JIRA_EMAIL` + `JIRA_API_TOKEN` + `JIRA_BASE_URL` env vars. |
| `marp.lua` | `:MarpPreview`, `:MarpToPptx`, `:MarpToHtml`, `:MarpToPdf` via the MARP Docker container. |
| `mdpdf.lua` | `:MdToPdf` — Markdown → PDF with PlantUML diagrams via Docker. |
| `mdpreview.lua` | `:MdServerPreview` — live Markdown preview via the markserv Docker container (handles cross-page links). |
| `openspec.lua` | OpenSpec workflow integration (proposal/spec/task management). |
| `copilot_cli.lua` | Helpers for the GitHub Copilot CLI integration. |

---

## `after/ftplugin/` — Filetype-Specific Overrides

Neovim automatically sources `after/ftplugin/<filetype>.lua` when a buffer of
that filetype is opened. This is the correct place for:

- Setting `vim.b.maplocalleader`
- Filetype-specific indent settings
- `<localleader>` keymaps (REPL, preview, export, etc.)
- Calling `require("config.<module>").setup()` for filetype modules

| File | Filetype | Key things it does |
|---|---|---|
| `markdown.lua` | `markdown` | `,p` preview (glow/markdown-preview); Confluence, Jira, MARP, PDF commands |
| `plantuml.lua` | `plantuml` | `,p` / `,pa` diagram preview via Docker |
| `lisp.lua` | `lisp` | Conjure REPL keymaps, parinfer mode |
| `clojure.lua` | `clojure` | Conjure REPL keymaps |
| `scheme.lua` | `scheme` | Conjure REPL keymaps |
| `fsharp.lua` | `fsharp` | iron.nvim REPL keymaps (`dotnet fsi`) |
| `haskell.lua` | `haskell` | haskell-tools keymaps (GHCi REPL, Hoogle search) |
| `html.lua` | `html` | Indent overrides |
| `http.lua` | `http` | rest.nvim request execution keymaps |
| `cs.lua` | `cs` (C#) | .NET / OmniSharp keymaps |

---

## `docker/` — Docker Service Definitions

Each subdirectory is a self-contained Docker Compose service used by a Neovim
feature. Start them independently with `docker compose -f <path> up -d`.

| Directory | Service | Used by |
|---|---|---|
| `plantuml-server/` | PlantUML HTTP server (port 8080) | `:PumlPreview`, `:PumlPreviewAscii`, Markdown PDF export |
| `markserv/` | Markserv live-reload server | `:MdServerPreview` (cross-page Markdown links) |
| `marp/` | MARP CLI renderer | `:MarpPreview`, `:MarpToPptx`, `:MarpToHtml`, `:MarpToPdf` |
| `md2pdf/` | Pandoc + filters for PDF export | `:MdToPdf` (includes PlantUML + Mermaid diagram rendering) |
| `ollama/` | Ollama LLM server (port 11434) | avante.nvim ollama backend |
| `sbcl-swank/` | SBCL Common Lisp + Swank server (port 4005) | Conjure Common Lisp REPL |

---

## `docs/` — User Documentation

Human-readable reference material. Not loaded by Neovim.

### `docs/guides/`

Long-form setup and usage guides, one per feature area. Start here when
setting up a new language or feature on a fresh machine.

### `docs/cheatsheets/`

Quick-reference keymap tables. `index.md` is the single-page master reference.
Each other file covers one plugin or language area.

### `docs/jira-project-map.md`

Maps directory prefixes to Jira project keys. Used by `lua/config/jira.lua`
to automatically select the right Jira project when creating issues.

---

## `scripts/` — Shell and Pandoc Scripts

Helper scripts invoked by Neovim commands, not intended to be run directly
by the user.

| File | Purpose |
|---|---|
| `confluence_publish.sh` | Converts Markdown → Confluence storage format and POSTs via REST API |
| `confluence_preproc.py` | Python pre-processor: resolves local image paths and PlantUML blocks before publish |
| `confluence_filter.lua` | Pandoc Lua filter used during Confluence conversion |

---

## `openspec/` — OpenSpec Change Management

OpenSpec is a lightweight spec-driven workflow for tracking proposed changes
to this configuration. It is used by the Copilot CLI and opencode-ai assistants.

```
openspec/
  config.yaml          # Schema declaration (spec-driven)
  specs/               # Ratified/merged specs (source of truth)
  changes/             # In-progress changes
    <change-name>/
      proposal.md      # What and why
      design.md        # How (technical approach)
      tasks.md         # Implementation checklist
      specs/           # Delta specs for this change
        <feature>/
          spec.md      # Requirement + scenarios for one feature slice
    archive/           # Completed changes (historical record)
```

Active changes in `changes/` represent work in progress. Once implemented and
verified, a change is archived (moved to `changes/archive/`) and its specs are
merged into the top-level `specs/` directory.

---

## `.github/` — Copilot CLI Integration

| Path | Purpose |
|---|---|
| `copilot-instructions.md` | Loaded as system context by GitHub Copilot CLI for every session in this repo. Describes architecture, conventions, and documentation policy. |
| `prompts/` | Named prompt files for OpenSpec workflow steps (invoked via `/` commands in Copilot CLI). |
| `skills/` | Copilot CLI skill definitions — each `SKILL.md` describes how to invoke an OpenSpec workflow step. |

---

## `.opencode/` — opencode-ai Integration

Mirror of `.github/skills/` for the opencode-ai editor assistant. Contains
the same OpenSpec skill definitions in the format opencode-ai expects.

---

## `.serena/` — Serena MCP Server State

Runtime state for the [Serena](https://github.com/oraios/serena) MCP server:

| Path | Purpose |
|---|---|
| `project.yml` | Project-level Serena configuration (shared, committed) |
| `project.local.yml` | Machine-local overrides (gitignored) |
| `cache/` | Serena's symbol index cache (gitignored, rebuilt automatically) |
| `memories/` | Persistent memory files written by AI assistants during sessions |

---

## `testdocs/`

Sample files used for manual testing of preview features (e.g. `test.puml` for
verifying the PlantUML ASCII preview). Not part of the production config.
