## Why

Keymap documentation is spread across three unsynchronized surfaces and drifts: which-key generates live popups from each map's `desc` (always accurate), the `<leader>?` cheatsheet reads `cheatsheets/*.md`, and the Antora web docs carry per-area guide+cheatsheet pairs plus a 518-line `editor/keybindings.adoc` that is **orphaned from nav** and **duplicates** keymap tables already living in the per-area cheatsheets. A reader cannot answer "what does plugin X give me, and what are its keys?" from one place. Co-locating each plugin's description and keymaps on its own page removes the duplication and gives every tool a single, obvious home.

## What Changes

- Establish a **per-plugin documentation page model**: one Antora page per plugin/extension, opening with a brief **BA-level** (plain-language "what & why") description, followed by that plugin's keymaps. This replaces the per-area guide+cheatsheet split for migrated areas.
- **Pilot the model on the Git area only** as the reference template: split the current `editor/git.adoc` + `editor/git-cheatsheet.adoc` into three plugin pages — **vim-fugitive**, **gitsigns**, **diffview** — each self-contained (BA blurb + keymaps + any tool-specific setup note).
- Update `nav.adoc` so the Git entries under **Editor Core** point at the three per-plugin pages instead of a guide+cheatsheet pair.
- Remove the now-redundant `editor/git.adoc` and `editor/git-cheatsheet.adoc` once their content is migrated (redirects/xrefs updated).
- **Docs-only** — no `lua/` runtime changes. which-key (auto) and the `<leader>?` cheatsheet (`cheatsheets/*.md`) are unchanged; each plugin page notes them as the in-editor equivalents.
- A **follow-up change** rolls this pattern across the remaining areas (editor, AI, content, languages, tooling) and retires the orphaned `editor/keybindings.adoc`; that is explicitly out of scope here.

## Capabilities

### New Capabilities
- `docs-plugin-page`: A documentation page model where each plugin/extension gets its own Antora page that opens with a BA-level description and then documents that plugin's keymaps, with the Git area (vim-fugitive, gitsigns, diffview) as the reference instantiation.

### Modified Capabilities
- `docs-nav-structure`: The Editor Core group's Git entries change from a co-located guide+cheatsheet pair to per-plugin pages (vim-fugitive, gitsigns, diffview); the existing "Git group contains both guide and cheatsheet" requirement is replaced for migrated areas.

## Impact

- **Files:** new `docs/modules/ROOT/pages/editor/git/{vim-fugitive,gitsigns,diffview}.adoc` (or equivalent per-plugin paths); `docs/modules/ROOT/nav.adoc` (Git entries); remove `docs/modules/ROOT/pages/editor/git.adoc` and `editor/git-cheatsheet.adoc` after migration.
- **Docs only** — no `lua/`, keymap, or plugin-config changes; no runtime behavior touched, so the manual TEST_PLAN live-session requirement does not apply (validation is an Antora build + xref/nav spot-check).
- **`docs-guide-template`** is unaffected for the pilot — the remaining per-area guides still follow it. The plugin-page model is a distinct page type introduced by `docs-plugin-page`; reconciling the two templates repo-wide is deferred to the follow-up rollout change.
- The Antora build (`docker compose -f antora-playbook.yml run --rm antora antora-playbook.yml`) must still succeed with valid AsciiDoc and resolvable xrefs.
