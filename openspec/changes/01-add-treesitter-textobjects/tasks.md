## 1. Branch reconciliation + parser

- [x] 1.1 In `lua/plugins/treesitter.lua`, add `branch = "master"` to the `nvim-treesitter` spec.
- [x] 1.2 Add `nvim-treesitter/nvim-treesitter-textobjects` (also `branch = "master"`) to the spec's `dependencies`.
- [x] 1.3 Add `"haskell"` to `ensure_installed` (leave `fsharp`/`c_sharp` — already present).

## 2. Configure text objects (gated)

- [x] 2.1 Add a `textobjects.select` block with `af`/`if`, `ac`/`ic`, `aa`/`ia` keymaps, `lookahead = true`, and a `disable` function returning true for lisp/clojure/scheme/fennel/janet.
- [x] 2.2 Add a `textobjects.move` block with `]f`/`[f`/`]F`/`[F` (function start/end), `set_jumps = true`, and the same `disable` gate. Do NOT map `]c`/`[c` (class) — diff-mode collision.

## 3. Validation

- [ ] 3.1 `:Lazy sync`; `:TSUpdate` — confirm the `haskell` parser installs and textobjects loads without error.
- [ ] 3.2 Confirm Treesitter highlighting is active in Lua, F#, C#, and Haskell buffers (it was a no-op on the `main` branch before).
- [ ] 3.3 In an F#/Haskell/C#/Lua buffer: `vaf` selects a function, `vif` its body, `via` an argument, `daf` deletes a function, `]f`/`[f` jump between functions.
- [ ] 3.4 In a `.clj`/`.lisp`/`.janet` buffer: `vaf` still selects an s-expression form (vim-sexp), confirming textobjects is disabled there.
- [ ] 3.5 Confirm vim-unimpaired bracket maps and gitsigns `]h`/`[h` are unaffected.
- [x] 3.6 `find . -name '*.lua' -print0 | xargs -0 luac -p`.

## 4. Documentation

- [x] 4.1 Update `docs/modules/ROOT/pages/editor/navigation.adoc` (and/or `editor/editing.adoc`) with the select objects (`af`/`if`/`ac`/`ic`/`aa`/`ia`) and move motions (`]f`/`[f`/`]F`/`[F`), noting they apply to F#/Haskell/C#/Lua and that Lisp uses vim-sexp.
- [x] 4.2 Add the text-object maps to the relevant editor cheatsheet.
- [x] 4.3 Update `docs/modules/ROOT/pages/other/architecture.adoc` if it describes the treesitter setup (note the `master` pin + textobjects module).
