## 1. Inventory the Git keymaps (source of truth)

- [x] 1.1 Extract every vim-fugitive keymap from `lua/plugins/git.lua` (and any `lua/keymaps.lua` git maps), cross-checking each `desc` against the current `editor/git.adoc` + `editor/git-cheatsheet.adoc` tables.
- [x] 1.2 Do the same for gitsigns (hunk nav/actions, text object) and for diffview (open/close/history), noting which maps are normal vs visual mode.
- [x] 1.3 List the in-`:Git`-window keys (`s`/`u`/`=`/`cc`/`q`, stash, navigation) that belong to the vim-fugitive page.

> **Inventory result.** All 20 config-bound Git keymaps live in `lua/plugins/git.lua`; `lua/keymaps.lua`
> has none. vim-fugitive 5 (`<leader>gs/gb/gl/gd/gp`), gitsigns 12 (`]h`, `[h`, `<leader>hs/hr/hS/hR/hu/hp/hb/hd/hD`,
> `<leader>ih`), diffview 3 (`<leader>gD/gH/gX`). The in-`:Git`-window keys are fugitive built-ins, not
> config-bound, and were harvested from `git-cheatsheet.adoc` (staging, commit, navigation, stash).
>
> **Defect found — conflicting docs.** `git.adoc` documented `q` as the close-status key while
> `git-cheatsheet.adoc` documented `gq`. Fugitive binds `gq`; there is no default `q` map. The
> per-plugin page keeps `gq` and drops `q`. This is exactly the guide-vs-cheatsheet drift the change exists
> to remove.
>
> **Branch was 23 commits stale.** Rebased onto `main` before authoring — main's `5ee02d1` fixes a
> column count in `git.adoc`, so migrating the pre-rebase copy would have reintroduced that bug.

## 2. Author the three plugin pages

- [x] 2.1 Create `docs/modules/ROOT/pages/editor/git/vim-fugitive.adoc` — BA-level description, then keymaps (global maps + in-status-window keys), then any setup note, then the in-editor-surfaces footer. Use this page as the tone/length yardstick (design D3, Open Question).
- [x] 2.2 Create `docs/modules/ROOT/pages/editor/git/gitsigns.adoc` following the same structure (hunk nav, hunk actions, text object).
- [x] 2.3 Create `docs/modules/ROOT/pages/editor/git/diffview.adoc` following the same structure (diff view, conflict resolution, file history).
- [x] 2.4 Verify against §1: every Git keymap appears on exactly one page and none is dropped.

> **Open Question resolved (design D3).** BA-blurb yardstick set by the vim-fugitive page: two short
> paragraphs — what the tool does in plain language, then when to reach for it versus the other two —
> plus a one-line pointer to each sibling page. Roughly 60–90 words. Jargon gets defined inline where
> it is unavoidable (gitsigns defines "hunk" before using it).
>
> **2.4 verified mechanically,** not by eye: each of the 20 config-bound keymaps was matched against the
> three pages; all appear on exactly one. Two findings during the check — an initial `[h` "miss" was the
> checker's own unescaped bracket expression (the page was fine), and `<leader>hs` genuinely appeared
> twice because diffview's conflict section restated it in prose; reworded to link to the gitsigns page
> without repeating the key.

## 3. Rewire nav and inbound links

- [x] 3.1 Update `docs/modules/ROOT/nav.adoc`: replace the two Git entries under Editor Core with a "Git" sub-label listing the three plugin pages (guide-before-cheatsheet ordering no longer applies).
- [x] 3.2 Grep `docs/` for inbound xrefs to `editor/git.adoc` and `editor/git-cheatsheet.adoc` (incl. `#anchor` targets — e.g. from `editor/keybindings.adoc`, `editor/navigation.adoc`) and repoint them to the new pages/anchors.

> **Three inbound xrefs found and repointed:** `nav.adoc` (the two Git entries → a `* Git` sub-label
> with three `**` children, matching the existing Lua pattern), `index.adoc:38` (area table → the
> vim-fugitive page), and `keybindings.adoc:25` (index row → all three pages). `navigation.adoc`,
> named speculatively in this task, turned out to have no Git xrefs.
>
> **Scope call — `keybindings.adoc` keymap table removed.** That page also carried a 20-row table
> duplicating every Git keymap. The `docs-plugin-page` spec requires a plugin's keymaps appear on
> exactly one page ("not duplicated on any other Antora page"), so the table was replaced with links
> to the three new pages. This does *not* retire `keybindings.adoc`, which design.md lists as a
> Non-Goal — the page and its other sections are untouched, and the follow-up rollout change still
> owns retiring it.

## 4. Remove the old pages

- [x] 4.1 Delete `docs/modules/ROOT/pages/editor/git.adoc` and `docs/modules/ROOT/pages/editor/git-cheatsheet.adoc`.
- [x] 4.2 Re-grep `docs/` to confirm no remaining reference to either deleted file.

## 5. Build and verify

- [x] 5.1 Rebuild the Antora site: `./docker/antora/run.sh antora-playbook.yml` — confirm no AsciiDoc/xref errors.
- [x] 5.2 Spot-check the rendered output: the three Git pages appear under Editor Core in the nav, each renders description-then-keymaps, and inbound links resolve.
- [x] 5.3 Confirm `openspec validate reorganize-per-plugin-docs` still passes.

> **Defect found — this change's own build command was the broken one.** Tasks 5.1 and proposal.md
> both specified `docker compose -f antora-playbook.yml run --rm antora antora-playbook.yml`, which
> feeds the Antora *playbook* to docker compose as a compose file and dies with
> `additional properties 'ui', 'content', 'site' not allowed`. Commit `a33cc7f` (2026-07-27) had already
> fixed this in all six live locations, but this change was authored 2026-07-24 and its artifacts were
> not among them. Both corrected to `./docker/antora/run.sh antora-playbook.yml`.
>
> **Clean build required to get a truthful result.** The first build appeared to leave `git.html` and
> `git-cheatsheet.html` in place — they were stale artifacts from a 10:33 build; Antora does not prune
> removed pages. After `rm -rf build/site`, the rebuild exits 0 with **zero errors and zero xref
> failures**, and both old pages are genuinely absent. The 5 remaining warnings are pre-existing
> missing-attribute references (`name`, `pat`, `feed`) in `code-intelligence.adoc`, `navigation.adoc`
> and `dotnet.adoc` — all files untouched by this change.
>
> **5.2 verified in the rendered HTML:** the Editor Core nav renders `Git` as a label with exactly three
> children (vim-fugitive, gitsigns, diffview) and no Guide/Cheatsheet entry; each page renders
> title → plain-language description → keymap tables; `index.html` and `editor/keybindings.html` both
> resolve to the three new pages; no link anywhere still targets the deleted pages.

## 6. Follow-up handoff

- [x] 6.1 Record the page template + nav pattern (from the vim-fugitive page) so the follow-up rollout change can copy it across the remaining areas and retire `editor/keybindings.adoc`.

### Page template (yardstick: `editor/git/vim-fugitive.adoc`)

```adoc
== <plugin canonical name>            <!-- `==`, not `=` — matches every existing page -->

<BA blurb: 2 short paragraphs, ~60-90 words. What it does in plain language,
then when to reach for it vs. its siblings, with an xref to each sibling page.
Define any unavoidable jargon inline — gitsigns defines "hunk" before using it.>

=== Keymaps
[cols="1,1,2",options="header"]     <!-- Keys | Mode | Action; drop Mode if uniform -->

=== <extra sections as the plugin warrants>
<in-window keys, worked example, conflict flow — after the keymaps, never before>

=== Setup
<only if there is one; "None." is a valid and useful answer>

'''''
_In the editor, which-key shows these maps live as you type a prefix (built from each keymap's
`desc`), and `++<++leader++>++?` opens the context-aware cheatsheet. Those are the authoritative
live view. Plugin configured in `lua/plugins/<file>.lua`._
```

Notation: keys use the pandoc-converted house style — `++<++leader++>++x`, `++]++h`, `++[++h`,
`++<++CR++>++` (226 occurrences across the tree; do not introduce `kbd:`).

### Nav pattern (`nav.adoc`)

```adoc
.<Area group>
* <Sub-area label>              <!-- bare text, no xref — renders as a nav-text label -->
** xref:<area>/<sub>/<plugin>.adoc[<plugin>]
```

This mirrors the pre-existing `* Lua` / `** xref:...[Guide]` nesting, so it needs no UI change.

### For the follow-up rollout

- De-duplicate as you migrate: the `docs-plugin-page` spec requires each plugin's keymaps on exactly
  one page, so every area you migrate must also have its rows removed from `editor/keybindings.adoc`.
  Once the last area is migrated that page holds only links and can finally be retired.
- Verify coverage mechanically, not by eye — extract the bound keymaps from `lua/plugins/<file>.lua`
  and assert a one-page hit count for each. Escape `[`/`]` or use `grep -F`; an unescaped `[h`
  silently reads as a bracket expression and reports a false miss.
- Always `rm -rf build/site` before the verification build; Antora leaves stale HTML for removed pages
  and it will look like your deletion did not take.
