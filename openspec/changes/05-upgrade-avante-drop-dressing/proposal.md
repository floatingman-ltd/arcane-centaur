## Why

`lua/plugins/avante.nvim` is pinned to `version = "v0.0.27"` with a comment claiming newer releases lack Linux binaries. The best-of-breed evaluation establishes that comment is outdated: Linux x86_64/aarch64 prebuilt binaries (both lua51 and luajit) ship from v0.0.29 onward and the versioning has moved past v0.1.0. The pin is roughly 18 months stale.

The upgrade is coupled with one of its dependencies: `dressing.nvim` is declared in avante's dependency list, has been **archived** by its author (who now points to snacks.nvim), and — confirmed by cross-validation — is used by **nothing else in this config** (`grep` finds `dressing` only in `avante.lua`). So the dependency can be dropped as part of the same change.

Cross-validation of the other shared dependencies determined what must NOT be dropped:

- **`plenary.nvim`** is declared only by avante, but `diffview.nvim` depends on it transitively and declares no copy of its own. Dropping plenary during the avante edit would break diffview. → **keep plenary**.
- **`nui.nvim`** is avante-only here and still required by avante. → keep.
- **`nvim-web-devicons`** is shared (fzf-lua, nvim-tree, avante) and stays regardless. → keep.

## What Changes

- **Upgrade** `avante.nvim` from the stale `v0.0.27` pin to a current stable release (a pinned recent `v0.1.x`+ tag, consistent with this config's pin-for-stability convention), and update the `build` step to the recipe documented for that release (`make` or `:AvanteBuild`, verified against the chosen tag).
- **Remove** `stevearc/dressing.nvim` from avante's dependency list (archived; no other consumer).
- **Keep** `plenary.nvim` (diffview needs it), `nui.nvim`, and `nvim-web-devicons` in the dependency list.
- **Simplify to Ollama-only.** Keep the ollama default provider but reduce its model to the small `llama3.2:1b` (~1.3 GB) so it runs on limited-RAM machines. **Remove the `claude` provider and its `<leader>ac` keymap** — Anthropic's ToS scopes subscription OAuth tokens to Claude Code / claude.ai (so avante can't safely lean on a subscription), and requiring an `ANTHROPIC_API_KEY` adds an external account/billing dependency this config would rather avoid. Kept keymaps: `<leader>aa` / `<leader>ao`.
- **Update** the outdated pin/comment in `lua/plugins/avante.lua` (and document how to re-enable a claude provider via API key, the ToS-safe path).
- **vim.ui overlays**: after dropping dressing, `vim.ui.select`/`vim.ui.input` fall back to Neovim's native UI (acceptable on 0.12). Adopting snacks.nvim for richer `vim.ui` is explicitly deferred (out of scope).

## Capabilities

### New Capabilities

- `avante-runtime`: avante.nvim installed at a maintained release with prebuilt Linux binaries, built via the release's documented build step, with a dependency set of plenary + nui + nvim-web-devicons (dressing.nvim removed).

### Modified Capabilities

- `ai-research-ollama`: the default avante ollama model changes to the small **`llama3.2:1b`** (from the spec's `llama3.1:8b` / the prior config's `llama3.2:3b`) for limited-RAM machines, and ollama becomes avante's **only** provider.

### Removed Capabilities

- `ai-research-claude`: avante's `claude` provider and its `<leader>ac` keymap are removed — avante is Ollama-only. (This does **not** touch the `claude-cli-integration` / `research-popup` capabilities, which drive `:ClaudeSuggest`/`:ClaudeExplain`/the research popup through Claude Code's own CLI auth, not avante.)

## Impact

- **`lua/plugins/avante.lua`** → `version` bumped, `build` updated, `dressing.nvim` removed from `dependencies`, stale pin comment rewritten. `providers` reduced to `ollama` only (model `llama3.2:1b`); the `claude` provider block and `<leader>ac` keymap removed; `<leader>aa`/`<leader>ao` kept. A comment documents re-enabling claude via an API key.
- **`dressing.nvim`** → no longer installed after `:Lazy clean`.
- **`diffview.nvim`** → unaffected, because plenary is retained.
- **No `ANTHROPIC_API_KEY` dependency** — the claude provider is gone; the ollama endpoint (`http://127.0.0.1:11434`) is unchanged, its model is now `llama3.2:1b`.
- **Docs** → `ai-tools.adoc` (+cheatsheet), `getting-started.adoc`, `architecture.adoc`, `CLAUDE.md` updated to Ollama-only + the small-model pull.
- **Independence**: decoupled from the completion and editing changes (different files).

## Prerequisites and sequencing

**Sequence position:** 05 of 08 — Wave A (independent; precedes 08-add-claudecode-session).

- **Hard prerequisites:** none. Edits only `lua/plugins/avante.lua`; retains `plenary.nvim` (diffview depends on it).
- **Implementation wave: A** (independent; parallelizable with the other Wave A changes).
- **Downstream dependents:** `add-claudecode-session` derives its "native terminal provider / no snacks dependency" requirement from this change's decision to defer snacks (see Out of scope). It is *recommended* to implement `add-claudecode-session` after this change so the shared "snacks deferred" rationale is already in place. If that deferral is ever reversed, `add-claudecode-session`'s provider choice must be revisited. No file conflict (different files).

## Out of scope

- Adopting `snacks.nvim` for `vim.ui.select`/`vim.ui.input` — a separate optional change; native vim.ui is acceptable here.
- The claude-CLI research features (`claude-cli-integration`, `research-popup`) — unchanged; only avante's in-panel claude provider is removed.
- Re-adding a claude provider via `ANTHROPIC_API_KEY` — documented as an opt-in in `avante.lua` / `ai-tools.adoc`, but not enabled by default.
