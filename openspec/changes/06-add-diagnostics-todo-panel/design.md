## Context

Diagnostics today (all in `lua/config/lsp.lua`'s `on_attach`):

- `<leader>e` → `vim.diagnostic.open_float` (line diagnostics popup).
- `[d` / `]d` → `vim.diagnostic.jump({ count = ∓1 })`.

`fzf-lua` is installed with `opts = {}`; it provides a diagnostics picker (`:FzfLua diagnostics_document` / `diagnostics_workspace`) but none is currently mapped. There is no persistent diagnostics split and no TODO highlighting.

Keymap namespace (from `lua/keymaps.lua`): `<leader>x` is **unused**. `<leader>d` is `"+d` (clipboard cut). vim-unimpaired (KEEP) owns `]t`/`[t` (`:tnext`/`:tprev`), among many other bracket maps.

`nvim-treesitter` is on the `main` branch; todo-comments does not use the treesitter module API (it works via regex / `vim.regex` over comments, optionally consuming the `comment` parser), so the branch state is irrelevant to it.

## Goals / Non-Goals

**Goals**
- A persistent, filterable diagnostics/quickfix/loclist/refs/symbols panel.
- Project-wide TODO/FIXME/etc. highlighting + listing.
- Integration with the existing fzf-lua picker and (optionally) trouble.
- Zero disruption to native diagnostics navigation and to vim-unimpaired.

**Non-Goals**
- Replacing `[d`/`]d`, `<leader>e`, or the global quickfix list.
- Bracket-jump maps for todos.
- A bespoke trouble layout beyond the standard modes.

## Decisions

### trouble.nvim under `<leader>x` (`lua/plugins/trouble.lua`)
Use trouble's documented `<leader>x` prefix — free here, so no remap needed:

```lua
return {
  "folke/trouble.nvim",
  version = "*",                 -- pin to stable v3
  cmd = "Trouble",
  keys = {
    { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",                        desc = "Trouble: diagnostics (project)" },
    { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",           desc = "Trouble: diagnostics (buffer)" },
    { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>",                desc = "Trouble: symbols" },
    { "<leader>xr", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "Trouble: LSP references/defs" },
    { "<leader>xl", "<cmd>Trouble loclist toggle<cr>",                            desc = "Trouble: location list" },
    { "<leader>xq", "<cmd>Trouble qflist toggle<cr>",                             desc = "Trouble: quickfix list" },
  },
  opts = {},                     -- v3 defaults are sensible; no quickfix takeover
}
```

`[d`/`]d` and `<leader>e` are **left in place** — trouble is the panel, the native maps are the motions. They are complementary (a persistent split vs. jump-to-next vs. a fuzzy modal). The `version = "*"` pin matches the config's pin-for-stability convention (haskell-tools `^6`, blink `1.*`).

*Alternative considered*: mapping `[d`/`]d` to `require("trouble").next()/prev()`. Rejected — it couples basic diagnostic navigation to trouble being loaded and changes long-standing muscle memory for no gain.

### todo-comments.nvim, list-driven, no bracket jumps (`lua/plugins/todo-comments.lua`)
```lua
return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },  -- still required by current releases; already present
  event = { "BufReadPost", "BufNewFile" },
  opts = {},                                   -- default keyword set + signs
  keys = {
    { "<leader>xt", "<cmd>TodoTrouble<cr>",  desc = "Todo: list (Trouble)" },
    { "<leader>xT", "<cmd>TodoFzfLua<cr>",   desc = "Todo: list (fzf-lua)" },
  },
}
```

**No `]t`/`[t`.** todo-comments' README suggests `]t`/`[t` for jumping between todos, but those are vim-unimpaired's tag maps (KEEP). Mapping them would shadow `:tnext`/`:tprev`. Todos are reached through the `<leader>xt`/`<leader>xT` lists instead. If the user later wants bracket jumps, a non-conflicting pair (e.g. `]o`/`[o` only if confirmed unused by unimpaired) can be added in a follow-up — out of scope here.

`:TodoFzfLua` requires fzf-lua (present); `:TodoTrouble` requires trouble (added in the same change), so both list commands resolve. Highlighting and signs work without either.

*Alternative considered*: `]t`/`[t` jumps as upstream suggests. Rejected — direct clash with the retained vim-unimpaired.

### which-key group
Add `{ "<leader>x", group = "Trouble" }` to `lua/plugins/which-key.lua`'s `wk.add`. todo's `<leader>xt`/`<leader>xT` nest under it naturally.

## Risks / Trade-offs

- **`]t`/`[t` clash (designed around).** Resolved by not mapping them; documented so a future contributor does not re-introduce the clash.
- **todo-comments plenary dependency.** Current releases still need plenary; it is present (retained by the avante change). If a future todo-comments release drops it, the explicit dep is harmless. Low risk.
- **trouble v3 API stability.** v3 is stable; the command strings above are the documented v3 form. Verify the exact `Trouble lsp`/`symbols` argument syntax against the installed version.
- **Overlap with fzf-lua diagnostics.** Intentional and complementary (persistent split vs. fuzzy modal). No conflict — fzf-lua has no diagnostics map today, so nothing is shadowed.
- **Independence.** No shared files with the other four changes; `lsp.lua` untouched.

## Validation outline
1. Add `trouble.lua` + `todo-comments.lua`; register the which-key group. `:Lazy sync`.
2. In a file with LSP diagnostics: `<leader>xx` opens the project diagnostics panel; `<leader>xX` the buffer-only view; navigating an entry jumps to the location.
3. Confirm `[d`/`]d` and `<leader>e` still behave exactly as before.
4. Add a `-- TODO:` and `-- FIXME:` comment: confirm they are highlighted with signs.
5. `<leader>xT` (`:TodoFzfLua`) lists todos via fzf-lua; `<leader>xt` (`:TodoTrouble`) lists them in trouble.
6. Confirm vim-unimpaired `]t`/`[t` still do tag navigation (unchanged).
7. `find . -name '*.lua' -print0 | xargs -0 luac -p`.
