## 1. Preconditions

- [ ] 1.1 Change 05 merged, so `.stylua.toml` is on `main` (`test -f .stylua.toml`).
- [ ] 1.2 Changes 06–08 and `document-setup-prerequisites` merged (this runs last).
- [ ] 1.3 `stylua` on `$PATH` (`stylua --version`).

## 2. Format

- [ ] 2.1 Run `stylua lua/ after/ init.lua` (plus any other Lua roots — `plugin/`, `ftplugin/`).
- [ ] 2.2 `stylua --check .` reports no remaining diffs.

## 3. Verify (formatting only — no behaviour change)

- [ ] 3.1 `find . -name '*.lua' -not -path './.git/*' -print0 | xargs -0 luac -p` → all parse.
- [ ] 3.2 Launch Neovim → `:messages` shows no plugin / LSP / treesitter load errors.
- [ ] 3.3 `git show --stat` reviewed — only whitespace / formatting, no logic changes.

## 4. Ship

- [ ] 4.1 Single commit: `style(lua): format entire tree with stylua (2-space via .stylua.toml)`.
- [ ] 4.2 Raise PR → `main`; review the stat/diff; merge.
- [ ] 4.3 Post-merge: `git checkout main && git pull`; confirm `stylua --check .` is clean.
