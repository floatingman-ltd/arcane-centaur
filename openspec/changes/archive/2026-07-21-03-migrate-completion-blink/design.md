## Context

`lua/plugins/nvim-cmp.lua` configures a vanilla nvim-cmp stack:

- Sources (insert mode): `nvim_lsp`, `luasnip`, `buffer`, `path`, `spell` (the last gated to `vim.opt.spell:get()` and `keyword_length = 3`).
- Sources (cmdline): `/` → `buffer`; `:` → `path` then `cmdline`.
- Snippet expansion via `require("luasnip").lsp_expand`.
- Keymaps: `<C-b>`/`<C-f>` scroll docs, `<M-Space>` complete, `<C-e>` abort, `<CR>` confirm with `select = false`, `<C-n>`/`<C-p>` next/prev.
- A sixth source, `conjure`, is contributed by `cmp-conjure`, declared as a Conjure dependency in `lua/plugins/lisp.lua` (loads only on `lisp/clojure/scheme/fennel/janet`).

Two integration facts discovered during cross-validation:

- **LuaSnip is not installed** (`lazy-lock.json` has `cmp_luasnip` but no `L3MON4D3/LuaSnip`). The `luasnip` source and `lsp_expand` shim are inert — snippet expansion cannot actually run today.
- **`lua/config/lsp.lua` never advertises completion capabilities.** It builds `vim.lsp.protocol.make_client_capabilities()` + `foldingRange` only. No `cmp_nvim_lsp.default_capabilities()` call exists, so removing nvim-cmp breaks nothing in `lsp.lua` — and adding blink's capabilities is a net gain.

## Goals / Non-Goals

**Goals**
- Drop-in replacement preserving every current keybinding and source behavior (LSP, buffer, path, cmdline, prose-spell, Conjure).
- Reduce the plugin count and remove dead LuaSnip config.
- Advertise completion capabilities to LSP servers (new, correct behavior).
- Pin to blink.cmp v1 for stability.

**Non-Goals**
- Adding a real snippet library (none exists today; not introducing one here).
- Changing completion *triggering* philosophy (still manual-friendly, no auto-select on `<CR>`).
- Migrating to blink.cmp v2 or Neovim native `autocomplete`.

## Decisions

### New file `lua/plugins/blink.lua`, delete `lua/plugins/nvim-cmp.lua`
A clean replacement file is clearer in git history than rewriting the old one in place, and matches the one-file-per-plugin-group convention. lazy.nvim auto-imports it.

### Pin blink.cmp to v1
`version = "1.*"` (or the latest v1 tag). v2 is under active development with breaking changes. Pinning v1 mirrors the evaluation's recommendation and the `version`-pin convention already used for haskell-tools (`^6`).

### Source set and the two compat bridges
blink provides `lsp`, `buffer`, `path`, `snippets` natively. The two sources with no native blink equivalent are bridged through `blink.compat`:

```
default sources:  lsp, buffer, path, snippets        (built-in)
                  spell                               (blink.compat → cmp-spell)
lisp filetypes:   + conjure                           (blink.compat → cmp-conjure)
```

- **`cmp-spell`** moves from `nvim-cmp.lua`'s dependency list to the blink spec's dependency list. Its prose-only behavior is reproduced with a per-source gate: only enable the `spell` provider when `vim.opt.spell:get()` is true (blink.compat passes through the source's `enabled`/`should_show_items` hooks). Keep `keyword_length`/min-length semantics so it does not fire on 1–2 char tokens.
- **`cmp-conjure`** stays declared in `lua/plugins/lisp.lua` (so it still loads on lisp filetypes alongside Conjure). The blink spec declares a `conjure` provider via `blink.compat`. blink.compat resolves the registered cmp source lazily, so the load-order (blink early, conjure on ft) is fine — **but this is the highest-risk item and must be verified in a real `.clj`/`.lisp`/`.janet` buffer** (see tasks).

*Alternative considered*: drop `cmp-conjure` and rely on Conjure's omnifunc (`<C-x><C-o>`). Rejected — it loses popup autocompletion of REPL symbols, a core REPL-driven-development affordance for this config.

### Keymap preset — reproduce current ergonomics
Use a custom keymap table rather than a stock preset, to match muscle memory exactly:

```lua
keymap = {
  preset = "none",
  ["<C-b>"]     = { "scroll_documentation_up", "fallback" },
  ["<C-f>"]     = { "scroll_documentation_down", "fallback" },
  ["<M-Space>"] = { "show", "fallback" },
  ["<C-e>"]     = { "hide", "fallback" },
  ["<CR>"]      = { "accept", "fallback" },
  ["<C-n>"]     = { "select_next", "fallback" },
  ["<C-p>"]     = { "select_prev", "fallback" },
},
completion = {
  list = { selection = { preselect = false, auto_insert = false } },
},
```

`preselect = false` reproduces nvim-cmp's `confirm({ select = false })` — nothing is highlighted until the user navigates, so `<CR>` never inserts an unintended first suggestion. `<CR> = accept` with `fallback` keeps newline behavior when the menu is closed.

### Cmdline completion
blink supports cmdline natively. Configure per-type to match current behavior:

```lua
cmdline = {
  enabled = true,
  sources = function()
    local t = vim.fn.getcmdtype()
    if t == "/" or t == "?" then return { "buffer" } end
    if t == ":" then return { "path", "cmdline" } end
    return {}
  end,
},
```

This mirrors `/` → buffer words and `:` → paths + Ex commands.

### LSP capabilities (the third file)
In `lua/config/lsp.lua`, merge blink's capabilities into the existing table:

```lua
local capabilities = require("blink.cmp").get_lsp_capabilities({
  textDocument = { foldingRange = { dynamicRegistration = false, lineFoldingOnly = true } },
})
```

This preserves the nvim-ufo folding capability while adding the completion capabilities the servers were never told about. blink.cmp must be available at the time `config.lsp` runs — it is loaded eagerly enough (blink typically loads early), but if a load-order error appears, guard with `pcall` and fall back to `make_client_capabilities()`.

### `completeopt` is left unchanged
`lua/options.lua` sets `completeopt = {menu, menuone, noselect}`. This governs Neovim's *native* completion, which blink does not use; it is harmless to leave and out of scope to touch.

## Risks / Trade-offs

- **Conjure bridge (highest risk).** If the `conjure` source does not surface in a lisp buffer, the most likely cause is the cmp source not being registered before blink.compat resolves it. Mitigation: verify in a live buffer; if needed, move `cmp-conjure` into the blink spec's dependencies or add an explicit `require("cmp_conjure")` on the conjure ft event. Documented as an explicit verification task.
- **Spell bridge.** blink.compat's gating of cmp-spell may differ subtly from nvim-cmp's `enable_in_context`. Mitigation: verify spell suggestions appear in a `spell`-enabled markdown buffer and are absent in a code buffer.
- **Capabilities change behavior.** Advertising completion capabilities can make servers return richer (e.g. snippet-flavored) items. This is desired, but watch for servers that now return snippet text needing expansion — blink's snippet engine handles standard LSP snippets.
- **No rollback coupling.** This change is independent of the statusline/surround/avante changes; it can be merged or reverted on its own.

## Migration / Validation outline
1. Add `lua/plugins/blink.lua`; delete `lua/plugins/nvim-cmp.lua`.
2. `:Lazy sync` — confirm blink.cmp builds its matcher (prebuilt binary or `cargo build`; the v1 release ships prebuilt binaries) and the six cmp-core plugins are removed.
3. Confirm LSP, buffer, path completion in a Lua/F# buffer; cmdline completion on `:`/`/`.
4. Confirm Conjure completion in a `.clj`/`.lisp`/`.janet` buffer.
5. Confirm prose-spell completion in markdown (spell on) and its absence in code.
6. `luac -p` syntax check across the repo.
