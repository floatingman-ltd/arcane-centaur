## Context

`lua/plugins/treesitter.lua`:

```lua
return {
  { "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "lisp","clojure","scheme","lua","fsharp","vim",
                           "markdown","markdown_inline","plantuml","http","c_sharp" },
      highlight = { enable = true },
      indent = { enable = true },
    } },
}
```

No `branch` is declared, so lazy resolves the repo default — currently **`main`** (confirmed: the installed checkout is on a `main` commit). But `opts` here is the **`master`** API. On `main`, `setup()` does not consume `ensure_installed`/`highlight`/`indent`; highlighting is instead started per-buffer via `vim.treesitter.start()`. So today's config is internally inconsistent, and likely not actually running treesitter highlighting.

Other relevant state:
- `ensure_installed` already includes `fsharp` and `c_sharp`; `haskell` is absent.
- `guns/vim-sexp` (lisp/clojure/scheme/janet) provides `af`/`if`/`aF`/`iF` form text objects.
- vim-unimpaired (KEEP) uses many bracket maps but **not** `]f`/`[f`/`]F`/`[F`. `]c`/`[c` are Vim's built-in diff-mode change motions.

## Goals / Non-Goals

**Goals**
- Function/class/argument select objects and function move motions for F#/Haskell/C#/Lua.
- A branch-consistent treesitter setup (the running API matches the written API).
- Preserve vim-sexp's structural editing in Lisp-family buffers.
- Smallest, lowest-risk diff.

**Non-Goals**
- Migrating to the nvim-treesitter `main` API.
- Swap objects, extra parsers, or class motions.
- Any textobjects in Lisp-family buffers.

## Decisions

### Consolidate on `master` (not `main`)
Pin both plugins to `master`:

```lua
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects", branch = "master" },
    },
    opts = { ... },   -- existing master-style opts, now actually consumed
  },
}
```

**Why master over main, for *this* change**: the config is already written in the master API; pinning master makes it self-consistent in a one-line diff and turns `highlight = { enable = true }` from a no-op into working highlighting. The legacy textobjects module (`configs.setup({ textobjects = ... })`) lives on master and is the simplest integration. Migrating the whole setup to the `main` API (per-buffer `vim.treesitter.start`, new install + textobjects APIs) is a larger, riskier rewrite that deserves its own proposal — explicitly out of scope here.

*Alternative considered*: adopt the `main` API now (textobjects' `main` branch + `require("nvim-treesitter-textobjects").setup` + manual select/move wiring + a `FileType` autocmd calling `vim.treesitter.start`). Rejected for this change — it balloons a "add textobjects" change into a full treesitter-runtime rewrite. Recorded as the deferred future path.

### Add `haskell`; keep the rest
`ensure_installed` gains `"haskell"`. `fsharp` and `c_sharp` are already present (the evaluation's claim that fsharp was missing is incorrect). `:TSUpdate` installs the new parser.

### Select + move objects, gated away from Lisp
Add to the `opts` table:

```lua
local lisp_family = { lisp = true, clojure = true, scheme = true, fennel = true, janet = true }
local function not_lisp(_, buf)
  return lisp_family[vim.bo[buf].filetype] == true   -- disable() returns true to disable
end

textobjects = {
  select = {
    enable = true,
    lookahead = true,
    keymaps = {
      ["af"] = "@function.outer",  ["if"] = "@function.inner",
      ["ac"] = "@class.outer",     ["ic"] = "@class.inner",
      ["aa"] = "@parameter.outer", ["ia"] = "@parameter.inner",
    },
    disable = not_lisp,
  },
  move = {
    enable = true,
    set_jumps = true,
    goto_next_start     = { ["]f"] = "@function.outer" },
    goto_previous_start = { ["[f"] = "@function.outer" },
    goto_next_end       = { ["]F"] = "@function.outer" },
    goto_previous_end   = { ["[F"] = "@function.outer" },
    disable = not_lisp,
  },
}
```

- `af`/`if` etc. are operator/visual-mode objects (`daf`, `vif`, `cia`) — they do not occupy normal-mode keys and never collide with vim-unimpaired's bracket maps.
- `disable = not_lisp` keeps textobjects off lisp/clojure/scheme/fennel/janet, so **vim-sexp keeps `af`/`if`/`aF`/`iF`** there. This is the explicit reason textobjects is gated rather than global.
- Move uses `]f`/`[f`/`]F`/`[F` only (all free). **Class motion `]c`/`[c` is intentionally omitted** — it shadows Vim's diff-mode change navigation (relevant with diffview).

## Risks / Trade-offs

- **Branch re-pin behavior change (highest "risk", likely a win).** Moving to `master` makes highlight/indent actually run. If the user's terminal was relying on regex syntax that looked fine, TS highlight will now apply. Mitigation: verify highlighting in Lua/F#/C#/Haskell buffers before and after; this is desired behavior, not a regression.
- **vim-sexp clash if gating is wrong.** If `disable` is mis-implemented (e.g. returns false for lisp), `af`/`if` would shadow vim-sexp in lisp buffers. Mitigation: explicit verification that `vaf` in a `.clj` buffer still selects an s-expression (vim-sexp), and in a `.fs`/`.hs` buffer selects a function (textobjects).
- **`:TSUpdate` for the haskell parser.** Requires a compiler toolchain; usually fine. Mitigation: run `:TSUpdate` and confirm `haskell` installs.
- **master is in maintenance.** Accepted trade-off for this change; the `main` migration is the documented future path.
- **Independence.** Only this change edits `treesitter.lua`; no other best-of-breed change touches it.

## Validation outline
1. Add `branch = "master"`, the textobjects dependency, `haskell`, and the `textobjects` opts block. `:Lazy sync`; `:TSUpdate`.
2. Confirm treesitter highlighting is active in a Lua, F#, C#, and Haskell buffer.
3. In an F#/Haskell/C#/Lua buffer: `vaf` selects a whole function, `vif` its body, `via` an argument; `daf` deletes a function; `]f`/`[f` jump between functions.
4. In a `.clj`/`.lisp`/`.janet` buffer: `vaf` still selects an s-expression form (vim-sexp), confirming textobjects is disabled there.
5. Confirm vim-unimpaired bracket maps and gitsigns `]h`/`[h` are unaffected.
6. `find . -name '*.lua' -print0 | xargs -0 luac -p`.
