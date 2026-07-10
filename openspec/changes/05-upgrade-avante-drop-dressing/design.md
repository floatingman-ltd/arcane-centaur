## Context

`lua/plugins/avante.lua` currently:

```lua
version = "v0.0.27",
build = "make",
dependencies = {
  "nvim-lua/plenary.nvim",
  "MunifTanjim/nui.nvim",
  "stevearc/dressing.nvim",
  "nvim-tree/nvim-web-devicons",
},
opts = { provider = "ollama", providers = { ollama = {...}, claude = {...} } },
keys = { <leader>aa, <leader>ao, <leader>ac },
```

The opts already use the newer `providers = {}` nesting (not the pre-v0.0.19 top-level schema), so the config is partly ahead of its own pin. The header comment warns against upgrading past v0.0.27 — that warning is the thing this change retires.

Cross-validation of the four declared dependencies:

| Dep | Other consumers in this config | Verdict |
|---|---|---|
| `plenary.nvim` | diffview.nvim (transitive; diffview declares none) | **keep** |
| `nui.nvim` | none (avante-only) | keep (avante needs it) |
| `dressing.nvim` | none (avante-only) — archived upstream | **remove** |
| `nvim-web-devicons` | fzf-lua, nvim-tree | keep |

## Goals / Non-Goals

**Goals**
- Move avante to a current, maintained release with working Linux binaries.
- Remove the archived dressing.nvim dependency cleanly.
- Make avante Ollama-only: small default model (`llama3.2:1b`) for limited-RAM machines, and remove the `claude` provider + `<leader>ac` (Anthropic subscription-OAuth is ToS-scoped to Claude Code/claude.ai; avoid an `ANTHROPIC_API_KEY` dependency too).
- Keep diffview working by retaining plenary.

**Non-Goals**
- Adding snacks.nvim or any vim.ui replacement.
- Re-enabling a claude provider by default (documented as an API-key opt-in only).
- Changing the separate claude-CLI research features (`claude-cli-integration`, `research-popup`).

## Decisions

### Pin to a recent stable tag, not `version = false`
The evaluation offers `version = false` (track latest) or a newer tag. This config pins for stability everywhere (haskell-tools `^6`, blink `1.*`). Pin avante to a recent stable `v0.1.x`+ tag so updates are intentional, not automatic — and because lazy's `checker.enabled = true` already surfaces available updates. The exact tag is chosen at implementation time from the releases page, preferring the latest with prebuilt Linux binaries.

### Verify and set the build recipe for the chosen tag
The build step changed across releases: older releases used `make`; newer releases install `.so` files to a Neovim-discoverable location and provide `:AvanteBuild`. The implementer SHALL read the chosen release's README/build docs and set `build` to whatever that release documents, then run the build once after `:Lazy update`. Do not assume `make` still works on the new tag.

### Remove dressing.nvim; accept native vim.ui
After removal, `vim.ui.select`/`vim.ui.input` revert to Neovim's native implementations, which on 0.12 are serviceable (the select menu and input prompt both work). avante's own UI (chat sidebar, diffs) is provided by nui.nvim, not dressing, so the chat experience is unaffected.

*Alternative considered*: replace dressing with `snacks.nvim`'s `vim.ui` module (the upstream-recommended successor). Rejected for *this* change — snacks is a large meta-plugin and pulling it in for one module is a separate decision with its own footprint. Deferred to a future optional change; noted in the proposal's Out of scope.

### Keep plenary explicitly in avante's dependency list
Even though diffview is the transitive beneficiary, plenary's only *declared* home is avante. Leaving it in avante's `dependencies` keeps diffview working without adding a redundant declaration to `git.lua`. (A more robust future cleanup would declare plenary where diffview lives, but that is out of scope.)

### Ollama-only: small model, claude provider removed
`providers` is reduced to `ollama` alone, model **`llama3.2:1b`** (endpoint `http://127.0.0.1:11434`) — a ~1.3 GB model that runs on limited-RAM machines. The `claude` provider and `<leader>ac` are **removed**: avante's only in-panel route to Anthropic would be a subscription OAuth token (ToS-scoped to Claude Code / claude.ai, so using it from avante risks a violation) or an `ANTHROPIC_API_KEY` (an external account/billing dependency this config avoids). `<leader>aa`/`<leader>ao` are kept. A comment in `avante.lua` documents re-adding a `claude` provider with `auth_type = "api"` + `api_key_name = "ANTHROPIC_API_KEY"` for anyone who wants the API-key path.

This affects **only** avante's in-panel provider. The CLI-based Claude features — `:ClaudeSuggest`/`:ClaudeExplain` (`<leader>gcs`/`<leader>gce`) and the research popup (`<leader>?l`/`<leader>?a`) — shell out to the `claude` binary using Claude Code's own auth (the sanctioned path) and are untouched (see `claude-cli-integration`).

*Alternative considered*: keep the claude provider on subscription OAuth (`auth_type = "max"`). Rejected — the ToS scoping makes third-party in-panel use risky, and the CLI features already cover Anthropic-backed help.

## Risks / Trade-offs

- **API surface drift (highest risk).** `require("avante.api").ask()` and `switch_provider(...)` back the three keymaps. Newer avante could rename or relocate these. Mitigation: explicit verification task that each keymap opens avante / switches provider on the new version; adjust the `keys` callbacks if the API moved.
- **Build failure on the new tag.** If the documented build step differs, `:Lazy` may report a build error. Mitigation: read the release build docs first; run `:AvanteBuild`/`make` per the release.
- **opts schema rejection.** If a key was renamed, avante may warn at setup. Mitigation: validate against the chosen release's config docs.
- **vim.ui regression.** If native `vim.ui.select` feels worse for some flow, that is the deferred snacks.nvim decision — not a blocker for this change.
- **Independence.** Decoupled from completion and editing changes.

## Validation outline
1. Choose the target release tag; read its build docs.
2. Update `version`, `build`, remove dressing, set the ollama model to `llama3.2:1b`, remove the claude provider + `<leader>ac`, rewrite the comment.
3. `:Lazy update` then run the documented build; `:Lazy clean` to remove dressing. **Restart Neovim** (a v0.0→v0.1 in-place update leaves stale Lua modules — see TEST_PLAN §5).
4. `<leader>ao` opens avante on ollama (with `llama3.2:1b` pulled and the service up) and returns an answer or a clean error.
5. `<leader>ac` is unmapped (claude provider removed); `<leader>aa` opens with the current provider (ollama).
6. `:DiffviewOpen` still works (plenary intact).
7. Native `vim.ui.select`/`vim.ui.input` still function (dressing gone).
8. `:Lazy` shows dressing.nvim is gone; `luac -p` syntax check passes.
9. The CLI Claude features (`<leader>gcs`/`<leader>gce`, `<leader>?l`/`<leader>?a`) still work — unaffected by removing avante's claude provider.
