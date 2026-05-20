## 1. Content Files — Core Cheatsheet

- [x] 1.1 Create `cheatsheets/core.md` with universal keybindings: LSP, window/split navigation, terminal toggle, git (fugitive + gitsigns + diffview), Copilot, visual editing, system clipboard, formatting, auto-completion
- [x] 1.2 Create `cheatsheets/lisp.md` with Conjure eval/REPL-log bindings and vim-sexp slurp/barf bindings
- [x] 1.3 Create `cheatsheets/janet.md` with Janet-specific Conjure bindings
- [x] 1.4 Create `cheatsheets/fsharp.md` with iron.nvim REPL bindings
- [x] 1.5 Create `cheatsheets/haskell.md` with haskell-tools GHCi and Hoogle bindings
- [x] 1.6 Create `cheatsheets/markdown.md` with mkdnflow, preview, MARP, Confluence, and Jira bindings

## 2. Content Files — Mini-Guides

- [x] 2.1 Create `guides/sbcl-swank.md`: launch the sbcl-swank Docker image and connect Conjure (,cc → localhost:4005)
- [x] 2.2 Create `guides/clojure-nrepl.md`: start an nREPL server and connect Conjure
- [x] 2.3 Create `guides/dotnet-fsi.md`: start F# REPL via `dotnet fsi` and iron.nvim
- [x] 2.4 Create `guides/ghci-workflow.md`: open GHCi via haskell-tools and common workflow

## 3. Lua Module

- [x] 3.1 Create `lua/config/cheatsheet.lua`: filetype-to-cheatsheet mapping table (`ft_map` with `sheet` and `guides` fields)
- [x] 3.2 Implement `open_cheatsheet()`: assemble core.md + ft-specific file into a stable cache path, delegate to `vim.cmd("Glow ...")` via glow.nvim
- [x] 3.3 Dismiss keymaps handled natively by glow.nvim (`q`/`Esc`)
- [x] 3.4 Implement `pick_guide()`: show ft-relevant guides (or all guides) via `vim.ui.select`; replaces numbered in-float shortcuts
- [x] 3.5 Implement `open_guide(slug)`: open `guides/<slug>.md` via `vim.cmd("Glow ...")`
- [x] 3.6 Wire into `lua/keymaps.lua`: `<leader>?` → `open_cheatsheet()`, `<leader>?g` → `pick_guide()`
- [x] 3.7 Add `cmd = { "Glow" }` to glow.nvim spec so `:Glow` loads from any filetype

## 4. Validation

- [x] 4.1 Syntax-check `lua/config/cheatsheet.lua` with `luac -p`
- [x] 4.2 Manually verify `<leader>?` from a plain buffer opens core-only cheatsheet via glow
- [x] 4.3 Manually verify `<leader>?` in a `.lisp` buffer shows core + lisp content via glow
- [x] 4.4 Manually verify `<leader>?g` opens guide picker and selected guide renders via glow
- [x] 4.5 Manually verify `q` and `<Esc>` dismiss the glow float

## 5. Documentation Updates

- [x] 5.1 Add `<leader>?` to the keybindings table in `readme.md`
- [x] 5.2 Add a note to `docs/modules/ROOT/pages/cheatsheets/index.adoc` pointing to `<leader>?` as the in-editor quick reference
