## Why

The completion stack is a full vanilla nvim-cmp setup: `nvim-cmp` plus six source plugins (`cmp-nvim-lsp`, `cmp-buffer`, `cmp-path`, `cmp-cmdline`, `cmp_luasnip`, `cmp-spell`) and a seventh source bridged through Conjure (`cmp-conjure`). The best-of-breed evaluation flags this as the single largest quality-of-life gain available: [blink.cmp](https://github.com/saghen/blink.cmp) updates on every keystroke with sub-millisecond overhead (vs. nvim-cmp's debounced 2–50 ms hitches), bundles LSP/buffer/path/snippet sources natively, and ships a Rust fuzzy matcher that tolerates typos.

Cross-validation of the *actual* config surfaced three facts the evaluation glossed over, and they shape this change:

1. **`L3MON4D3/LuaSnip` is not installed.** `lua/plugins/nvim-cmp.lua` calls `require("luasnip")` and registers a `luasnip` source, and `cmp_luasnip` is locked — but LuaSnip itself is absent from `lazy-lock.json`. Snippet expansion is dead config today. blink.cmp's built-in snippet engine replaces it cleanly; no `snippets.preset = "luasnip"` is needed.
2. **The migration touches three files, not one.** `cmp-conjure` lives in `lua/plugins/lisp.lua`; `lua/config/lsp.lua` currently builds capabilities from `make_client_capabilities()` and never advertises completion capabilities at all.
3. **`cmp-spell` is context-gated** to `vim.opt.spell:get()` (prose buffers only). blink has no native spell source, so this behavior must be preserved deliberately.

## What Changes

- **Replace** `nvim-cmp` and five source plugins (`cmp-nvim-lsp`, `cmp-buffer`, `cmp-path`, `cmp-cmdline`, `cmp_luasnip`) with `saghen/blink.cmp` (pinned to the stable v1 line) and `saghen/blink.compat`.
- **Retain** `cmp-conjure` and `cmp-spell` as installed plugins, bridged into blink.cmp via `blink.compat` (no native blink source exists for either).
- **Drop** the LuaSnip source and snippet-expand shim — LuaSnip was never installed, so blink's built-in snippet engine is a strict improvement.
- **Preserve completion ergonomics exactly**: `<CR>` confirms without auto-selecting the first item, `<C-n>`/`<C-p>` navigate, `<C-e>` aborts, `<M-Space>` triggers, `<C-b>`/`<C-f>` scroll docs.
- **Preserve cmdline completion**: `/` completes from buffer words; `:` completes paths and Ex commands.
- **Wire completion capabilities into LSP** (`lua/config/lsp.lua`) via `require("blink.cmp").get_lsp_capabilities()`, merged with the existing `foldingRange` capability — net improvement over the current setup, which advertises none.

## Capabilities

### New Capabilities

- `completion-engine`: insert-mode and cmdline completion powered by blink.cmp, with LSP / buffer / path / snippet sources built in, Conjure and spell sources bridged via blink.compat, and completion capabilities advertised to LSP servers.

### Modified Capabilities

<!-- none — completion was never captured as an OpenSpec requirement before this change -->

## Impact

- **`lua/plugins/nvim-cmp.lua`** → deleted; replaced by `lua/plugins/blink.lua` (new blink.cmp + blink.compat spec).
- **`lua/plugins/lisp.lua`** → `cmp-conjure` stays as a Conjure dependency (loads on lisp filetypes); no spec change required there, but the blink spec must declare the bridged `conjure` provider.
- **`lua/config/lsp.lua`** → `capabilities` extended with `require("blink.cmp").get_lsp_capabilities()`.
- **Net package count**: 6 removed, 2 added, 2 retained-as-bridged (`cmp-conjure`, `cmp-spell`). The evaluation's "8 → 2" assumed both bridges away; preserving Conjure and prose-spell completion makes the real figure 8 → 4.
- **No keymap changes** outside the completion menu itself; no global keymaps in `lua/keymaps.lua` touch completion.
- **Risk**: cmdline completion and the spell/Conjure bridges are the parts most likely to need tuning. See `design.md`.

## Prerequisites and sequencing

**Sequence position:** 03 of 08 — Wave A (independent; precedes 07-add-dotnet-debug-test).

- **Hard prerequisites:** none. Edits `lua/plugins/blink.lua` (new), `lua/plugins/nvim-cmp.lua` (delete), `lua/config/lsp.lua`, and references `lua/plugins/lisp.lua` — none of which any other change edits.
- **Implementation wave: A** (independent; parallelizable with the other Wave A changes: `modernize-editing-plugins`, `upgrade-avante-drop-dressing`, `enhance-asciidoc-authoring`, `add-treesitter-textobjects`).
- **Downstream dependents:** `add-dotnet-debug-test` is *recommended* to follow this change so its "exactly one Roslyn client, advertising blink capabilities" verification runs against the final `lua/config/lsp.lua` state. That change does **not** edit `lsp.lua`, so there is no file conflict and no hard ordering.

## Out of scope

- `cmp-spell` could be retired entirely in favour of native `z=` / `]s` spell tooling — deferred; this change preserves current behavior.
- blink.cmp v2 (in active development with breaking changes) — this change pins v1.
- Neovim 0.12's native `autocomplete` option — not mature enough to replace a dedicated engine yet.
