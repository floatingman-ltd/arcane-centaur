## Why

The config has several "lookup" affordances, but no single place to **ask a free-form question and get a prose answer inside the editor**:

- `<leader>?` / `<leader>?g` (context-aware cheatsheet, guides) — curated and static; you *read* them, you don't *ask*.
- which-key — discover bound keys interactively, but only keys.
- avante (`<leader>aa`) — a full chat sidebar; heavyweight for a single throwaway question.
- `:ClaudeExplain` / `:ClaudeSuggest` — operate on the current buffer/selection with *fixed* prompts; there is no free-form question box.

Two kinds of question recur while editing, and they want different sources:

1. **About *this* config** — e.g. "what's the command to toggle the terminal?" The honest answer is `<leader>t` (a custom `toggle_terminal()` in `lua/keymaps.lua`), which is config-specific. A generic LLM answer ("use `:terminal` and `<C-\><C-n>`") is *wrong* for this setup.
2. **General knowledge** — e.g. "what are the directives for the Common Lisp `format` function?" Pure model knowledge; no local context needed.

This change adds a **research popup**: type a question, get an answer in a floating window. Two entry points share an **identical look and feel** and differ only in where the answer comes from — local (grounded in this config) vs general (model knowledge). The user already knows which kind of question they're asking, so they pick the entry point directly; there is no mode selector.

## What Changes

- **New `lua/config/research.lua`** module (`M.setup()`, wired into `init.lua`) — mirrors `claude_cli.lua`. Prompts for a free-form question, shells out to `claude -p` via `vim.system` (async), and renders the response in a shared floating window.
- **Two commands / keymaps** under the existing `<leader>?` help namespace, with identical UX:
  - `:ResearchLocal` (`<leader>?l`) — prepends config context (live keymap descriptions + assembled cheatsheet content) and instructs the model to answer **only** from that context, stating when it cannot.
  - `:ResearchAsk` (`<leader>?a`) — sends the bare question (general knowledge).
- **Shared float helper** — lift the currently-private `open_float()` out of `claude_cli.lua` into `lua/config/util.lua` so `research` and `claude_cli` render through *one* helper. This is what guarantees the two paths look and feel identical (one window implementation, not two copies).
- **Documentation** — an entry in the AI tools guide + cheatsheet, the global keybindings reference, and the in-editor `cheatsheets/core.md`.

## Capabilities

### New Capabilities

- `research-popup`: A free-form question popup with two identical-UX entry points. `:ResearchLocal` (`<leader>?l`) answers questions about *this* Neovim configuration, grounded in live keymap descriptions and the assembled cheatsheet content, and is instructed not to fabricate beyond that context. `:ResearchAsk` (`<leader>?a`) answers general-knowledge questions from the model. Both prompt via a single shared input mechanism, run `claude -p` asynchronously using Claude Code's built-in authentication, and render the response in the shared floating-window helper (markdown highlighting, `q`/`<Esc>` to dismiss).

### Modified Capabilities

<!-- none — `claude-cli-integration` behaviour is unchanged; the float helper it uses simply moves to a shared util module (refactor only, see Impact). -->

## Impact

- `lua/config/research.lua` — new file: input prompt, prompt assembly (local vs general), async `claude -p` call, result float.
- `lua/config/util.lua` — add shared `open_float(title, lines)` helper.
- `lua/config/claude_cli.lua` — refactor to call `util.open_float`; remove its private copy (no observable behaviour change).
- `init.lua` — call `require("config.research").setup()`.
- `lua/keymaps.lua` — add `<leader>?l` → `:ResearchLocal` and `<leader>?a` → `:ResearchAsk`.
- `docs/modules/ROOT/pages/ai/ai-tools.adoc` + `ai-tools-cheatsheet.adoc` — document the popup and the two keys.
- `docs/modules/ROOT/pages/editor/keybindings.adoc` — add the two keys to the global reference.
- `cheatsheets/core.md` — add `<leader>?l` / `<leader>?a` for in-editor discoverability.
