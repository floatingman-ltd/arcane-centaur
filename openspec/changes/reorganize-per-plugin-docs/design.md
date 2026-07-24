## Context

Keymap documentation lives on three surfaces that can drift:

1. **which-key.nvim** (`lua/plugins/which-key.lua`) — builds live popups at runtime from each keymap's `desc`. Always accurate; no maintenance.
2. **`<leader>?` context-aware cheatsheet** (`lua/config/cheatsheet.lua`) — reads hand-maintained `cheatsheets/core.md` + per-filetype `cheatsheets/{fsharp,haskell,janet,lisp,markdown}.md` (config root). In-editor reference.
3. **Antora web docs** (`docs/modules/ROOT/pages/`) — per-area guide+cheatsheet pairs, plus a 518-line `editor/keybindings.adoc` that is **orphaned from `nav.adoc`** and duplicates keymap tables already in the per-area cheatsheets.

The Antora surface is the problem: keymaps for one plugin can appear in the area guide, the area cheatsheet, and the orphaned keybindings page. There is no single "what is plugin X and what are its keys?" page. The Git area is a clean exemplar of the coupling: `editor/git.adoc` (workflow guide) + `editor/git-cheatsheet.adoc` both document three distinct plugins (vim-fugitive, gitsigns, diffview) interleaved.

## Goals / Non-Goals

**Goals:**
- Define a reusable **per-plugin page model**: one Antora page per plugin, opening with a BA-level (plain-language) description, then that plugin's keymaps.
- Prove the model end-to-end on the **Git area only**, producing a copy-able template for the follow-up rollout.
- Keep the Antora build green (valid AsciiDoc, resolvable xrefs, updated nav).

**Non-Goals:**
- Migrating any area other than Git (deferred to the follow-up rollout change).
- Retiring the orphaned `editor/keybindings.adoc` (deferred — it is not a Git-area page).
- Any `lua/` runtime change: which-key and the `<leader>?` cheatsheet are untouched.
- Reconciling `cheatsheets/*.md` content against the web docs (deferred).
- The blink cmdline accept-key alignment (a separate, non-Git concern; stays docs-only if/when addressed).

## Decisions

**D1 — One page per plugin, not per workflow group.** vim-fugitive, gitsigns, and diffview each get their own page, even though they form one git workflow.
- _Why:_ Matches the stated model ("a page for each plugin/extension") and gives each tool a stable, linkable home. A reader asking "what does gitsigns do?" lands on exactly that.
- _Alternative rejected:_ a single grouped "Git" page (fewer pages) — but that reproduces today's interleaving, the exact problem being removed.

**D2 — Page path: area subdirectory, one file per plugin.** New pages at `docs/modules/ROOT/pages/editor/git/{vim-fugitive,gitsigns,diffview}.adoc`.
- _Why:_ Preserves the existing area grouping (`editor/`) while scaling to many plugins without flat-namespace collisions; the URL path (`editor/git/gitsigns`) reads naturally.
- _Alternative rejected:_ flat prefixed files (`editor/git-gitsigns.adoc`) — noisier as areas grow.

**D3 — Page structure.** Each plugin page: (1) title = the plugin's canonical name; (2) a short **BA-level description** — what problem it solves and what you get, in plain language, no jargon; (3) keymap table(s) grouped by task where useful; (4) an optional short Setup/Prerequisites note only if the plugin needs one; (5) a one-line footer noting the in-editor equivalents (which-key live popups; `<leader>?`).
- _Why:_ The BA blurb makes each page approachable to a newcomer; keymaps-with-context replace the split guide/cheatsheet.

**D4 — Retire the old Git pages.** After migration, delete `editor/git.adoc` and `editor/git-cheatsheet.adoc`; update every inbound xref (notably from the orphaned `keybindings.adoc` and `navigation.adoc`) to point at the new pages.

**D5 — nav.adoc pattern.** Under **Editor Core**, replace the two Git entries with a "Git" sub-label listing the three plugin pages. This becomes the nav template the follow-up change copies.

## Risks / Trade-offs

- **Page proliferation** → For the pilot this is only +3/−2 pages; the follow-up change will weigh grouping vs. count area-by-area. The model explicitly favors granularity.
- **Broken xrefs after deleting the old pages** → Grep the whole `docs/` tree for `git.adoc`/`git-cheatsheet.adoc` xrefs and the `#anchors` within them before deletion; fix all, then rebuild Antora to confirm zero xref errors.
- **Divergence from the untouched surfaces** → The plugin pages, `cheatsheets/*.md`, and which-key `desc`s can still drift. Mitigation for now: each page footer points readers to which-key/`<leader>?` as the authoritative live view; full three-surface reconciliation is a named follow-up.
- **Naming collision with the `git-diff-view` runtime capability** → That is a `lua/` capability spec, unrelated to this docs capability; no overlap in scope.

## Migration Plan

1. Author the three Git plugin pages from the content of `git.adoc` + `git-cheatsheet.adoc` (no keymap left behind; verify against the live specs/`desc`s).
2. Update `nav.adoc` Git entries.
3. Repoint inbound xrefs; delete the two old pages.
4. Rebuild the Antora site; confirm no AsciiDoc/xref errors and the three pages render with working nav.
5. Rollback = restore the two deleted files and revert the nav/xref edits (single-commit revert on the branch).

## Open Questions

- Exact BA-blurb length/tone — settle by writing the vim-fugitive page first and using it as the yardstick for the other two.
