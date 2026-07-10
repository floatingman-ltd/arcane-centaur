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
- Preserve provider config, models, and keymaps exactly.
- Keep diffview working by retaining plenary.

**Non-Goals**
- Adding snacks.nvim or any vim.ui replacement.
- Changing providers/models/keymaps.
- Fixing the unrelated ollama model-name spec drift.

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

### Preserve provider opts and keymaps verbatim
The `providers.ollama` (endpoint `http://127.0.0.1:11434`, model `llama3.2:3b`) and `providers.claude` (`ANTHROPIC_API_KEY`, `claude-3-5-haiku-20241022`) blocks, plus `<leader>aa`/`<leader>ao`/`<leader>ac`, are carried over unchanged. The newer avante may have schema additions, but the existing keys remain valid; verify the opts validate cleanly on the new version.

## Risks / Trade-offs

- **API surface drift (highest risk).** `require("avante.api").ask()` and `switch_provider(...)` back the three keymaps. Newer avante could rename or relocate these. Mitigation: explicit verification task that each keymap opens avante / switches provider on the new version; adjust the `keys` callbacks if the API moved.
- **Build failure on the new tag.** If the documented build step differs, `:Lazy` may report a build error. Mitigation: read the release build docs first; run `:AvanteBuild`/`make` per the release.
- **opts schema rejection.** If a key was renamed, avante may warn at setup. Mitigation: validate against the chosen release's config docs.
- **vim.ui regression.** If native `vim.ui.select` feels worse for some flow, that is the deferred snacks.nvim decision — not a blocker for this change.
- **Independence.** Decoupled from completion and editing changes.

## Validation outline
1. Choose the target release tag; read its build docs.
2. Update `version`, `build`, remove dressing, rewrite the comment.
3. `:Lazy update` then run the documented build; `:Lazy clean` to remove dressing.
4. `<leader>ao` opens avante on ollama (if the service is up) and returns an answer or a clean error.
5. `<leader>ac` switches to the claude provider (with `ANTHROPIC_API_KEY`) and opens.
6. `<leader>aa` opens with the current provider.
7. `:DiffviewOpen` still works (plenary intact).
8. `:Lazy` shows dressing.nvim is gone; `luac -p` syntax check passes.
