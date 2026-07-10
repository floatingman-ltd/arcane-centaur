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
- **Preserve** provider behavior and keymaps: ollama default, claude API provider, `<leader>aa` / `<leader>ao` / `<leader>ac`.
- **Update** the outdated pin/comment in `lua/plugins/avante.lua`.
- **vim.ui overlays**: after dropping dressing, `vim.ui.select`/`vim.ui.input` fall back to Neovim's native UI (acceptable on 0.12). Adopting snacks.nvim for richer `vim.ui` is explicitly deferred (out of scope).

## Capabilities

### New Capabilities

- `avante-runtime`: avante.nvim installed at a maintained release with prebuilt Linux binaries, built via the release's documented build step, with a dependency set of plenary + nui + nvim-web-devicons (dressing.nvim removed).

### Modified Capabilities

<!-- none — the ai-research-claude and ai-research-ollama provider requirements describe behavior that this change preserves verbatim; their scenarios must still pass (verification task) but their text is unchanged -->

## Impact

- **`lua/plugins/avante.lua`** → `version` bumped, `build` updated, `dressing.nvim` removed from `dependencies`, stale pin comment rewritten. Provider `opts` (already using the newer `providers = {}` schema) and the three keymaps preserved.
- **`dressing.nvim`** → no longer installed after `:Lazy clean`.
- **`diffview.nvim`** → unaffected, because plenary is retained.
- **Dependency on `ANTHROPIC_API_KEY`** (claude provider) and the ollama endpoint (`http://127.0.0.1:11434`) are unchanged.
- **Independence**: decoupled from the completion and editing changes (different files).

## Prerequisites and sequencing

**Sequence position:** 05 of 08 — Wave A (independent; precedes 08-add-claudecode-session).

- **Hard prerequisites:** none. Edits only `lua/plugins/avante.lua`; retains `plenary.nvim` (diffview depends on it).
- **Implementation wave: A** (independent; parallelizable with the other Wave A changes).
- **Downstream dependents:** `add-claudecode-session` derives its "native terminal provider / no snacks dependency" requirement from this change's decision to defer snacks (see Out of scope). It is *recommended* to implement `add-claudecode-session` after this change so the shared "snacks deferred" rationale is already in place. If that deferral is ever reversed, `add-claudecode-session`'s provider choice must be revisited. No file conflict (different files).

## Out of scope

- Adopting `snacks.nvim` for `vim.ui.select`/`vim.ui.input` — a separate optional change; native vim.ui is acceptable here.
- Changing avante providers, models, or keymaps (covered by `ai-research-claude` / `ai-research-ollama`, preserved).
- Reconciling the pre-existing drift where `ai-research-ollama` spec says `llama3.1:8b` but `avante.lua` uses `llama3.2:3b` — pre-existing, not introduced here.
