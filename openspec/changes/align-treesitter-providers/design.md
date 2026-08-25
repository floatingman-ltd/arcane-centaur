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
- **ufo already guards folds.** `ufo/provider/treesitter.lua:160` checks `#get_query_files(lang, 'folds', nil) > 0` before using the provider, so listing `treesitter` for a language without `folds.scm` degrades rather than errors. The indent side has no equivalent guard — that is the asymmetry this change corrects.
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

**D2 — Restore `treesitter` to the fold provider chain as `{ "lsp", "treesitter", "indent" }`.**

- _Why this order:_ LSP first protects C# `#region` folds, which come from Roslyn and are covered by their own requirement in `code-folding`. Treesitter fills in where no server is attached — which, given `marksman` and `fsautocomplete` are missing, is most filetypes here. Indent remains the last resort.
- _Why not guard it like D1:_ ufo already does (`provider/treesitter.lua:160`). Duplicating the check would be redundant and would drift from ufo's own behaviour.
- _Alternative rejected — treesitter before LSP._ It would give more consistent folds across filetypes, but demotes Roslyn's `#region` folds, which is a stated requirement and a thing the user explicitly asked to keep.

**D3 — Markdown becomes `{ "lsp", "treesitter", "indent" }`, not indent-only.**

- _Why treesitter:_ it is the only thing that can produce heading folds here. Verified on `testdocs/test.md`: six fold levels tracking the heading hierarchy, 14 headings carrying levels, `zM` collapsing all 133 lines, no errors.
- _Why include `lsp` when `marksman` is not installed:_ it is inert with no client attached, and it means installing marksman later improves folds with no config change. Costs nothing now, removes a future gotcha.
- _Alternative rejected — `{ "treesitter", "indent" }`._ Marginally more honest about today's reality, but guarantees someone has to remember to edit this line when marksman appears.

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
- **The May 2026 error might not have been glow-specific.** The commit blamed "special/temporary buffers"; if something else in the config still creates such buffers, the `UnhandledPromiseRejection` could return. → The obvious candidates are the new markdown float (`buftype=nofile`, already verified clean) and Conjure's HUD. Exercise both during validation.

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
