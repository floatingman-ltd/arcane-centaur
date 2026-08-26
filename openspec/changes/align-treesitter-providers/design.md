## Context

Two treesitter provider decisions in this config were made without checking which queries `nvim-treesitter` actually ships. See `proposal.md` for the measurements; this document is about how to correct them.

The relevant code is small and in two places:

```
lua/plugins/treesitter.lua:50-55        lua/plugins/ufo.lua:7-21
┌──────────────────────────────┐        ┌──────────────────────────────┐
│ FileType autocmd over        │        │ provider_selector(ft)        │
│ HIGHLIGHT_FILETYPES:         │        │   markdown    → {indent}     │
│   vim.treesitter.start()     │        │   asciidoctor → ""           │
│   vim.bo.indentexpr = <ts>   │        │   else        → {lsp,indent} │
└──────────────────────────────┘        └──────────────────────────────┘
        ▲ applies to all 13                      ▲ treesitter absent everywhere
```

Constraints worth stating:

- **Filetype ≠ language.** `lisp` → `commonlisp`, `janet` → `janet_simple`, `cs` → `c_sharp`. Any query-existence check must resolve the language first. Verified that `vim.treesitter.language.get_lang(ft)` handles all three correctly.
- **`indentexpr` outranks everything.** Vim's precedence is `indentexpr` → `'lisp'` → `cindent` → `smartindent` → `autoindent`. Setting it unconditionally does not merely add treesitter indenting; it *removes* whatever the filetype had arranged.
- **ufo accepts at most two providers.** `provider_selector` takes a main and a fallback (`ufo/fold/manager.lua:110-121`); a third raises `UnhandledPromiseRejection` and ufo then produces no folds at all. This constraint was discovered during implementation and reshaped D2 and D3.
- **ufo guards the treesitter provider against a missing query** (`provider/treesitter.lua:160`), so it will not *error* where no `folds.scm` exists — but it does not choose a fallback. With only two slots, selecting the second provider is the configuration's job.
- **`foldlevel` and `foldlevelstart` are both 99** (`lua/options.lua:42-43`), so new folds never collapse a buffer on open.

## Goals / Non-Goals

**Goals:**

- Treesitter is used for indentation only where an `indents.scm` exists, and for folding wherever a `folds.scm` exists.
- Filetypes without an indent query get their *own* indent behaviour back — `'lisp'` and `lispwords` for the Lisp family, `autoindent`/`smartindent` elsewhere.
- Structural folds become available in the languages that ship a fold query.
- C# `#region` folding, which is LSP-provided, is unaffected.
- The rule is expressed as a check, not a hand-maintained list, so it stays correct as `nvim-treesitter` adds or removes queries.

**Non-Goals:**

- Installing `marksman` or `fsautocomplete`, or fixing their documentation. Tracked separately; F# therefore gains nothing here.
- Changing `foldlevel`, `foldlevelstart`, `foldcolumn`, or the fold text handler.
- Asciidoctor's fold ownership by `vim-asciidoctor`.
- Adding indent queries upstream, or shipping local `indents.scm` files. That is a much larger undertaking and is not what the defect calls for.
- Reviewing `nvim-parinfer` or `vim-sexp` behaviour beyond confirming they are no longer suppressed.

## Decisions

**D1 — Guard `indentexpr` on query existence, computed rather than listed.**

In the `FileType` autocmd, resolve the buffer's language with `vim.treesitter.language.get_lang(ft)` and set `indentexpr` only when `nvim_get_runtime_file("queries/<lang>/indents.scm", true)` is non-empty.

- _Why computed:_ a hardcoded `{ lua, markdown }` list would be correct today and silently wrong the moment upstream adds a query — the same failure mode that created this defect. A check cannot drift.
- _Alternative rejected — split `HIGHLIGHT_FILETYPES` into two lists._ Explicit, but it encodes today's upstream state as configuration and needs manual revisiting forever.
- _Alternative rejected — set `cindent` for the C-like filetypes (`c_sharp`, `fsharp`)._ Tempting, but it is a *new* behaviour nobody asked for, and `smartindent` already covers the reported case. If C# indenting still disappoints once the override is gone, that is a separate, informed decision.
- _Cost:_ one `nvim_get_runtime_file` call per `FileType` event. Negligible, and it can be memoised per language if it ever shows up.

**D2 — Restore `treesitter` to the fold providers, choosing the second slot by query availability.**

**Revised during implementation.** This decision originally specified `{ "lsp", "treesitter", "indent" }`. That is not a valid value: `provider_selector` accepts at most **two** providers, a main and a fallback (`ufo/fold/manager.lua:110-121`), and a third raises `UnhandledPromiseRejection` — after which ufo produces **no folds at all**. It does not degrade. Measured: Lua had `maxfoldlevel=2` before the change and `0` with a three-element list, so the first attempt made folding strictly worse.

The chain is therefore `{ "lsp", <second> }`, where the second slot is `treesitter` when the language ships a `folds.scm` and `indent` when it does not.

- _Why LSP first:_ it protects C# `#region` folds, which come from Roslyn and have their own requirement in `code-folding`.
- _Why compute the second slot:_ with only two slots there is no room for a blanket third fallback, so the choice has to be made deliberately. This makes the fold side symmetric with D1's indent guard — both ask "does the query exist?" — which is a more coherent design than the original, not merely a workaround.
- _This supersedes the original reasoning that no guard was needed_ because ufo self-guards at `provider/treesitter.lua:160`. That guard prevents an *error* when a query is missing; it does not choose a fallback. With two slots, choosing is our job.
- _Alternative rejected — `{ "lsp", "treesitter" }` everywhere._ Simpler, but leaves any language with no server and no fold query — F# here — with no folds at all, losing the indent folding it has today.
- _Alternative rejected — treesitter before LSP._ More consistent across filetypes, but demotes Roslyn's `#region` folds, which the user explicitly asked to keep.

**D3 — Markdown becomes `{ "treesitter", "indent" }`, not indent-only.**

**Revised during implementation**, for the same two-slot reason as D2. The original specified `{ "lsp", "treesitter", "indent" }`, reasoning that including `lsp` cost nothing while `marksman` was absent and would pay off if it were installed. With only two slots that is no longer free: including `lsp` would displace the `indent` fallback.

- _Why treesitter first:_ it is the only thing that can produce heading folds here. Verified on `testdocs/test.md`: six fold levels tracking the heading hierarchy, `zM` collapsing the document to its outline, no errors.
- _Why keep `indent` as the fallback rather than `lsp`:_ `marksman` is not installed, so the `lsp` slot would be dead today in exchange for losing the list folding markdown currently has — trading a real capability for a hypothetical one.
- _Consequence to accept:_ if `marksman` is ever installed, this line must be revisited deliberately. That is a worse property than the original design claimed, and it is a genuine cost of the two-slot limit rather than a preference.

**D4 — Keep the glow history in the `code-folding` spec, rewritten rather than deleted.**

The requirement flips from "treesitter folding SHALL NOT be used" to using it, but the rationale is retained as history: it was disabled in May 2026 because of errors in glow's preview buffer, glow no longer exists, and the replacement float does not reproduce the problem.

- _Why:_ that sentence is why the config looked wrong for three months. Deleting it invites someone to rediscover the "errors" folklore and re-disable the provider. One sentence is cheap insurance.

**D5 — Leave `after/ftplugin/markdown.lua:9` setting `indentexpr` directly.**

Markdown *has* an indent query, so the assignment is correct. It is deliberately outside the `HIGHLIGHT_FILETYPES` autocmd (markdown is not in that list) so preview tooling can override it.

- _Trade-off:_ the guard logic then lives in one place and a correct-but-unguarded assignment in another. Accepted because markdown is the one filetype where the assignment is provably right — but it is exactly the line that would need revisiting if upstream ever dropped `markdown/indents.scm`, so it should carry a comment saying why it is exempt.

## Risks / Trade-offs

- **Folds appear where users are used to none.** Structural folds become available in Lua, C#, Haskell, Vim, HTTP, markdown and the Lisp family. → Mitigated by `foldlevel = 99`: nothing collapses on open, folds are opt-in via `zM`/`zc`. Still a visible change to the fold column.
- **Lisp-family indenting changes for the first time.** `'lisp'`, `lispwords`, parinfer and vim-sexp have all been suppressed, so restoring them is a real behavioural shift in four filetypes — and one nobody has actually experienced. → Validate each Lisp filetype separately rather than assuming one result generalises. If `'lisp'` proves worse than the current always-zero behaviour, that is worth knowing, but it is hard to see how.
- **C# `#region` folds could regress** if the provider ordering is wrong. → Explicit validation step; it is the one fold behaviour with a dedicated requirement.
- **Treesitter folds may disagree with LSP folds** where both exist (Lua via `lua_ls`, C# via Roslyn). ufo takes the first provider that returns ranges, so LSP wins and treesitter is never consulted there. → Not a conflict in practice, but worth confirming rather than assuming.
- **The May 2026 error might not have been glow-specific.** The commit blamed "special/temporary buffers"; if something else in the config still creates such buffers, the `UnhandledPromiseRejection` could return. → The obvious candidates are the new markdown float (`buftype=nofile`, already verified clean) and Conjure's HUD. Exercise both during validation. **Note this same error was reproduced during implementation from an over-long provider list** — so if it reappears, suspect the list shape before suspecting buffer types.
- **A trivial fixture can look like a broken provider.** `testdocs/hello.hs` is seven lines of one-liners with nothing foldable, and reported `maxfoldlevel=0` — briefly mistaken for Haskell folding being broken. It folds correctly (`maxfoldlevel=1`) on a file with real structure. → Validate folds against files that actually contain nested constructs; the same trap previously made `testdocs/test.md` useless for fold testing.

## Migration Plan

1. Add the query-existence guard to the `FileType` autocmd in `lua/plugins/treesitter.lua`; confirm `indentexpr` is set for `lua` only (markdown is set by its ftplugin) and empty for the other ten.
2. Verify the indent fix per family: C#/Haskell/F#/vim/http fall back to `autoindent`; the four Lisp filetypes fall back to `'lisp'` and honour `lispwords`.
3. Update `provider_selector` in `lua/plugins/ufo.lua`, rewriting the glow comment as history.
4. Verify folds: markdown headings, C# `#region` still LSP-provided, a Lisp file, and asciidoctor still owning its own.
5. Exercise the special-buffer path — markdown float and Conjure HUD — watching for `UnhandledPromiseRejection`.
6. Spec deltas for `code-folding` and `treesitter-editing`, including the Purpose correction.

**Rollback:** both edits are self-contained and independently revertible — the guard is one conditional, the provider change is one list. Reverting either does not affect the other.

## Open Questions

- **Does restoring `'lisp'` indenting actually feel right in each Lisp filetype?** It has never been active, so there is no prior experience to appeal to. The user's stated preference is to let the existing tools own it and revisit downstream if that disappoints — recorded here so the eventual answer has somewhere to land.
- **Should the `indents.scm` check be memoised?** Only worth answering if `FileType` handling measurably slows; noted so it is a deliberate omission rather than an oversight.
