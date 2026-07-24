## 1. Repin plugins to `main`

- [x] 1.1 In `lua/plugins/treesitter.lua`, change `nvim-treesitter` to `branch = "main"`.
- [x] 1.2 Add `nvim-treesitter/nvim-treesitter-textobjects` on `branch = "main"` as a dependency.
- [x] 1.3 `:Lazy sync` and confirm both check out the `main` branch with no load errors in `:messages`.
- [x] 1.4 Update `lazy-lock.json` so both plugins record `branch: "main"` at pinned commits.

## 2. Parser installation (main API)

- [x] 2.1 Configure `main`'s install list / call install for: `commonlisp`, `clojure`, `scheme`, `lua`, `fsharp`, `c_sharp`, `vim`, `markdown`, `markdown_inline`, `http`, `haskell`.
- [x] 2.2 Confirm a C compiler is present and the parsers compile (`:TSInstall` / `:checkhealth nvim-treesitter`).

## 3. Highlight + indent (core APIs)

- [x] 3.1 Add a `FileType` autocmd (or ftplugin wiring) calling `vim.treesitter.start()` for the supported filetypes.
- [x] 3.2 Set `indentexpr` via `v:lua.require'nvim-treesitter'.indentexpr()` where indent is wanted.
- [x] 3.3 Test whether markdown still triggers the nil-range error on `main`; keep the `disable`/`after/ftplugin/markdown.lua` `vim.treesitter.stop()` only if still needed, otherwise remove it. (Tested with a fenced-code-block buffer via manual `vim.treesitter.start()` — no crash. Workaround removed; `after/ftplugin/markdown.lua` now calls `start()` + sets `indentexpr`.)

## 4. Text objects (textobjects `main`)

- [x] 4.1 Call `require('nvim-treesitter-textobjects').setup{}` with select/move config.
- [x] 4.2 Map select objects `af`/`if`, `ac`/`ic`, `aa`/`ia` (operator + visual) via the select API; gate off Lisp filetypes.
- [x] 4.3 Map motions `]f`/`[f`/`]F`/`[F` (add to jumplist) via the move API; gate off Lisp; do NOT map `]c`/`[c`.

## 5. Validation (Neovim 0.12)

- [x] 5.1 Highlight: `vim.treesitter.highlighter.active[bufnr]` non-nil in lua/fsharp/c_sharp/haskell buffers.
- [x] 5.2 Select: `vaf` selects a whole function (verified single-line C# expression body and multi-line `Main`), `dif`/`daf` delete inner/outer correctly — no `tsrange`/removed-API error.
- [x] 5.3 Motions: `]f`/`[f` jump between functions (Lua `M.greet`→`M.farewell`) and populate the jumplist (`<C-o>` returns to the prior function).
- [x] 5.4 Lisp: `af` in a `.clj` buffer resolves to vim-sexp's `<Plug>(sexp_outer_list)`, confirming treesitter text objects are not attached there.
- [x] 5.5 No collisions: gitsigns `]h` ("Next hunk"), unimpaired `]b` (`:bnext`), and `]c` (unmapped — builtin diff-mode) all verified via `maparg()`.
- [x] 5.6 `find . -name '*.lua' -print0 | xargs -0 luac -p` passes; `:messages` clean on startup.

## 6. Documentation

- [x] 6.1 Re-add the text-objects section to `docs/modules/ROOT/pages/editor/navigation.adoc` (main-branch note).
- [x] 6.2 Re-add the text-object rows to the editor cheatsheet (`editor/keybindings.adoc`).
- [x] 6.3 Update `docs/modules/ROOT/pages/other/architecture.adoc` treesitter entries (pin `main`; core-API highlight; textobjects restored).
- [x] 6.4 Note in the treesitter/editor guide that the config now tracks nvim-treesitter `main` and requires Neovim ≥ 0.11.
