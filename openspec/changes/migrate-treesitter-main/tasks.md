## 1. Repin plugins to `main`

- [ ] 1.1 In `lua/plugins/treesitter.lua`, change `nvim-treesitter` to `branch = "main"`.
- [ ] 1.2 Add `nvim-treesitter/nvim-treesitter-textobjects` on `branch = "main"` as a dependency.
- [ ] 1.3 `:Lazy sync` and confirm both check out the `main` branch with no load errors in `:messages`.
- [ ] 1.4 Update `lazy-lock.json` so both plugins record `branch: "main"` at pinned commits.

## 2. Parser installation (main API)

- [ ] 2.1 Configure `main`'s install list / call install for: `commonlisp`, `clojure`, `scheme`, `lua`, `fsharp`, `c_sharp`, `vim`, `markdown`, `markdown_inline`, `http`, `haskell`.
- [ ] 2.2 Confirm a C compiler is present and the parsers compile (`:TSInstall` / `:checkhealth nvim-treesitter`).

## 3. Highlight + indent (core APIs)

- [ ] 3.1 Add a `FileType` autocmd (or ftplugin wiring) calling `vim.treesitter.start()` for the supported filetypes.
- [ ] 3.2 Set `indentexpr` via `v:lua.require'nvim-treesitter'.indentexpr()` where indent is wanted.
- [ ] 3.3 Test whether markdown still triggers the nil-range error on `main`; keep the `disable`/`after/ftplugin/markdown.lua` `vim.treesitter.stop()` only if still needed, otherwise remove it.

## 4. Text objects (textobjects `main`)

- [ ] 4.1 Call `require('nvim-treesitter-textobjects').setup{}` with select/move config.
- [ ] 4.2 Map select objects `af`/`if`, `ac`/`ic`, `aa`/`ia` (operator + visual) via the select API; gate off Lisp filetypes.
- [ ] 4.3 Map motions `]f`/`[f`/`]F`/`[F` (add to jumplist) via the move API; gate off Lisp; do NOT map `]c`/`[c`.

## 5. Validation (Neovim 0.12)

- [ ] 5.1 Highlight: `vim.treesitter.highlighter.active[bufnr]` non-nil in lua/fsharp/c_sharp/haskell buffers.
- [ ] 5.2 Select: `vaf` selects a whole function, `vif` its body, `via` an argument, `daf` deletes a function — with no `tsrange`/removed-API error.
- [ ] 5.3 Motions: `]f`/`[f`/`]F`/`[F` jump between functions and populate the jumplist.
- [ ] 5.4 Lisp: `vaf` in `.clj`/`.lisp`/`.janet` still follows vim-sexp (text objects not attached).
- [ ] 5.5 No collisions: gitsigns `]h`/`[h`, unimpaired `]b`/`[b`, and diff-mode `]c`/`[c` still work.
- [ ] 5.6 `find . -name '*.lua' -print0 | xargs -0 luac -p` passes; `:messages` clean on startup.

## 6. Documentation

- [ ] 6.1 Re-add the text-objects section to `docs/modules/ROOT/pages/editor/navigation.adoc` (main-branch note).
- [ ] 6.2 Re-add the text-object rows to the editor cheatsheet (`editor/keybindings.adoc`).
- [ ] 6.3 Update `docs/modules/ROOT/pages/other/architecture.adoc` treesitter entries (pin `main`; core-API highlight; textobjects restored).
- [ ] 6.4 Note in the treesitter/editor guide that the config now tracks nvim-treesitter `main` and requires Neovim ≥ 0.11.
