# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

This is a personal Neovim configuration ("arcane-centaur" / "Magical NeoVIM") targeting **Neovim ≥ 0.12**, geared toward REPL-driven development, AI assistance, and AsciiDoc/Antora documentation tooling. There is no build system — it is loaded by Neovim at startup.

## Architecture

`init.lua` loads, in order: `options` → `loader` → `keymaps` → `config.lsp`, then calls `config.claude_cli.setup()` and `config.openspec.setup()`.

- **`lua/loader/init.lua`** — bootstraps lazy.nvim (clones it on first launch) and imports all plugin specs via `{ import = "plugins" }`. `checker.enabled = true`, so lazy auto-checks for plugin updates.
- **`lua/plugins/`** — one file per plugin group, each returning a lazy.nvim spec table. Everything here is auto-imported; you never register a new file by hand. `lua/plugins/init.lua` holds bare-string specs for plugins needing no config.
- **`lua/config/`** — non-plugin Lua modules (LSP, terminal capability detection, and feature integrations like `claude_cli`, `openspec`, `jira`, `confluence`, `marp`, `mdpreview`). Modules that need bootstrapping expose `M.setup()` and are wired in from `init.lua`.
- **`after/ftplugin/<ft>.lua`** — filetype-specific overrides (indent, `<localleader>` REPL/eval maps, extra keymaps). Loaded automatically by Neovim's runtime for each filetype.

Lazy-loading is filetype-driven: plugins use lazy.nvim's `ft = { ... }` field so language tooling (Lisp/Clojure/Scheme/Fennel, F#, Haskell, Janet) loads only when you open those files.

## Key conventions

- **Leader keys**: `<leader>` is Space (global maps in `lua/keymaps.lua`); `<localleader>` is `,` (per-filetype REPL/eval maps in `after/ftplugin/`). All keymaps set a `desc` — which-key surfaces them.
- **LSP**: every server shares one `on_attach` in `lua/config/lsp.lua`. Add servers there with `lspconfig.<server>.setup{ on_attach = on_attach }`.
- **Formatting**: `lua/plugins/conform.lua` does format-on-save; add filetypes to its `formatters_by_ft`. F# uses `lsp_format = "prefer"`.
- **Terminal capabilities**: branch on `lua/config/terminal.lua`'s flags (`has_nerd_font`, `has_undercurl`, `name`) rather than hardcoding terminal-specific behavior.
- **Colorscheme**: TokyoNight; change the `style` variable at the top of `lua/plugins/colorscheme.lua`.
- **Diagnostics panel**: `folke/trouble.nvim` v3 (`lua/plugins/trouble.lua`) provides `<leader>x` maps for project/buffer diagnostics, symbols, LSP refs, quickfix, and loclist. Native `[d`/`]d`/`<leader>e` are preserved.
- **TODO annotations**: `folke/todo-comments.nvim` (`lua/plugins/todo-comments.lua`) highlights `TODO`/`FIXME`/`HACK`/`NOTE`/`WARN`; list via `<leader>xT` (fzf-lua) or `<leader>xt` (trouble). `]t`/`[t` remain vim-unimpaired tag navigation.
- **Debugging**: `nvim-dap` + `nvim-dap-ui` (`lua/plugins/dap.lua`) with function-key maps (`<F5>`/`<F9>`/`<F10>`/`<F11>`/`<F12>`/`<S-F5>`) and `<leader>b` group. netcoredbg auto-registered by easy-dotnet; haskell-tools auto-discovers Haskell DAP configs.
- **easy-dotnet**: `GustavEikaas/easy-dotnet.nvim` (`lua/plugins/dotnet.lua`, `ft = cs/fsharp`) — solution management, test runner, netcoredbg DAP registration. `lsp.enabled = false` (roslyn.nvim owns C# LSP). `<localleader>tt`/`tr`/`tb` in C# and F# ftplugins.

## Language support

| Language | LSP | REPL/eval |
|---|---|---|
| Common Lisp | — | Conjure + Swank (port 4005) |
| Clojure / Scheme / Fennel / Janet | — | Conjure built-in |
| F# | `fsautocomplete` | iron.nvim → `dotnet fsi` |
| Haskell | haskell-language-server | haskell-tools → GHCi |

## AI assistance

- **`lua/config/claude_cli.lua`** — `:ClaudeSuggest` / `:ClaudeExplain` (`<leader>gcs` / `<leader>gce`). These shell out to the `claude` CLI via `claude -p <prompt>` (`vim.system`) and show the result in a floating scratch window — they rely on Claude Code's own auth and the `claude` binary being on `$PATH`, **not** on `ANTHROPIC_API_KEY`.
- **`lua/plugins/avante.lua`** — Avante.nvim chat, **Ollama-only** (offline, small `qwen2.5:0.5b` model): `<leader>aa` open with current provider, `<leader>ao` (re)select ollama and open. The Claude/Anthropic provider is intentionally disabled (subscription-OAuth ToS risk); re-enable via an API key per the avante guide if needed.

GitHub Copilot and OpenCode have been removed in favour of Claude; the OpenSpec/feature workflows now live as Claude Code skills in `.claude/skills/` (see below).

## OpenSpec (spec-driven workflow)

This repo uses **OpenSpec** (`openspec/`, `schema: spec-driven`) to drive changes. Capabilities are documented as specs under `openspec/specs/<capability>/`, change proposals live in `openspec/changes/` and are moved to `openspec/changes/archive/` once shipped. `lua/config/openspec.lua` provides in-editor commands. When making a substantive feature change, check whether an OpenSpec proposal/spec is expected for it.

The OpenSpec and project workflows are also available as Claude Code skills in **`.claude/skills/`** — invoke them as slash commands: `/openspec-propose`, `/openspec-apply-change`, `/openspec-continue-change`, `/openspec-verify-change`, `/openspec-archive-change`, `/openspec-explore`, `/openspec-sync-specs`, `/openspec-onboard`, plus `/add-neovim-feature` and `/add-learning-lesson`.

## Documentation

**AsciiDoc under `docs/modules/ROOT/pages/` is the source of truth** (Antora site). The only Markdown in the repo is the root `readme.md` (metadata + link to the hosted site). Pages are organized by area: `languages/`, `editor/`, `ai/`, `content/`, `tooling/`, `learning/`. Each guide typically has a matching `*-cheatsheet.adoc`. The nav is `docs/modules/ROOT/nav.adoc` — add an `xref:` entry there when you add a page.

AsciiDoc filetype in-editor is **`asciidoctor`** (not `asciidoc`) — registered by `lua/plugins/asciidoc.lua` via `vim.filetype.add`. All `after/ftplugin/` and filetype-keyed config must use `asciidoctor`. Syntax/folding: `habamax/vim-asciidoctor`. In-buffer `markview.nvim` rendering was **deferred** (it needs `cathaysia/tree-sitter-asciidoc`, which is absent from nvim-treesitter master) — there is no `markview`/`<localleader>mv` toggle; re-enable when the grammar is available. Docker/Antora preview: `after/ftplugin/asciidoctor.lua`.

**User-visible changes must update the matching docs** (new/changed plugin → the relevant `languages|editor|ai|content|tooling` guide + cheatsheet; new keybinding → the relevant cheatsheet; new language → a new guide + cheatsheet + nav entries).

Build the docs site locally (requires Docker; output goes to `build/site/`, gitignored):

```sh
docker compose -f antora-playbook.yml run --rm antora antora-playbook.yml
```

## Validation

No CI, no test suite — validation is manual. Syntax-check all Lua from the repo root:

```sh
find . -name '*.lua' -print0 | xargs -0 luac -p
```

If `luac` is unavailable, run `:luafile %` / `:source %` inside Neovim, or `lua -e 'loadfile("<file>")()'` per file.

## Other tooling

- **`scripts/confluence_publish.sh`** — publish/pull a Markdown file to/from a Confluence page (`--pull`, `--comments`, `--force`); needs `CONFLUENCE_EMAIL` + related env vars. `lua/config/confluence.lua` / `lua/config/jira.lua` wrap Atlassian integration in-editor.
- **Serena MCP** (semantic code navigation) is configured for Claude Code at the user level in `~/.claude.json` (`serena start-mcp-server --context=claude-code --project-from-cwd` — it picks up `.serena/project.yml` in the repo root).
