## Why

Two related navigation gaps:

- **No persistent diagnostics view.** Diagnostics are surfaced only via `<leader>e` (floating window for the line) and `[d`/`]d` (jump). There is no project-wide or buffer-wide list, no quickfix/loclist viewer, and no LSP references/symbols panel. For multi-file C# solutions and Haskell projects, a standing error list (no build required) is valuable. → `folke/trouble.nvim` (v3).
- **No comment-annotation visibility.** `TODO`/`FIXME`/`HACK`/`NOTE`/`WARN` comments are not highlighted and cannot be listed project-wide. Across Lua, Lisp, F#, Haskell, and AsciiDoc in one repo, project-wide TODO navigation is a practical time-saver. → `folke/todo-comments.nvim`.

These two are grouped because they integrate: todo-comments exposes a `:TodoTrouble` view through trouble, and both feed the existing fzf-lua picker model rather than replacing it.

Cross-validation of the *actual* config shaped two decisions:

1. **`]t` / `[t` are taken by vim-unimpaired** (`:tnext` / `:tprev`, tag navigation). vim-unimpaired is a KEEP in the best-of-breed evaluation, so todo-comments MUST NOT grab its conventional `]t`/`[t` jump maps. Todos are driven through the list/`<leader>x` instead.
2. **`<leader>x` is free** in `lua/keymaps.lua` — the natural home for trouble (its upstream default prefix), with no collision.

## What Changes

- **Add** `folke/trouble.nvim` (v3, pinned) in a new `lua/plugins/trouble.lua`, with `<leader>x` keymaps for diagnostics (buffer + project), symbols, LSP references, quickfix, and loclist.
- **Add** `folke/todo-comments.nvim` in a new `lua/plugins/todo-comments.lua`, highlighting annotation keywords and exposing project-wide listing via `:TodoFzfLua` (fzf-lua) and `:TodoTrouble` (trouble), with a `<leader>xt` map. **No `]t`/`[t` maps** (reserved for vim-unimpaired).
- **Keep** native `[d`/`]d` diagnostic jumps and the `<leader>e` float exactly as they are — trouble is an additional panel, not a replacement for the jump motions.
- **Register** a `<leader>x` "Trouble" which-key group.

## Capabilities

### New Capabilities

- `diagnostics-panel`: a persistent, filterable diagnostics / quickfix / loclist / LSP-references / symbols panel via trouble.nvim, opened from the `<leader>x` group, complementing the existing `[d`/`]d` jumps and the fzf-lua pickers.
- `todo-comments`: highlighting of `TODO`/`FIXME`/`HACK`/`NOTE`/`WARN`/`PERF` annotations across all buffers, with project-wide listing through fzf-lua and trouble, and no collision with vim-unimpaired's `]t`/`[t`.

### Modified Capabilities

<!-- none — diagnostics navigation lives only in lua/config/lsp.lua's on_attach maps, which are preserved verbatim; no prior OpenSpec requirement covered a diagnostics panel or todo highlighting -->

## Impact

- **`lua/plugins/trouble.lua`** → new.
- **`lua/plugins/todo-comments.lua`** → new.
- **`lua/plugins/which-key.lua`** → register `{ "<leader>x", group = "Trouble" }`.
- **`lua/config/lsp.lua`** → **untouched** (native `[d`/`]d`, `<leader>e` preserved). No collision with the `migrate-completion-blink` capabilities rewrite.
- **vim-unimpaired** → unaffected; `]t`/`[t` remain its tag-navigation maps.
- **plenary.nvim**: todo-comments may still depend on it (upstream is dropping it during 2026); already present (retained by `upgrade-avante-drop-dressing`). Declared/relied-on as available.
- **Independence**: decoupled from the AsciiDoc / dotnet-debug / textobjects / claudecode changes (different files). trouble pairs naturally with the dotnet-debug change once it lands, but does not depend on it.

## Prerequisites and sequencing

**Sequence position:** 06 of 08 — Wave B (establishes the `<leader>x` which-key group; precedes 07-add-dotnet-debug-test).

- **Hard prerequisites:** none for the plugins themselves. `:TodoTrouble` requires trouble.nvim, which is installed within *this same change* — so there is no external prerequisite.
- **Shared file — `lua/plugins/which-key.lua`:** also edited by `add-dotnet-debug-test` (which adds a `<leader>b` "Debug" group). This change adds a `<leader>x` "Trouble" group to the single `wk.add({ ... })` call. **Sequencing rule:** whichever of the two changes is implemented **second** MUST append its group entry to the existing `wk.add` list, not replace the call. Recommended: implement **this change first** (establishes the `<leader>x` entry), then `add-dotnet-debug-test` appends `<leader>b`.
- **Implementation wave: B** (after Wave A; pairs naturally with `add-dotnet-debug-test` but does not depend on it).

## Out of scope

- Remapping `[d`/`]d` or `<leader>e` to trouble equivalents — native diagnostics navigation is preserved.
- Using trouble as the quickfix list *replacement* globally (`opts.quickfix` takeover) — trouble is opened explicitly via `<leader>x`, not forced.
- Bracket-style todo jumps (`]t`/`[t`) — reserved for vim-unimpaired; todos use the list views.
