## 1. Guard the indent expression

- [x] 1.1 In the `FileType` autocmd at `lua/plugins/treesitter.lua:50-55`, resolve the buffer's filetype to a treesitter language with `vim.treesitter.language.get_lang(ft)` and set `indentexpr` only when `nvim_get_runtime_file("queries/<lang>/indents.scm", true)` is non-empty. Leave `vim.treesitter.start()` unconditional — highlighting is unaffected and every filetype in the list has a `highlights.scm`.
- [x] 1.2 Compute the check rather than hardcoding `{ lua, markdown }` (design D1). A list would be correct today and silently wrong the moment upstream ships another query — the exact failure mode that produced this defect.
- [x] 1.3 Comment *why* the guard exists, naming the precedence that makes an unguarded `indentexpr` harmful: it outranks `'lisp'`, `cindent`, `smartindent` and `autoindent`, so setting it without a query removes indenting rather than adding it.
- [x] 1.4 Verify per filetype that `indentexpr` is now empty for `lisp`, `clojure`, `scheme`, `fennel`, `janet`, `fsharp`, `vim`, `http`, `cs` and `haskell`, and still set for `lua`.
- [x] 1.5 `after/ftplugin/markdown.lua:9` sets `indentexpr` directly and markdown *does* ship a query, so the assignment stays (design D5). Add a comment recording that it is deliberately exempt from the guard, and what would have to change if upstream ever dropped `markdown/indents.scm`.

> **Finding — the fallback is better than the proposal assumed.** The design said filetypes without an
> indent query would fall back to `autoindent`/`smartindent`, or `'lisp'` for the Lisp family. In fact
> several fall back to **Neovim's own built-in filetype indent scripts**, which the blanket
> `indentexpr` was also suppressing:
>
> | filetype | indentexpr after the guard | source |
> |---|---|---|
> | `cs` | `GetCSIndent(v:lnum)` | `indent/cs.vim` — purpose-built C# indenting |
> | `clojure` | `GetClojureIndent()` | `indent/clojure.vim` — purpose-built Clojure indenting |
> | `lua` | treesitter | has an `indents.scm`, correct |
> | `haskell`, `fsharp`, `http`, `vim` | *(none)* | no runtime script; `autoindent`/`smartindent` |
> | `lisp`, `scheme`, `fennel`, `janet` | *(none)* | `'lisp'` + `lispwords` from the ftplugins |
>
> Measured after the guard: C# `src=4 -> new=4` via `GetCSIndent`; Clojure `src=7 -> new=7` via
> `GetClojureIndent`. So C# gains real C# indenting rather than merely "same as the line above", and
> Clojure gains real Clojure indenting rather than generic `'lisp'`. Validation in group 4 should
> expect *correct* indenting, not just non-zero indenting.

## 2. Restore the fold providers

- [x] 2.1 In `lua/plugins/ufo.lua`, change the default return from `{ "lsp", "indent" }` to `{ "lsp", <second> }`, where the second slot is `treesitter` when the language ships a `folds.scm` and `indent` when it does not. LSP stays first so Roslyn's C# `#region` folds keep precedence. **(Revised — see the note below; the original three-element list is not a valid value.)**
- [x] 2.2 Change the markdown branch from `{ "indent" }` to `{ "treesitter", "indent" }`. **(Revised — `lsp` deliberately omitted; with two slots it would displace the indent fallback that list folding needs, in exchange for a client that is not installed.)**
- [x] 2.3 Leave the asciidoctor branch returning `""`; `vim-asciidoctor` keeps owning section folds.
- [x] 2.4 Rewrite the glow comment as **history**, not deletion (design D4): treesitter folding was disabled in May 2026 (commit `1912875`) because of `UnhandledPromiseRejection` errors in glow's preview buffer; glow is gone, its replacement float does not reproduce it, and ufo now checks for a fold query itself at `provider/treesitter.lua:160`.
- [x] 2.5 ~~Do **not** add a query-existence guard for folds — ufo already does it.~~ **Reversed.** ufo's guard prevents an *error* when a query is missing; it does not choose a fallback. With only two slots, choosing is the configuration's job, so `has_fold_query()` now mirrors the indent guard in `treesitter.lua`.

> **Design issue found during implementation — D2 and D3 revised.** `provider_selector` accepts at most
> **two** providers, a main and a fallback (`ufo/fold/manager.lua:110-121`). A third raises
> `UnhandledPromiseRejection` and ufo then produces **no folds at all** — it does not degrade.
> Measured: Lua had `maxfoldlevel=2` before the change and `0` with `{ "lsp", "treesitter", "indent" }`,
> so the first attempt made folding strictly worse than the state it was fixing. Caught by comparing
> against `main` rather than by reading the result in isolation.
>
> Note this is the **same error class** the May 2026 commit was reacting to. If it ever reappears,
> suspect the provider list shape before suspecting buffer types.
>
> **A trivial fixture briefly looked like a broken provider.** `testdocs/hello.hs` is seven lines of
> one-liners with nothing foldable and reported `maxfoldlevel=0`, which read as "Haskell folding is
> broken". It folds correctly (`maxfoldlevel=1`) on a file with real structure. Same trap that made the
> old `testdocs/test.md` useless for fold testing — fold checks need files with nested constructs.
>
> Verified after the revision, with no errors and nothing collapsed on open:
>
> | filetype | maxfoldlevel | provider |
> |---|---|---|
> | lua | 2 | lsp (`lua_ls`) — matches the pre-change baseline |
> | markdown | 6 | treesitter (heading hierarchy) |
> | haskell | 1 | treesitter |
> | clojure | 1 | treesitter |
> | fsharp | 1 | indent — no `folds.scm`, no server |
> | asciidoctor | 3 | `vim-asciidoctor`, untouched |

## 3. Syntax and formatting

- [x] 3.1 `find . -name '*.lua' -not -path './.git/*' -not -path './build/*' -print0 | xargs -0 luac -p`
- [x] 3.2 `stylua --check lua/ after/`

## 4. Manual validation (required — this is a runtime change)

- [x] 4.1 Add a `## Change · align-treesitter-providers` section to `openspec/TEST_PLAN.md`, following the existing sections' structure (branch, prerequisites, then numbered Prepare / Validate / Raise PR & merge / Post-merge).
- [x] 4.2 **Indent, the reported defect.** In `testdocs/csharp-project/Program.cs`, put the cursor at the end of a line indented 8 columns, press Enter and type a character. The new line must be indented 8, not 0. (Type a character — Vim strips autoindent from a line left empty, which will otherwise make a passing result look like a failure.)
- [x] 4.3 Repeat 4.2 for Haskell and F#, which have no indent query and now rely on `autoindent`/`smartindent`.
- [x] 4.4 **Lisp family — the part nobody has experienced.** For each of `lisp`, `clojure`, `scheme` and `janet`, confirm `indentexpr` is empty, `'lisp'` is on, and newline inside a form indents per Lisp rules. For Common Lisp specifically, check the `lispwords` entries take effect: a `defmethod` / `defgeneric` / `defclass` body should indent as a definition body, not as a function call's arguments. This configuration has never been active, so treat unexpected results as new information rather than a regression.
- [x] 4.5 Confirm `nvim-parinfer` and `vim-sexp` still behave correctly in Lisp buffers now that `indentexpr` no longer overrides them.
- [x] 4.6 Confirm Lua indenting is unchanged — it is the one filetype that keeps the treesitter expression.
- [x] 4.7 **C# `#region` folds must be unaffected.** Open a C# file containing `#region` blocks with Roslyn attached and confirm each region folds as one unit. This is the guarantee the provider ordering exists to protect.
- [x] 4.8 **Markdown heading folds.** Open `testdocs/test.md`; confirm headings begin foldable sections with nested levels, and that the nested-list folds still work. `zM` should collapse the document to its outline.
- [x] 4.9 Confirm folds now appear in Lua, Haskell, Vim and HTTP buffers, and in a Lisp-family buffer.
- [x] 4.10 Confirm asciidoctor still owns its own folds and ufo supplies none.
- [x] 4.11 **Exercise the special-buffer path.** The May 2026 commit blamed "special/temporary buffers" generally, not glow specifically, so the error may not have been glow-only. Open the markdown float (`<leader>?` and `:MarkdownPopup`) and a Conjure HUD/eval popup, watching `:messages` for `UnhandledPromiseRejection`.
- [x] 4.12 Confirm no buffer opens with folds already closed — `foldlevel` and `foldlevelstart` are both 99, so this should hold, but it is the most visible way the change could annoy.
- [x] 4.13 Fresh `nvim` — `:messages` shows no plugin, LSP or keymap **errors**. It will not necessarily be empty: lazy.nvim's update checker reports available updates at startup, which is expected.
- [x] 4.14 Tick each TEST_PLAN box only once genuinely confirmed, logging any defect and its fix inline as a blockquote note.

## 5. Correct the overclaiming spec Purpose

- [x] 5.1 `openspec/specs/treesitter-editing/spec.md` opens by claiming treesitter provides "syntax highlighting, indentation, and semantic text objects/motions for non-Lisp languages (F#, C#, Haskell, Lua)". The indentation half is false for three of those four — only Lua ships an `indents.scm`. Correct the Purpose to say indentation applies only where a query exists.
- [x] 5.2 This **cannot** be done by a delta: deltas operate on requirements, not Purpose prose, so `openspec archive` will not do it. Edit the spec directly as part of this change and note in the commit that it accompanies the `treesitter-editing` delta, so it does not read as unexplained spec drift.
- [x] 5.3 Re-run `openspec validate --all --strict` after the edit.

## 6. Ship

- [x] 6.1 Only once every validation step is ticked, push the branch and raise the PR.
- [x] 6.2 Confirm `openspec validate align-treesitter-providers --strict` and `--all --strict` both pass.
- [x] 6.3 Record the answer to the design's open question — whether restoring `'lisp'` indenting actually feels right in each Lisp filetype — in the change record. The user's stated position is to let the existing tools own it and revisit downstream if it disappoints; the verdict belongs somewhere durable.
