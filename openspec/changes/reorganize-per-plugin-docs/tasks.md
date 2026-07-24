## 1. Inventory the Git keymaps (source of truth)

- [ ] 1.1 Extract every vim-fugitive keymap from `lua/plugins/git.lua` (and any `lua/keymaps.lua` git maps), cross-checking each `desc` against the current `editor/git.adoc` + `editor/git-cheatsheet.adoc` tables.
- [ ] 1.2 Do the same for gitsigns (hunk nav/actions, text object) and for diffview (open/close/history), noting which maps are normal vs visual mode.
- [ ] 1.3 List the in-`:Git`-window keys (`s`/`u`/`=`/`cc`/`q`, stash, navigation) that belong to the vim-fugitive page.

## 2. Author the three plugin pages

- [ ] 2.1 Create `docs/modules/ROOT/pages/editor/git/vim-fugitive.adoc` — BA-level description, then keymaps (global maps + in-status-window keys), then any setup note, then the in-editor-surfaces footer. Use this page as the tone/length yardstick (design D3, Open Question).
- [ ] 2.2 Create `docs/modules/ROOT/pages/editor/git/gitsigns.adoc` following the same structure (hunk nav, hunk actions, text object).
- [ ] 2.3 Create `docs/modules/ROOT/pages/editor/git/diffview.adoc` following the same structure (diff view, conflict resolution, file history).
- [ ] 2.4 Verify against §1: every Git keymap appears on exactly one page and none is dropped.

## 3. Rewire nav and inbound links

- [ ] 3.1 Update `docs/modules/ROOT/nav.adoc`: replace the two Git entries under Editor Core with a "Git" sub-label listing the three plugin pages (guide-before-cheatsheet ordering no longer applies).
- [ ] 3.2 Grep `docs/` for inbound xrefs to `editor/git.adoc` and `editor/git-cheatsheet.adoc` (incl. `#anchor` targets — e.g. from `editor/keybindings.adoc`, `editor/navigation.adoc`) and repoint them to the new pages/anchors.

## 4. Remove the old pages

- [ ] 4.1 Delete `docs/modules/ROOT/pages/editor/git.adoc` and `docs/modules/ROOT/pages/editor/git-cheatsheet.adoc`.
- [ ] 4.2 Re-grep `docs/` to confirm no remaining reference to either deleted file.

## 5. Build and verify

- [ ] 5.1 Rebuild the Antora site: `docker compose -f antora-playbook.yml run --rm antora antora-playbook.yml` — confirm no AsciiDoc/xref errors.
- [ ] 5.2 Spot-check the rendered output: the three Git pages appear under Editor Core in the nav, each renders description-then-keymaps, and inbound links resolve.
- [ ] 5.3 Confirm `openspec validate reorganize-per-plugin-docs` still passes.

## 6. Follow-up handoff

- [ ] 6.1 Record the page template + nav pattern (from the vim-fugitive page) so the follow-up rollout change can copy it across the remaining areas and retire `editor/keybindings.adoc`.
