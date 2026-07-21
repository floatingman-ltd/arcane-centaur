# 01 — treesitter text objects → **re-scoped to treesitter highlight**

> **Outcome (revised 2026-07-07):** the text objects this change was named for were
> **backed out**. nvim-treesitter's `master` branch and `nvim-treesitter-textobjects`
> (master) are frozen and break on **Neovim 0.12** — the textobjects query path calls
> a removed API (`nvim-treesitter/tsrange.lua` → `:start()`), so `vaf`/`vif`/`daf`/`]f`/`[f`
> silently no-op. The part that survives and is worth keeping is **treesitter
> highlight/indent for non-core languages** (F#/C#/Haskell/Lua), which works because
> highlighting runs through Neovim's **core** engine, not the broken path.
>
> Relevant commits: `f5b66ed` (original), `8080040` (route `opts` through
> `configs.setup` so the config actually applies), `e2b5a7f` (remove text objects).
>
> **To get text objects working**, nvim-treesitter **and** nvim-treesitter-textobjects
> must move to their `main` branch (a config rewrite) — tracked as a separate change,
> not here.

## 1. Branch reconciliation + parser

- [x] 1.1 In `lua/plugins/treesitter.lua`, keep `branch = "master"` on the `nvim-treesitter` spec.
- [x] 1.2 Route `opts` through `require("nvim-treesitter.configs").setup(opts)` — lazy's default `opts` path calls a zero-arg `require("nvim-treesitter").setup()` that discards them.
- [x] 1.3 `ensure_installed`: add `haskell`; fix invalid names (`lisp`→`commonlisp`, drop `plantuml` — no parser).
- [x] 1.4 ~~Add `nvim-treesitter/nvim-treesitter-textobjects` dependency~~ — **REMOVED** (broken on 0.12).

## 2. Highlight (kept) / text objects (backed out)

- [x] 2.1 `highlight` + `indent` enabled via `configs.setup`; `markdown`/`markdown_inline` disabled (nil-range hotfix).
- [x] 2.2 ~~`textobjects.select`/`move` blocks (`af`/`if`/`ac`/`ic`/`aa`/`ia`, `]f`/`[f`/`]F`/`[F`) gated off for Lisp~~ — **REMOVED** (see Outcome).

## 3. Validation

- [x] 3.1 Parsers install (`commonlisp`/`clojure`/`scheme`/`lua`/`fsharp`/`vim`/`markdown`+`_inline`/`http`/`c_sharp`/`haskell`); a C compiler must be on PATH.
- [x] 3.2 Treesitter highlighting active in Lua/F#/C#/Haskell buffers — verified: highlighter non-nil (was a no-op before `8080040`).
- [x] 3.3 ~~`vaf`/`vif`/`via`/`daf`/`]f`/`[f` text objects~~ — **N/A** (backed out; broken on Neovim 0.12).
- [x] 3.4 Lisp buffers (`.clj`/`.lisp`/`.janet`) still use vim-sexp — text objects never attached there.
- [x] 3.5 vim-unimpaired / gitsigns bracket maps unaffected — no `]f`/`[f` maps are added.
- [x] 3.6 `find . -name '*.lua' -print0 | xargs -0 luac -p` passes.

## 4. Documentation

- [x] 4.1 Text-object section removed from `docs/modules/ROOT/pages/editor/navigation.adoc`.
- [x] 4.2 Text-object rows removed from the editor cheatsheet (`editor/keybindings.adoc`).
- [x] 4.3 `docs/modules/ROOT/pages/other/architecture.adoc` treesitter entries reworded (`master` pin + `configs.setup`; no text objects).
