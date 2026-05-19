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
- [x] 3.2 Implement `open_cheatsheet()`: read `cheatsheets/core.md` + ft-specific file, write to scratch buffer, open centred bordered float with `filetype=markdown`
- [x] 3.3 Implement float dismiss keymaps inside the float buffer: `q` and `<Esc>` close the window
- [x] 3.4 Implement numbered guide shortcuts: detect guide list from `ft_map`, append GUIDES section to buffer, map `1`–`9` keys to open the corresponding `guides/<slug>.md` in a new float
- [x] 3.5 Implement `open_guide(slug)`: read `guides/<slug>.md`, open in a new centred float with dismiss keymaps
- [x] 3.6 Wire the module into `lua/keymaps.lua`: add `<leader>?` Normal-mode mapping that calls `require("config.cheatsheet").open_cheatsheet()`

## 4. Validation

- [x] 4.1 Syntax-check `lua/config/cheatsheet.lua` with `luac -p`
- [ ] 4.2 Manually verify `<leader>?` opens correct content in a plain buffer (core only)
- [ ] 4.3 Manually verify `<leader>?` in a `.lisp` buffer shows core + lisp section + guide shortcuts
- [ ] 4.4 Manually verify guide float opens when pressing `1` from the lisp cheatsheet
- [ ] 4.5 Manually verify `q` and `<Esc>` dismiss both the cheatsheet and guide floats

## 5. Documentation Updates

- [x] 5.1 Add `<leader>?` to the keybindings table in `readme.md`
- [x] 5.2 Add a note to `docs/modules/ROOT/pages/cheatsheets/index.adoc` pointing to `<leader>?` as the in-editor quick reference
