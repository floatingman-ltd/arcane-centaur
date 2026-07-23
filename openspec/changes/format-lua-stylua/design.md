## Context

`lua/plugins/conform.lua` sets `formatters_by_ft.lua = { "stylua" }` with format-on-save, and
Change 05 added `.stylua.toml` (`indent_type = "Spaces"`, `indent_width = 2`). But the committed Lua
predates stylua — `stylua --check` flags dozens of files. And format-on-save only runs on a **user
save in Neovim**; files written by Claude Code's Edit/Write tools bypass it entirely. So the tree
neither conforms today nor stays conformant on its own.

## Goals / Non-Goals

**Goals**
- Every committed Lua file conforms to `.stylua.toml` + stylua defaults (format-on-save becomes a
  no-op on unedited files).
- Edits that bypass save (Claude-tool writes, the feature skill) are kept stylua-clean.
- A single, mechanical, reviewable formatting commit that doesn't wreck `git blame`.

**Non-Goals**
- No logic changes; no stylua rule changes beyond the 2-space indent from Change 05.
- No formatting of non-Lua files; no CI/pre-commit tooling (deferred).

## Decisions

### Run now, not last (enforcement inverts the old logic)
The original proposal sequenced this "last" to avoid muddying in-flight diffs and merge conflicts.
That risk assumed concurrent Lua work — but 01–08 are merged, `document-setup-prerequisites` is
docs-only, and the remaining Lua changes (`migrate-treesitter-main`, `claude_cli` fix) are unstarted.
With nothing in flight, running now is safe; and because we add the `PostToolUse` hook in the same
change, doing it now makes every later change born-clean rather than deferring cleanliness to an
"end game." (Reformatting `treesitter.lua` now is moot — `migrate-treesitter-main` will replace it —
but harmless.)

### Enforce after normalizing (fills the save-only gap)
A one-shot format re-rots the moment a non-save edit lands. Enforcement:
- **`PostToolUse` hook** in `.claude/settings.json`: match `Edit|Write`, filter to paths ending
  `.lua`, and run `stylua` on the written file (wired via the `update-config` skill). It must degrade
  gracefully — if `stylua` is absent or errors on a mid-edit syntax slip, the hook warns but does not
  block the edit. This is the piece conform's save-hook can't cover for tool writes.
- **`add-neovim-feature` skill**: add a `stylua` step to its validation so the feature-authoring path
  formats too.
- **`pre-commit` (deferred):** a `stylua --check` git hook would cover human/CI edits, but the repo
  has no CI and the paths above cover real edits; revisit if CI lands.

### Protect `git blame`
A dozens-of-files whitespace commit would poison `git blame` on every reformatted line. Add
`.git-blame-ignore-revs` containing the reformat commit's SHA; GitHub auto-detects it, and locally
`git config blame.ignoreRevsFile .git-blame-ignore-revs` makes `git blame` skip it. Document the
local config step (it isn't automatic outside GitHub).

### Accept stylua's defaults (except indent)
Only `indent_type = Spaces` / `indent_width = 2` are pinned. Everything else — `column_width = 120`,
`AutoPreferDouble` quotes, `Always` call parens, trailing commas — uses stylua defaults. Minimal
config, predictable output, no bikeshedding.

### Verify semantics are unchanged
The reformat must be purely cosmetic: `luac -p` on every file and a clean Neovim start
(`:messages` empty) after the pass.

## Risks / Trade-offs

- **Large diff (dozens of files).** Mitigation: one isolated mechanical commit reviewers trust via
  `git show --stat` + the `luac -p` gate; `.git-blame-ignore-revs` keeps blame usable.
- **Hook plumbing.** The `PostToolUse` hook must extract the edited file path from the hook payload
  and no-op cleanly when `stylua` is missing — must never block an edit. Verify by editing a `.lua`
  via a Claude tool and confirming the file lands stylua-formatted.
- **Contributors without stylua.** conform already degrades gracefully (saves unformatted); the hook
  must do the same. Documenting stylua as a dependency (via `document-setup-prerequisites`) mitigates.

## Validation outline
1. `.stylua.toml` present (Change 05).
2. `stylua lua/ after/ init.lua` (+ any other Lua roots); `stylua --check .` → no diffs.
3. `find . -name '*.lua' -not -path './.git/*' -print0 | xargs -0 luac -p` → all pass.
4. Launch Neovim → `:messages` clean.
5. `git show --stat` → only whitespace/formatting.
6. **Enforcement:** edit a `.lua` via a Claude Edit/Write → confirm it is stylua-formatted afterward
   (hook fired); run the `add-neovim-feature` skill's stylua step.
7. **Blame:** `.git-blame-ignore-revs` contains the reformat SHA; `git blame --ignore-revs-file` skips it.
