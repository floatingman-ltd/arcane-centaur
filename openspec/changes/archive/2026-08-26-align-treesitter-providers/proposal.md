## Why

Treesitter provider choices in this config were never checked against which queries `nvim-treesitter` actually ships. The result is backwards on both axes:

| | query ships for | config uses it for | consequence |
|---|---|---|---|
| `indents.scm` | **2 of 13** filetypes | **all 13** | broken newline indenting in 11 |
| `folds.scm` | **11 of 13** filetypes | **none** | no structural folds anywhere |

**Indentation is actively broken.** `lua/plugins/treesitter.lua:50-55` sets `indentexpr` on a `FileType` autocmd for every filetype in `HIGHLIGHT_FILETYPES`. Only `lua` and `markdown` have an `indents.scm`; the other eleven (`commonlisp`, `clojure`, `scheme`, `fennel`, `janet_simple`, `fsharp`, `vim`, `markdown_inline`, `http`, `c_sharp`, `haskell`) get an expression with no query behind it, which returns 0. Because `indentexpr` **overrides** `autoindent`/`smartindent`, this is worse than not setting it at all. Measured in C#: pressing Enter on a line indented 8 columns produces a new line indented **0**; clearing `indentexpr` produces **8**.

Worse, four of those filetypes have *deliberately configured* indentation being silently discarded. `after/ftplugin/lisp.lua` sets `'lisp'` and appends `lispwords` for `defmethod,defgeneric,defclass,define,letrec`; `clojure.lua`, `scheme.lua` and `janet.lua` each set `'lisp'` too. Vim's precedence is `indentexpr` → `'lisp'` → `cindent` → `smartindent` → `autoindent`, so none of that tuning has ever taken effect. `nvim-parinfer` and `vim-sexp` are suppressed the same way.

**Folding is disabled where it would work.** `lua/plugins/ufo.lua` excludes the treesitter provider for every filetype. The reason is recorded in commit `1912875` (May 2026): `UnhandledPromiseRejection` errors *in glow's preview buffer* when pressing `,pp`. That was an over-broad fix — treesitter folding was removed from Lua, C#, Haskell, F# and the whole Lisp family to resolve an error in one plugin's terminal buffer. The trigger is now gone three ways: glow was deleted in `replace-glow-renderer`, its replacement float is `buftype=nofile` with `foldmethod=manual` and was verified clean, and ufo's provider now self-guards on query existence (`ufo/provider/treesitter.lua:160`).

Verified working today: treesitter folding on `testdocs/test.md` yields the full heading hierarchy — six fold levels, 14 headings carrying fold levels, `zM` collapsing all 133 lines, **zero errors**.

## What Changes

- **Set `indentexpr` only where an `indents.scm` exists.** In practice `lua` and `markdown`; every other filetype falls back to `autoindent`/`smartindent`, or to `'lisp'` where the ftplugin sets it. The guard must resolve filetype to language (`lisp` → `commonlisp`, `janet` → `janet_simple`, `cs` → `c_sharp`) rather than assuming they match.
- **Restore the treesitter fold provider.** Default chain becomes `{ "lsp", "treesitter", "indent" }` — LSP stays first so Roslyn's `#region` folds remain primary for C#, with treesitter filling in where the server offers nothing.
- **Markdown gains heading folds**: `{ "lsp", "treesitter", "indent" }`, replacing indent-only. `lsp` is included deliberately even though `marksman` is not installed — it is inert today and starts contributing automatically if that changes.
- Asciidoctor keeps its opt-out; `vim-asciidoctor` continues to own section folding.
- **BREAKING (behavioural, not configuration)**: folds appear in buffers that previously had none, and newline indenting changes in eleven filetypes. Both are the point, but both alter muscle memory.

## Capabilities

### New Capabilities

None. Both concerns belong to existing capabilities.

### Modified Capabilities

- `treesitter-editing`: its Purpose claims treesitter provides "indentation ... for non-Lisp languages (F#, C#, Haskell, Lua)" — false for three of the four, since only Lua ships an `indents.scm`. Needs correcting, plus a new requirement that `indentexpr` is set only where a query exists.
- `code-folding`: *LSP folds with indent fallback elsewhere* currently states "Treesitter folding SHALL NOT be used for any filetype — it errors on special buffers such as the `glow` preview", which this change reverses. *Per-filetype fold provider exceptions* requires markdown to fold "by indent only", which also changes. The glow rationale is to be **rewritten as history rather than deleted**, so the reason the config looked wrong for three months stays discoverable and nobody re-disables it.

## Impact

**Code**
- `lua/plugins/treesitter.lua:50-55` — guard the `indentexpr` assignment on query existence.
- `lua/plugins/ufo.lua` — provider lists, and the comment explaining the glow history.
- `after/ftplugin/markdown.lua:9` — sets `indentexpr` directly; markdown *has* a query so this stays, but it should not duplicate logic the guard now owns.

**Behaviour**
- Eleven filetypes regain `autoindent`; four Lisp-family filetypes regain `'lisp'`, `lispwords`, parinfer and vim-sexp indenting for the first time.
- Structural folds appear in Lua, C#, Haskell, Vim, HTTP, markdown and the Lisp family.
- C# `#region` folding must be verified unchanged — it is LSP-provided and the ordering is designed to protect it.

**Known limitations, not addressed here**
- **F# gets neither.** No `indents.scm`, no `folds.scm`, and `fsautocomplete` is configured but not installed — so F# folding stays indent-only until that server is present. Tracked separately in `recommendations/ideas.md` along with `marksman`, which is in the same state.
- `markdown_inline` has no `folds.scm`; it is an injected language and not folded directly.

**Risk is lower than it appears**: `lua/options.lua:42-43` sets `foldlevel = 99` and `foldlevelstart = 99`, so files still open fully expanded. New folds are available on demand rather than collapsing anything on open.
