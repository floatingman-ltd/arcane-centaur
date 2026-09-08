## 1. Vendor the indent script

- [ ] 1.1 Create `indent/` and add `indent/fsharp.vim`, copied verbatim from `ionide/Ionide-vim` at commit `094e7dbb8f77` (2026-04-07, "Rewrite indent function based on PhilT's vim-fsharp plugin"). 283 lines, MIT.
- [ ] 1.2 Add a provenance header **above** the existing attribution block, without disturbing it: upstream repository, vendored commit and date, the MIT licence, why it is vendored rather than installed (Ionide-vim also ships a competing LSP client, `fdm=syntax`, a regex syntax file and FSI keymaps — all duplicating working configuration), and how to refresh it. The existing maintainer list back to the original OCaml script stays intact.
- [ ] 1.3 Confirm nothing else competes for `indentexpr`: the treesitter indent guard in `lua/plugins/treesitter.lua` already excludes F# for want of an `indents.scm`, and `after/ftplugin/fsharp.lua` sets only `tabstop`/`shiftwidth`/`expandtab`/`spell`. Neither needs changing.
- [ ] 1.4 Confirm no plugin spec, `lazy.nvim` entry or `lazy-lock.json` line is added — the whole point of vendoring is that there is nothing to install.

## 1b. Comment and string awareness (the upstream deviation)

- [ ] 1.5 Add `lua/config/fsharp_indent.lua` exposing a cursor-position predicate that returns `1` for a comment or string, `0` for code, and `-1` when it cannot tell. Decide from treesitter **captures**, not node types: node types miss a `char` literal holding a brace, captures catch all six comment and string forms. Verified 7 of 7 against a fixture carrying each.
- [ ] 1.6 Do **not** force a parse in the predicate. It is called repeatedly by `searchpairpos()` from inside `indentexpr`, so a forced parse would land in the keystroke path. Rely on the live buffer's existing tree; no captures reads as `0`.
- [ ] 1.7 Rewrite `s:IsInCommentOrString()` in the vendored file to call the Lua predicate and fall through to upstream's `synID` path on `-1`. Behaviour must never be worse than upstream — with treesitter off, upstream's logic is what remains.
- [ ] 1.8 Mark the deviation clearly at the function, not only in the header: a comment saying this body differs from upstream, why (`synID` needs a `:syntax` file, F# here is treesitter-highlighted, so upstream's version always answered "no"), and that a refresh must re-apply it.
- [ ] 1.9 State in the provenance header that the file is **not** byte-identical to upstream and name the one function that differs. Without this a refresh silently reverts the fix, and silently — the reverted predicate returns a plausible answer rather than erroring.
- [ ] 1.10 Add a fixture covering `//` comments, `(* *)` block comments, plain, verbatim and triple-quoted strings, and a `char` literal, each holding a brace or bracket, plus real brace-delimited code as the control.
- [ ] 1.11 Raise an issue upstream on `ionide/Ionide-vim`: every user on treesitter highlighting rather than its bundled `syntax/fsharp.vim` has the same latent bug. Not a blocker for this change, but it is the route by which the divergence eventually ends.

## 2. Validation

- [ ] 2.1 Add a `## Change · add-fsharp-indent` section to `openspec/TEST_PLAN.md` with `Prepare` / `Validate` / `Raise PR & merge` / `Post-merge` subsections, following the structure of the existing sections.
- [ ] 2.2 Every indentation case must **press Enter and then type a character**. Vim strips autoindent from a line left empty, so `o` then `<Esc>` reports zero indent whatever the setting — the false negative that has now caught two changes (`align-treesitter-providers` AT.2 and `install-language-servers` LS.7).
- [ ] 2.3 Cover the cases that already work **by accident**, not only the broken ones. `if ... then` indents correctly today via `autoindent`, and a bad `indentexpr` would regress it silently — `indentexpr` overrides `autoindent` entirely, so a rule that answers badly is worse than no rule.
- [ ] 2.4 Include a case proving indentation is independent of the language server: run with `fsautocomplete` off `$PATH` and confirm indentation still works, mirroring `LS.8`'s crippled-`PATH` method.
- [ ] 2.5 Include a case for a standalone `.fsx`, where project options resolve unreliably. This is the condition that made `LS.5` fail, and indentation must be immune to it.
- [ ] 2.6 Include the "nothing else changed" cases: folds still structural from the LSP, format-on-save still runs, `tabstop`/`shiftwidth` still 4, comment leader unchanged. These are the easiest to skip because nothing is expected to happen.
- [ ] 2.7 Walk every validation step live in a real Neovim session and tick each box only once genuinely confirmed.

## 3. Documentation

- [ ] 3.1 `docs/modules/ROOT/pages/languages/dotnet.adoc` — replace the statement that F# has no indent support with what it now has, and note that indentation is editor-side and works without the server.
- [ ] 3.2 `docs/modules/ROOT/pages/editor/code-intelligence.adoc` — the note under the LSP table says F# "does not supply indentation: ... pressing Enter copies the previous line's indent ... That gap is tracked separately". Correct it, and keep the distinction that indentation comes from the editor rather than from `fsautocomplete`.
- [ ] 3.3 `docs/modules/ROOT/pages/languages/setup.adoc` — check the F# rows for the same claim and correct any occurrence.
- [ ] 3.4 `cheatsheets/fsharp.md` — the in-editor cheatsheet, a separate file from the Antora pages and easy to miss. Record the reindent operators now being usable.
- [ ] 3.5 Record that the file is vendored, where it came from, and that Ionide-vim is deliberately **not** installed — so nobody later "completes" the job by adding the plugin.
- [ ] 3.6 Search the docs tree for any remaining claim that F# indentation does not work: `grep -rniE 'indent' docs/ cheatsheets/ | grep -i fsharp`.
- [ ] 3.7 Build the docs site: `./docker/antora/run.sh antora-playbook.yml`.

## 4. Close out

- [ ] 4.1 Remove the F# indent entry from the priority queue in `recommendations/ideas.md` and record it as shipped, including what the investigation established: the indent file is separable and standalone, no treesitter `indents.scm` exists for F# upstream, and `WillEhrendreich/Ionide-nvim` was assessed and rejected.
- [ ] 4.2 After archiving, check the Purpose of `openspec/specs/fsharp-lsp/spec.md` by hand — it currently states that F# indentation remains unsupported, and `openspec archive` does not touch Purpose prose. The removed requirement will go; the Purpose paragraph will not.
- [ ] 4.3 After archiving, write the Purpose of the new `openspec/specs/fsharp-indent/spec.md` by hand. `openspec archive` leaves `TBD - created by archiving change …`, which is the gap that has accumulated 14 placeholder Purposes across this repository; do not make it 15.
