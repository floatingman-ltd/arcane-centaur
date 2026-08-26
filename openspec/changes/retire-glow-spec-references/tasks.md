## 1. Write the deltas

- [x] 1.1 Delta for `asciidoc-inbuffer-preview`, modifying *In-buffer preview coexists with the Docker preview and the Markdown workflow*. Copy the whole requirement including both scenarios — MODIFIED replaces the requirement wholesale, so partial content silently loses the rest at archive time.
- [x] 1.2 In that requirement's *Markdown workflow untouched* scenario, replace the `glow.nvim` reference with the current surfaces: `markdown-preview.nvim` in a GUI, `:MarkdownPopup` in a console, and `<localleader>pp` toggling in-buffer rendering.
- [x] 1.3 In the same scenario, replace "exactly as before this change" with the behaviour itself (design D2). Once the introducing change is archived that phrase has no referent and cannot be evaluated.
- [x] 1.4 Delta for `ide-layout`, modifying *Floating UIs unaffected*: replace "Glow previews" with the Markdown preview popup in both the requirement text and its scenario trigger (design D1).
- [x] 1.5 Do **not** touch `openspec/specs/code-folding/spec.md`. Its glow mention was rewritten by `align-treesitter-providers` into deliberate history and is correct.
- [x] 1.6 Do **not** edit the live specs directly — the whole point of this change is that promoted specs are updated through deltas.

## 2. Verify

- [x] 2.1 `openspec validate retire-glow-spec-references --strict`
- [x] 2.2 `openspec validate --all --strict`
- [x] 2.3 `grep -rn -i glow openspec/specs/` — the only remaining hit must be the deliberate history in `code-folding`. Anything else is a spec this change missed.

> The grep found more than the two known specs, which is the step working:
> * `markdown-popup-preview`'s **Purpose** still promised "ensure `glow.nvim` loads in all environments" — a requirement `replace-glow-renderer` had *removed* — and still called `,pp` a forced popup when it is now a render toggle. Corrected directly; Purpose prose cannot be reached by a delta.
> * `markdown-native-rendering` carries a literal `TBD - ... Update Purpose after archive.` stub. **Not a glow reference** — grep only matched the change name inside the placeholder. Deliberately left: fourteen specs are in that state going back to changes 01–08, so fixing this one alone would make it the odd exception rather than progress. Logged in `recommendations/ideas.md` as its own pass.
> * `markdown-native-rendering`'s requirement text names the `glow` binary intentionally, defining that rendering works without it. Left as-is.
- [x] 2.4 Confirm no runtime file is touched: `git diff --stat` should show only `openspec/` and `recommendations/`.

## 3. Close the loop

- [x] 3.1 Remove the "three capability specs still reference `glow.nvim`" entry from `recommendations/ideas.md`, and its line from the priority queue. Note in the commit that the scope was two specs, not three — `code-folding` had already been resolved by `align-treesitter-providers`.
- [x] 3.2 Renumber the remaining priority-queue entries so the ordering stays contiguous.

## 4. Ship

- [x] 4.1 Push the branch and raise the PR. **No `TEST_PLAN.md` section and no live validation walk**: this changes spec text only, touches no runtime file, and CLAUDE.md's manual-verification requirement is scoped to changes that touch runtime behaviour. Say so in the PR body so the omission reads as deliberate rather than skipped.
- [ ] 4.2 After merge: archive, and confirm both deltas promote cleanly. Commit before archiving — the archive is not atomic and has partial-written specs before aborting on two occasions.
- [x] 4.3 Watch for the rename trap at archive time: neither delta renames a requirement, so `## RENAMED Requirements` should not be needed — but a MODIFIED header that does not match the live spec exactly will abort with "not found".

> Checked before archiving rather than discovering it mid-abort: both MODIFIED headers were compared
> against the live specs and match exactly. No `RENAMED` section needed.
