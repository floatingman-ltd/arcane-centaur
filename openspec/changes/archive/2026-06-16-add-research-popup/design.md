## Context

The configuration already integrates the `claude` CLI for code-centric tasks (`:ClaudeExplain` / `:ClaudeSuggest` in `lua/config/claude_cli.lua`) and a full chat sidebar (avante). It also has rich, static reference material: the context-aware cheatsheet (`lua/config/cheatsheet.lua` + `cheatsheets/`), which-key, and the AsciiDoc/Antora docs site. What it lacks is a quick way to *ask a free-form question and read a prose answer* without leaving the editor or opening a chat session.

Crucially, "research" splits into two query classes that need different sources:

- **Config-specific** ("what's the command to toggle the terminal?") — the truthful answer lives in *this* config (`<leader>t`, a custom function). An ungrounded LLM confidently returns generic Neovim advice that does not match the setup.
- **General knowledge** ("Common Lisp `format` directives") — answered cold by the model.

The user knows which class a question belongs to at ask time, so the design exposes two entry points rather than trying to auto-route. The hard requirement is that both entry points feel *identical*: same input prompt, same result window. The only difference is invisible — how the prompt is assembled before the `claude -p` call.

## Goals / Non-Goals

**Goals:**

- Ask a free-form question from any buffer and read the answer in a floating window.
- Two entry points (`<leader>?l` local, `<leader>?a` general) with an **identical** input + result experience.
- The local path is grounded in this config's *live* keymap descriptions and assembled cheatsheets, and is instructed not to answer beyond that context.
- Reuse the existing `claude_cli` plumbing (CLI invocation + float) — one shared float helper, zero new plugin dependencies.
- Use Claude Code's built-in auth (no `ANTHROPIC_API_KEY`), matching `claude_cli`.

**Non-Goals:**

- Multi-turn conversation or chat history — that is what avante is for.
- Live web search / current-events lookups — v1 is single-shot model knowledge (can be added later).
- Replacing the cheatsheet, which-key, or avante.
- A fuzzy-search-over-docs picker — a possible later `<leader>?f`, out of scope here.
- Agentic file reading (letting `claude` grep the repo) — too slow/heavy for a popup; grounding is done by prepending a compact context blob instead.

## Decisions

### 1. Reuse `claude_cli` plumbing; lift `open_float()` into `util.lua`

The result window must be *the same* one `:ClaudeExplain` already uses. `open_float()` is currently a private local in `claude_cli.lua`. Move it verbatim into `lua/config/util.lua` as `M.open_float(title, lines)` and have both `claude_cli` and `research` call it.

**Alternatives considered:**
- *Duplicate the float code into `research.lua`*: two implementations drift apart, breaking the "identical look and feel" requirement. Discarded.
- *Each module keeps its own float*: same drift risk, directly contradicts the requirement. Discarded.

A single helper is the mechanism that *guarantees* parity.

### 2. Free-form input via `vim.ui.input`

The question prompt uses `vim.ui.input({ prompt = "Research: " }, cb)`. dressing.nvim (an avante dependency) upgrades this into a floating input box when loaded; if it is not yet loaded, Neovim falls back to a command-line prompt — acceptable graceful degradation. Empty or cancelled input aborts before any CLI call.

**Alternative considered:** a custom scratch-buffer input float — more code for a marginal UX gain over dressing-enhanced `vim.ui.input`. Discarded for v1.

### 3. Two commands, not one command with a mode selector

The user knows up front whether a question is about the config or general. Two entry points (`:ResearchLocal`, `:ResearchAsk`) mean zero friction; a single command that asks "local or general?" adds a selection step every time. Binding both under the existing `<leader>?` *help* namespace makes them discoverable via which-key alongside the cheatsheet keys.

### 4. Local context = live keymaps + assembled cheatsheets

For `:ResearchLocal`, the prompt prepends:
- **Live keymap descriptions** via `vim.api.nvim_get_keymap()` for the relevant modes — every keymap in this config sets a `desc`, so this is an always-current command reference (a newly added/edited binding is reflected with no doc update).
- **Assembled cheatsheet content** (the same `core.md` + filetype sheet material `cheatsheet.lua` already assembles) for prose/workflow context.

**Alternatives considered:**
- *Feed `docs/**/*.adoc`*: larger and prose-heavy; start without it and add if answers feel thin.
- *Let `claude` read the repo agentically*: accurate but slow and unpredictable for a popup (this is path "D" from exploration). Discarded.

### 5. The local prompt is constrained to its context

The `:ResearchLocal` prompt explicitly instructs: *answer using only the provided context about this Neovim configuration; if the answer is not present, say so rather than guessing.* This is what prevents the model from silently falling back to generic Neovim advice — the exact wrong-answer failure mode that motivated splitting the paths.

### 6. Single-shot, asynchronous `claude -p`

Same execution model as `claude_cli`: `vim.system({ "claude", "-p", prompt }, {}, cb)`, an INFO "running…" notification, result scheduled back onto the UI loop, error notified on non-zero exit. Not agentic — fast and predictable.

### 7. Keymaps under the `<leader>?` namespace

`<leader>?` already means "I have a question" (`?` = cheatsheet, `?g` = guides). The new keys extend it naturally: `?l` (local) and `?a` (ask/general). Both are currently unused.

## Risks / Trade-offs

- **CLI latency** (~seconds per call) → acceptable for a deliberate "research" action; the "running…" notification sets expectations. Mitigation: keep prompts compact.
- **Local context token cost** → keymaps + cheatsheets are small; well within limits. If the context grows (e.g. adding docs), trim or summarise.
- **dressing.nvim not loaded yet** (avante is `VeryLazy`) when `?l`/`?a` is pressed early → `vim.ui.input` degrades to a cmdline prompt. Acceptable; no hard dependency introduced.
- **Refactor of `claude_cli.lua`** → must be a *faithful* extraction (identical dimensions, border, `filetype=markdown`, `q`/`<Esc>` close). Mitigation: validate `:ClaudeExplain` renders identically after the move.
- **Model may still drift on the local path** despite the guard → mitigated by the explicit "answer only from context" instruction; worst case the user re-asks via `?a` or opens the cheatsheet.

## Open Questions

- **Web for the general path?** Should `:ResearchAsk` optionally consult web search for current information, or is model knowledge enough? Deferred — v1 is single-shot.
- **Include docs in local context?** Start with keymaps + cheatsheets; fold in `docs/**` only if local answers feel thin.
- **Single-line vs multi-line input?** Start with single-line `vim.ui.input`; revisit if longer questions feel cramped.
- **Follow-up from within the float?** Re-asking inside the result window edges toward chat — defer to avante; keep the popup one-shot.
