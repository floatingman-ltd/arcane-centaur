## Context

F# indentation has never worked in this configuration. `install-language-servers` established the shape of the gap under `LS.7`: `indentexpr` is empty for F#, so `autoindent` copies the previous line's indent and nothing indents a function body.

What makes this gap unusual is that every other mechanism is genuinely unavailable rather than merely unconfigured:

- **Treesitter** cannot help. nvim-treesitter ships no `indents.scm` for F# — there is no `queries/fsharp` directory at all, confirmed 404 on both `main` and `master`. The guard at `lua/plugins/treesitter.lua` already excludes F# for exactly this reason, which is why `indentexpr` is empty rather than a treesitter expression answering zero.
- **LSP** cannot help. `fsautocomplete` supplies folds and formatting, both validated, but LSP has no indent-as-you-type concept. Format-on-save fixes indentation *after* the fact and only where project options resolve.
- **`smartindent`** cannot help. It keys off `{`, `}` and `cinwords`; F# uses none of them.

That leaves a hand-written `indentexpr`, and one maintained implementation exists.

## Goals / Non-Goals

**Goals:**

- Pressing Enter after `=`, `->`, `then`, `else` and similar indents the body rather than copying the previous indent.
- Indentation works with no language server running, and in a `.fsx` script where project options do not resolve.
- No second LSP client, no change to folding, formatting, comments or REPL keymaps.
- Reversible by deleting one file.

**Non-Goals:**

- Installing `ionide/Ionide-vim`. See D2.
- Reindent operators (`=`, `>>`, `<<`) becoming *good*. They stop being useless because `indentexpr` exists, but this change does not promise idiomatic whole-file reindentation — Fantomas via format-on-save is the tool for that.
- Contributing improvements upstream. Worth doing if defects are found, but not part of this change.
- Touching `after/ftplugin/fsharp.lua`, `lua/plugins/conform.lua`, `lua/plugins/ufo.lua` or `lua/config/lsp.lua`.

## Decisions

### D1 — Vendor the file rather than depend on the plugin

`indent/fsharp.vim` is 283 lines and self-contained: no references to `fsharp#`, `ionide` or `g:fsharp`, guarded on `b:did_indent`, setting only `indentexpr` and `indentkeys`. It has no dependency on the rest of Ionide-vim, which is what makes vendoring possible rather than a hack.

Placed at `indent/fsharp.vim`, Neovim's runtime sources it on `FileType` whenever `filetype indent` is on — which it is here. The configuration directory is first on the runtimepath and Neovim ships no F# indent file, so nothing competes and the `b:did_indent` guard makes it idempotent.

Verified by mechanism, not assumption: dropping the file onto a prepended runtimepath moved `indentexpr` from empty to `FSharpIndent()` and took the case results from 2 of 5 to 5 of 5.

Being pure Vimscript with no Neovim API calls, it is also immune to the 0.12 API drift that has repeatedly bitten plugins here — a relevant consideration given Ionide-vim itself claims only Neovim 0.11.3+.

### D2 — Do not install Ionide-vim

The plugin would not add capabilities; it would arrive with duplicates of things already working, three of which override validated behaviour:

| Ionide-vim ships | Already served here | Consequence |
|---|---|---|
| `vim.lsp.enable('ionide')` | `vim.lsp.enable("fsautocomplete")` (`lua/config/lsp.lua:50`) | A **second** FsAutoComplete client on the same buffers |
| `setl fdm=syntax` in its ftplugin | ufo `{ "lsp", "indent" }` (`lua/plugins/ufo.lua:59`) | Would **replace** the LSP folds validated at `LS.6` with regex folds |
| `syntax/fsharp.vim` (regex) | nvim-treesitter `fsharp` parser | Strictly worse highlighting |
| `commentstring=(*%s*)` | native `gc` with `//` | Changes comment behaviour |
| FSI keymaps via `g:fsharp#fsi_keymap` | iron.nvim → `dotnet fsi` (`lua/plugins/dotnet.lua:26`) | Keymap collision on the same `dotnet fsi` |
| — | easy-dotnet test/run/build, netcoredbg DAP | Ionide offers neither |

All of it is disableable — `g:fsharp#lsp_auto_setup = 0`, `g:fsharp#fsi_keymap = "none"`, re-setting `foldmethod` after its ftplugin — but that is four things to switch off in order to obtain one file that has no dependency on any of them.

Its maintenance profile does not argue for the dependency either. 211 stars and 41 contributors, but the top two account for roughly 70% of commits; commits per year run 48, 11, 20, 9, 7, 18, 12, 6 from 2019 to 2026 — maintained, not developed; and the **last tagged release was 2019-11-25**, so depending on it means tracking `master` regardless. Its open issues are `nvim freezes in certain large projects` (2026-06), `random stops when the cursor passes certain identifiers` (2025-12), `codelenses flash on every keystroke`, and `error shown on every keystroke when file is not included in project` — all in the LSP integration this change would switch off.

### D3 — Reject `WillEhrendreich/Ionide-nvim`

A self-described "now disconnected fork" of Ionide-vim: 17 stars, three contributors of whom one is Copilot and one has a single commit, and an 87 KB single `lua/ionide/init.lua`. It is more recently active and does carry a real test suite, which Ionide-vim lacks — but it is a one-person fork of the thing we already decided not to depend on, and it does not ship anything the vendored file does not.

### D4 — A new capability, not an addition to `fsharp-lsp`

`fsharp-indent` stands on its own because indentation is not a language-server concern. The vendored script has no dependency on `fsautocomplete` and must keep working when the server is absent, still starting, or unable to resolve project options for a `.fsx` — the condition that made `LS.5` fail. Folding it into `fsharp-lsp` would imply a coupling that does not exist and that the tests should actively disprove.

`fsharp-lsp`'s `F# indentation remains unsupported` requirement is removed rather than modified. It was written to stop the gap being misread as a regression and explicitly anticipated retirement by a dedicated change; keeping a hollowed-out version would be worse than pointing at the capability that now covers it.

### D5 — Keep the attribution header, and add provenance

The file carries a maintainer list going back to the original OCaml indent script — Yuen, Leary, Mottl, Grinberg, Kongo2002, Thompson, Pottle. That stays untouched; it is both an MIT courtesy and a useful record.

Added above it: the upstream repository, the exact commit vendored (`094e7dbb8f77`, 2026-04-07), why it is vendored rather than installed, how to refresh it, and — because of D6 — **that the file is not byte-identical to upstream and exactly which function differs**. Without the first part the next reader sees an unexplained 283-line Vimscript file and cannot tell whether it is homegrown, safe to edit or safe to delete; without the deviation called out, the first refresh silently reverts the fix.

### D6 — Fix the comment/string predicate, in Lua, as a declared deviation

Upstream's `s:IsInCommentOrString()` reads `synIDattr(synID(...), "name")` and matches `comment\|string`. That needs Vim `:syntax` highlighting. Measured in this configuration:

```
b:current_syntax = nil          treesitter highlight active = true
synID() on a comment line = 0   name=[]
  -> IsInCommentOrString() returns false
```

It is not a subtle degradation. The function is passed as the skip predicate to `searchpairpos()`, so brace, bracket and paren matching currently cannot skip commented-out or quoted delimiters. A `{` inside a comment is treated as a real opening brace when computing the indent of a closing one. Upstream does not hit this because Ionide-vim ships its own `syntax/fsharp.vim`; we are vendoring the file into an environment its author did not assume.

The replacement asks treesitter for the **captures** at the cursor, not the node type. Node types would miss a case — measured:

|Construct |node type |captures |
|---|---|---|
|`// line` |`line_comment` |`comment` |
|`(* block *)` |`block_comment_content` |`comment` |
|a plain string literal |`string` |`string` |
|a verbatim `@"..."` literal |`verbatim_string` |`string` |
|a triple-quoted literal |`triple_quoted_string` |`string` |
|a `char` literal holding a brace |`char` |**`string`** |
|real code |`brace_expression` |`punctuation.bracket` |

Matching node types on `comment`/`string` catches five of six and misses the `char` literal. Captures catch all six and cleanly exclude real code. Verified 7 of 7 against a fixture carrying every construct.

**It returns three values, not two.** `1` comment-or-string, `0` no, `-1` undecidable — and `-1` makes the caller fall through to upstream's `synID` path. That matters because the predicate must not become *worse* than upstream anywhere: if treesitter highlighting is off, or the F# parser is missing, the original behaviour is what remains.

**Deliberately not forcing a parse.** The predicate runs inside `searchpairpos()`, which calls it repeatedly, inside `indentexpr`, which runs on keystrokes. A live buffer's tree is already current; forcing `parser:parse()` here would put a full parse in the keystroke path. An unparsed tree yields no captures, which reads as `0` and is the safe answer.

The Lua lives in `lua/config/fsharp_indent.lua` rather than inline `luaeval`, so it is greppable, annotated and testable — and so the deviation sits where this configuration's logic normally sits. The indent algorithm stays Vimscript, which keeps D1's upstream diff path intact for the 200 lines that matter.

Alternatives considered. Leaving it broken was tempting on "vendor verbatim" grounds, but shipping a knowingly inert function to preserve a clean diff is the wrong trade when the diff is one function long. Porting the whole file to Lua to fix it is disproportionate, and is logged in `recommendations/ideas.md` as an idea rather than a plan. Patching upstream first would block this change on someone else's review cycle — though the issue is worth raising regardless, since every Ionide-vim user on treesitter highlighting has the same latent bug.

## Risks / Trade-offs

**Upstream fixes arrive only when pulled by hand** → the accepted cost of D1. Mitigated by recording the exact upstream commit in the header so a refresh is a diff rather than an investigation. The file has changed three times since 2016 (2016-11, 2023-07, 2026-04), so the expected cadence is roughly one pull every few years.

**Local edits and an upstream refresh will conflict** → no longer hypothetical: D6 makes one function differ from upstream on day one. A careless refresh reverts it and the failure is silent, because the reverted predicate returns a plausible answer rather than erroring. Mitigated by naming the deviation in the header, by a validation case asserting that pair matching ignores commented delimiters, and by raising the issue upstream so the divergence can eventually end.

**Indentation is felt on every keystroke** → unlike folding or formatting, a bad indent rule is immediately and continuously annoying, and `indentexpr` overrides `autoindent` entirely, so a rule that answers badly is worse than no rule at all. This is the reason the test plan covers the cases that currently work by accident as well as the ones that are broken: `if ... then` already indents correctly today, and must not regress.

**The file inherits an OCaml lineage** → it descends from an OCaml indent script ported to F# in 2014. F# and OCaml diverge, and the April 2026 rewrite was itself motivated by a misindent bug (`#76`, closing brace, open since 2023). Some rough edges are likely; the mitigation is that they are now discoverable and fixable in-tree rather than absent.

## Migration Plan

1. Add `indent/fsharp.vim` with the provenance header.
2. Verify `indentexpr` becomes `FSharpIndent()` in an F# buffer and walk the test plan.
3. Update the F# documentation, which currently states indentation does not work.

Rollback is deleting the file: `indentexpr` returns to empty and behaviour reverts to `autoindent` exactly as before. No state, no dependency, no generated artefact.

## Open Questions

None blocking. Whether to upstream any local fixes is a decision for the first time one is needed.
