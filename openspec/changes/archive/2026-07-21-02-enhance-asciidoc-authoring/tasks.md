## 1. Verify upstream behavior (do first)

- [x] 1.1 Read the vim-asciidoctor README: confirm the filetype name (`asciidoctor`), the exact extensions its `ftdetect` claims, and the global option names (`asciidoctor_extensions`, `asciidoctor_folding`, `asciidoctor_fold_options`, `asciidoctor_fenced_languages`, `asciidoctor_syntax_conceal`).
- [x] 1.2 Read the markview README: confirm AsciiDoc support and how its renderer binds to a filetype (whether `preview.filetypes` alone activates the AsciiDoc spec, or a filetype-alias/registration call is needed for a non-`asciidoc` filetype).

## 2. Add vim-asciidoctor + canonical filetype

- [x] 2.1 Create `lua/plugins/asciidoc.lua` with a `habamax/vim-asciidoctor` spec lazy-loaded on `ft = { "asciidoctor" }`.
- [x] 2.2 In its `init`, call `vim.filetype.add` mapping `adoc`/`asciidoc`/`asciidoctor` extensions → filetype `asciidoctor`; set `asciidoctor_extensions = {}` (disable compile commands); enable folding + fenced-language highlighting; set `asciidoctor_syntax_conceal = 0`.
- [x] 2.3 Rename `after/ftplugin/asciidoc.lua` → `after/ftplugin/asciidoctor.lua` (preview map bodies unchanged: `<localleader>p`/`pp`/`pa`).

## 3. Add markview (opt-in, scoped)

- [x] 3.1 Add an `OXY2DEV/markview.nvim` spec (in `lua/plugins/asciidoc.lua`) scoped to `ft = { "asciidoctor" }`, `preview.enable = false`, `preview.filetypes = { "asciidoctor" }`. Do NOT include `markdown`.
- [x] 3.2 Add a buffer-local toggle map in `after/ftplugin/asciidoctor.lua`: `<localleader>mv` → `:Markview Toggle`.
- [x] 3.3 markview AsciiDoc rendering deferred (fallback b): markview's pipeline is fully treesitter-driven; AsciiDoc requires `cathaysia/tree-sitter-asciidoc`, which is not in nvim-treesitter master and is out of scope per the proposal. Removed markview spec + `,mv` keymap; noted in docs and architecture.

## 4. Validation

- [x] 4.1 `:Lazy sync` — vim-asciidoctor installs with no errors. _(markview deferred per 3.3; not installed.)_ (TEST_PLAN §2.1)
- [x] 4.2 Open a `.adoc` file cold (first of the session): `:set filetype?` → `asciidoctor`; syntax is highlighted; sections fold; a `[source,lua]` block highlights as Lua. (TEST_PLAN §2.2)
- [x] 4.3 Confirm `<localleader>p`/`pp` (Docker HTML) and `<localleader>pa` (Antora) still fire. (TEST_PLAN §2.3)
- [x] 4.4 ~~Toggle markview (`<localleader>mv`): rendered view appears; toggle again restores raw markup.~~ — N/A: markview deferred (3.3); validated instead that markview is **absent** from `:Lazy` (TEST_PLAN §2.4).
- [x] 4.5 Open a `.md` file: markview does not activate (not installed); markdown-preview/glow still work. (TEST_PLAN §2.4)
- [x] 4.6 `grep -rn asciidoc lua/ after/` shows no stale `asciidoc`-keyed logic.
- [x] 4.7 `find . -name '*.lua' -print0 | xargs -0 luac -p`.

## 5. Documentation

- [x] 5.1 Add a `docs/modules/ROOT/pages/content/asciidoc.adoc` guide describing the syntax/folding/fenced-code support, the canonical `asciidoctor` filetype, and the markview toggle vs. Docker/Antora preview distinction.
- [x] 5.2 Update `docs/modules/ROOT/pages/content/asciidoc-cheatsheet.adoc` with the markview toggle (`<localleader>mv`) and a note that preview maps are now under the `asciidoctor` filetype.
- [x] 5.3 Add an `xref:content/asciidoc.adoc[AsciiDoc Guide]` entry to `docs/modules/ROOT/nav.adoc` (Content Creation section, above the existing cheatsheet entry).
- [x] 5.4 Update `docs/modules/ROOT/pages/other/architecture.adoc` and `CLAUDE.md` where they describe AsciiDoc tooling (note vim-asciidoctor as the syntax source and the `asciidoctor` filetype; verify with grep before editing).
