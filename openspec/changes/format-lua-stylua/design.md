## Context

`lua/plugins/conform.lua` sets `formatters_by_ft.lua = { "stylua" }` with format-on-save, but:

- no `.stylua.toml` existed until Change 05 added one (`indent_type = "Spaces"`, `indent_width = 2`),
  so stylua defaulted to tabs; and
- the committed Lua predates stylua entirely — `stylua --check lua/` flags ~29 files.

So format-on-save silently reformats any edited Lua file to stylua style, producing large diffs and
(pre-Change-05) a tab/space flip-flop. The tree needs a one-time normalization so the formatter and
the committed code agree.

## Goals / Non-Goals

**Goals**
- Every committed Lua file conforms to `.stylua.toml` + stylua defaults, so format-on-save is a
  no-op on unedited files and future diffs are minimal.
- A single, mechanical, reviewable formatting commit.

**Non-Goals**
- No logic changes; no stylua rule changes beyond the 2-space indent pinned in Change 05.
- No formatting of non-Lua files.

## Decisions

### Format the whole tree in one pass, last in the sequence
Run stylua once over every Lua root, after all functional changes have merged. Doing it early would
muddy every other change's diff and invite merge conflicts; doing it last isolates the churn.

### Accept stylua's defaults (except indent)
Only `indent_type = Spaces` / `indent_width = 2` are pinned (to match the repo). Everything else —
`column_width = 120`, `AutoPreferDouble` quotes, `Always` call parens, trailing commas — uses stylua
defaults. Keeps `.stylua.toml` minimal and the output predictable.

### Verify semantics are unchanged
Formatting must not change behaviour. After the pass, `luac -p` on every file and a clean Neovim
start (`:messages` empty) confirm the reformat is purely cosmetic.

## Risks / Trade-offs

- **Large diff (~29 files).** Mitigation: one isolated, mechanical commit reviewers can trust via
  `git show --stat` and the `luac -p` gate; no logic touched.
- **Merge conflicts if run early.** Mitigation: sequence it last (end game).
- **Contributors without stylua.** conform already degrades gracefully when stylua is absent (the
  file saves unformatted); `.stylua.toml` only standardises output when stylua *is* present.

## Validation outline
1. Confirm `.stylua.toml` is present (from Change 05).
2. `stylua lua/ after/ init.lua` (plus any other Lua roots — `plugin/`, `ftplugin/`).
3. `stylua --check .` → no diffs remain.
4. `find . -name '*.lua' -not -path './.git/*' -print0 | xargs -0 luac -p` → all pass.
5. Launch Neovim → `:messages` shows no load errors.
6. `git show --stat` → only whitespace/formatting changes, no logic.
