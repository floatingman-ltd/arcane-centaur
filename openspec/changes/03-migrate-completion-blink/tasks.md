## 1. Replace the completion engine

- [x] 1.1 Create `lua/plugins/blink.lua` with a `saghen/blink.cmp` spec pinned to v1 (`version = "1.*"`), depending on `saghen/blink.compat` and `f3fora/cmp-spell`.
- [x] 1.2 Configure built-in sources `lsp`, `buffer`, `path`, `snippets`; configure the keymap table to reproduce current ergonomics (`<CR>` accept-no-preselect, `<C-n>`/`<C-p>` navigate, `<C-e>` hide, `<M-Space>` show, `<C-b>`/`<C-f>` scroll docs) with `completion.list.selection.preselect = false`.
- [x] 1.3 Add the `spell` provider via `blink.compat`, gated to fire only when `vim.opt.spell:get()` is true and not on 1–2 character tokens (preserve `keyword_length = 3` semantics).
- [x] 1.4 Add the `conjure` provider via `blink.compat`, scoped to lisp filetypes; keep `cmp-conjure` declared as a Conjure dependency in `lua/plugins/lisp.lua` (no removal there).
- [x] 1.5 Configure cmdline completion: `/` and `?` → `buffer`; `:` → `path` then `cmdline`.
- [x] 1.6 Delete `lua/plugins/nvim-cmp.lua` (removing `nvim-cmp`, `cmp-nvim-lsp`, `cmp-buffer`, `cmp-path`, `cmp-cmdline`, `cmp_luasnip`, and the dead LuaSnip expand shim).

## 2. Wire completion capabilities into LSP

- [x] 2.1 In `lua/config/lsp.lua`, replace the hand-built `capabilities` with `require("blink.cmp").get_lsp_capabilities({...})`, retaining the `textDocument.foldingRange` settings for nvim-ufo.
- [x] 2.2 Guard against load-order issues (`pcall` fallback to `make_client_capabilities()` if blink is not yet available).

## 3. Validation

- [ ] 3.1 `:Lazy sync` — confirm blink.cmp installs and builds its fuzzy matcher with no errors, and the six removed cmp plugins are gone from `:Lazy`.
- [ ] 3.2 Confirm LSP, buffer, and path completion work in a Lua and an F# buffer.
- [ ] 3.3 Confirm `<CR>` does NOT auto-insert the first suggestion (nothing preselected); `<C-n>`/`<C-p>` navigate; `<C-e>` hides the menu.
- [ ] 3.4 Confirm cmdline completion: `:` completes paths and Ex commands; `/` completes buffer words.
- [ ] 3.5 **Conjure bridge** — open a `.clj` (or `.lisp`/`.janet`) buffer with a REPL connected and confirm Conjure symbol completions appear in the blink menu. If absent, apply the load-order mitigation in `design.md`.
- [ ] 3.6 **Spell bridge** — confirm spell-correction completions appear in a markdown buffer with `:set spell`, and do NOT appear in a code buffer.
- [x] 3.7 Run Lua syntax check: `find . -name '*.lua' -print0 | xargs -0 luac -p`.

## 4. Documentation

- [x] 4.1 Update `docs/modules/ROOT/pages/editor/code-intelligence.adoc` (and its cheatsheet if completion keymaps are listed there) to describe blink.cmp as the completion engine and list the menu keymaps.
- [x] 4.2 Update `docs/modules/ROOT/pages/other/architecture.adoc` if it references nvim-cmp as the completion plugin.
- [x] 4.3 Update `CLAUDE.md` if it names nvim-cmp anywhere (verified with grep — no references found).
