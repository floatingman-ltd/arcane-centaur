## 1. Preconditions

- [ ] 1.1 `.stylua.toml` on `main` (`test -f .stylua.toml`) — from Change 05.
- [ ] 1.2 `stylua` on `$PATH` (`stylua --version`).
- [ ] 1.3 No Lua work in flight (01–08 merged; `migrate-treesitter-main` / `claude_cli` fix unstarted) — safe to run now.

## 2. Normalize

- [ ] 2.1 Run `stylua lua/ after/ init.lua` (plus any other Lua roots — `plugin/`, `ftplugin/`).
- [ ] 2.2 `stylua --check .` reports no remaining diffs.

## 3. Enforce (fold-in)

- [ ] 3.1 Add a `PostToolUse` hook to `.claude/settings.json` (via the `update-config` skill): match `Edit|Write`, filter to `*.lua`, run `stylua` on the written file; degrade gracefully (warn, never block) when `stylua` is absent or the file mid-edit fails to parse.
- [ ] 3.2 Add a `stylua` step to the `add-neovim-feature` skill's validation section.
- [ ] 3.3 (Deferred — not this change) `pre-commit` `stylua --check` for human/CI edits; revisit if CI lands.

## 4. Protect git blame

- [ ] 4.1 Create `.git-blame-ignore-revs` containing the reformat commit's SHA (added after the normalize commit exists).
- [ ] 4.2 Document `git config blame.ignoreRevsFile .git-blame-ignore-revs` (local step; GitHub honors the file automatically) — in `getting-started.adoc` or the repo README.

## 5. Verify (formatting only — no behaviour change)

- [ ] 5.1 `find . -name '*.lua' -not -path './.git/*' -print0 | xargs -0 luac -p` → all parse.
- [ ] 5.2 Launch Neovim → `:messages` shows no plugin / LSP / treesitter load errors.
- [ ] 5.3 `git show --stat` reviewed — only whitespace / formatting, no logic.
- [ ] 5.4 Enforcement check: edit a `.lua` via a Claude Edit/Write tool → the file is stylua-formatted afterward (hook fired), no edit blocked.

## 6. Dependency doc (cross-change)

- [ ] 6.1 Ensure `stylua` is listed as a required dependency under the `document-setup-prerequisites` change (load-bearing for format-on-save AND the `PostToolUse` hook).

## 7. Ship

- [ ] 7.1 Commit the normalize as one mechanical commit: `style(lua): format entire tree with stylua (2-space via .stylua.toml)`; add the enforcement + `.git-blame-ignore-revs` (referencing that SHA) in follow-up commit(s) on the same branch.
- [ ] 7.2 Raise PR → `main`; review the stat/diff; merge.
- [ ] 7.3 Post-merge: `git checkout main && git pull`; confirm `stylua --check .` is clean and the hook fires on a test `.lua` edit.
