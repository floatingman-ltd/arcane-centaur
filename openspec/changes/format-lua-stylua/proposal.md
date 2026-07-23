## Why

`conform.nvim` runs `stylua` as the Lua formatter on save (`lua = { "stylua" }` in
`lua/plugins/conform.lua`), and Change 05 added a `.stylua.toml` pinning the repo's 2-space style —
but the committed Lua was **never normalized**, so `stylua --check` flags **dozens** of files
(the proposal originally measured ~29 in `lua/`; tree-wide it is most of the 61 Lua files). Two gaps:

1. **The tree doesn't conform.** Editing any Lua file yields a large, noisy diff — stylua rewraps and
   retrailing-commas unrelated lines mixed in with the real change.
2. **Nothing keeps it clean once normalized.** `conform`'s format-on-save only fires on a **user save
   inside Neovim**. Files written by **Claude Code's Edit/Write tools** (and other editors / scripts)
   are *not* formatted — so a one-shot normalization would re-rot on the first tool edit.

This change finishes the job **and** makes it stick: normalize the whole tree once, then enforce the
style on edits that bypass save.

## What Changes

- **Normalize** — run `stylua` over all Lua (`lua/`, `after/`, `init.lua`, any `plugin/`/`ftplugin/`
  Lua) so every file matches `.stylua.toml` + stylua defaults. Formatting only — **no behaviour
  change**.
- **Enforce (folded in)** — keep the tree clean after the one-shot:
  - a **`PostToolUse` hook** in `.claude/settings.json` that runs `stylua` on `.lua` files after
    `Edit`/`Write` (covers the gap that format-on-save leaves for Claude-tool edits);
  - a **`stylua` step** in the `add-neovim-feature` skill's validation.
- **Protect `git blame`** — add a `.git-blame-ignore-revs` file listing the reformat commit, and
  document `git config blame.ignoreRevsFile .git-blame-ignore-revs` (GitHub honors the file
  automatically) so the mechanical reformat doesn't pollute line history.

## Capabilities

### Modified Capabilities

- `lua-formatting`: the repo ships `.stylua.toml` (2-space) **and** all committed Lua conforms to it,
  **and** edits that bypass format-on-save (Claude Code tools, the feature-authoring skill) are kept
  stylua-clean by enforcement — so the tree stays conformant, not just at the moment of the one-shot.

## Impact

- **Dozens of Lua files** reformatted (whitespace / trailing commas / wrapping only — no logic).
- **`.claude/settings.json`** — new `PostToolUse` hook (Edit/Write → stylua on `.lua`).
- **`.claude/skills/add-neovim-feature`** — a `stylua` validation step added.
- **`.git-blame-ignore-revs`** — new; lists the reformat commit SHA.
- **`.stylua.toml`** — already on `main` (Change 05); relied on, not changed.
- **stylua as a documented dependency** — handled under the `document-setup-prerequisites` change
  (stylua is now load-bearing for both save *and* the hook).
- No plugin or runtime behaviour changes; the reformat is purely cosmetic.

## Prerequisites and sequencing

**Run NOW — not "last" as originally scoped.** The old "run last" rationale assumed other changes
were in flight touching Lua; that is no longer true:

- The 01–08 best-of-breed series is **merged**.
- `document-setup-prerequisites` is **docs-only** (AsciiDoc) — no Lua overlap.
- `migrate-treesitter-main` and the `claude_cli` key fix touch Lua but are **unstarted** (no branch to
  conflict with).

With no Lua work in flight, there is nothing for the reformat to muddy. More importantly, **the
enforcement hook inverts the sequencing logic**: normalize + enable the hook now, and every
subsequent change (the treesitter rewrite, the claude_cli fix) is *born* stylua-clean instead of
producing noisy diffs until some future "end game."

- **Hard prerequisite:** `.stylua.toml` on `main` (Change 05 — satisfied).
- **Sequence:** next / now.

## Out of scope

- Changing stylua's rules beyond the 2-space indent pinned in Change 05 (accept defaults —
  `column_width = 120`, `AutoPreferDouble` quotes, `Always` call parens, trailing commas).
- Formatting non-Lua files (AsciiDoc, JSON, shell) — different tools, separate concern.
- A git `pre-commit` `stylua --check` hook for human/CI edits — deferred (repo has no CI; the
  `PostToolUse` hook + save + skill step cover the actual edit paths). Revisit if a CI pipeline lands.
