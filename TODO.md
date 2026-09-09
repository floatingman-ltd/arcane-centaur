# TODO / Cleanup Backlog

Running list of known loose ends, deferred work, and housekeeping tasks.
Add new items here as they are discovered; remove or move them to the relevant
openspec change when work begins.

---

## Git Housekeeping

**Rewritten 2026-09-09.** The previous list named 13 `origin/*` branches to delete. **All 13 were
already gone**, and **none of the 9 that actually existed were listed** — so following it would have
been busywork while missing everything real. If you touch this section, re-derive it from
`git branch -r` rather than editing the list in place.

### Merged remote branches, safe to delete

Verified 2026-09-09: for each, the only files not present on `main` are pre-archive
`openspec/changes/<name>/` paths (now under `openspec/changes/archive/`), the retired
`markdown-preview-glow` spec, and `_readme.adoc` — which was deleted deliberately. No unique work.

- [ ] `origin/chore/archive-align-treesitter-providers`
- [ ] `origin/chore/archive-replace-glow-renderer`
- [ ] `origin/chore/archive-retire-glow-spec-references`
- [ ] `origin/chore/close-align-treesitter-providers`
- [ ] `origin/chore/lazy-lock-sync-late-aug`
- [ ] `origin/fix/align-treesitter-providers`
- [ ] `origin/fix/open-url-wsl-opener`
- [ ] `origin/fix/replace-glow-renderer`
- [ ] `origin/fix/retire-glow-spec-references`

```sh
git push origin --delete <branch>          # one per branch; the user runs these
git fetch --all --prune                    # then drop the stale tracking refs
```

Keep `origin/main` and `origin/gh-pages`. Local branches were cleaned on 2026-09-09; `main` is the
only one left. Recovery SHAs for the four deleted locally, should they ever be wanted:
`backup/markserv-pre-collapse` `9c49620`, `feat/markserv-gfm-alerts` `dd43bb9`,
`feat/vendor-fsharp-indent` `1d66514`, `fix/install-language-servers` `b562b23` — in the reflog for
90 days from that date.

## End-to-End Testing

- [ ] **Run the full validation guide** — work through every section of
  `docs/guides/validation.md` on the current machine and mark all items `[x]`.

- [ ] **Test on a fresh machine / clean install** — clone the repo to a new
  machine (or a fresh WSL instance), follow `readme.md` from scratch, and verify
  all Docker services start and all features work without prior state.

- [ ] **Console-mode E2E** — run the validation guide sections 3–9 explicitly
  under `env -u DISPLAY -u WAYLAND_DISPLAY nvim` to confirm all console-mode
  paths work end-to-end.

---

## Deferred Features / Known Limitations

- [ ] **PlantUML Unicode art (`/utxt/`)** — the current `plantuml/plantuml-server:jetty`
  image returns 404 for the `/utxt/` endpoint. Upgrade the image and switch
  `lua/plugins/plantuml.lua` back to `/utxt/` once confirmed.
  See `docs/guides/cli-console-mode.md` "Known limitation" callout.

- [ ] **avante.nvim version pin** — pinned to `v0.0.27` (latest release with
  prebuilt Linux binaries). Monitor [releases](https://github.com/yetone/avante.nvim/releases)
  and unpin `version = "v0.0.27"` in `lua/plugins/avante.lua` when a newer
  release publishes Linux `.so` files.

- [x] **`lazy-lock.json` is gitignored** — currently excluded from version control.
  Consider whether to track it (guarantees reproducible installs across machines)
  or keep it ignored (allows each machine to use latest compatible versions).

---

## Incomplete OpenSpec Changes

**None. This section held 46 open task items for three changes; all three are archived and shipped.**
Verified 2026-09-09:

| Change | Archived | Evidence in the config |
|---|---|---|
| `add-jira-workflow` | yes | `lua/config/jira.lua`, 340 lines, registers `:JiraCreateIssue`, binds `,ji` |
| `add-lua-support` | yes | `lua_ls` in `lua/config/lsp.lua`, `stylua` in `conform.lua`, `after/ftplugin/lua.lua` |
| `document-confluence-workflow` | yes | `scripts/confluence_publish.sh`, `lua/config/confluence.lua` |

Those raw task lists were copies of `tasks.md` from changes that then shipped, and nothing removed
them. They made this file look like it carried an entire unfinished feature — 46 of its 66 open
boxes — when the work was done.

**Do not paste change task lists in here.** They belong in `openspec/changes/<name>/tasks.md`, which
moves to `openspec/changes/archive/` when the change ships, so the record follows the work instead of
being duplicated somewhere that never gets revisited.

One genuine remnant survives, tracked under Documentation Gaps below: `docs/jira-project-map.md` does
not exist.

## Documentation Gaps

**Rewritten 2026-09-09.** Every path this section previously named was a pre-Antora `docs/guides/*.md`
or `docs/cheatsheets/*.md` file. **`docs/guides/` does not exist**; documentation moved to
`docs/modules/ROOT/pages/` under Antora. The gaps were therefore unactionable as written — you could
not open the files they referred to.

- [ ] **`docs/jira-project-map.md` is missing entirely.** `lua/config/jira.lua` resolves a project key
  by reading it, so the Jira integration depends on a file that is not in the repo. Either add it with
  real project keys, or change `jira.lua` to fail with a clear message naming the file it wants. This
  is the one gap from the old list that is both real and still true.
- [ ] **Re-derive the rest against the Antora tree.** The genuine questions behind the old entries —
  is the REST guide current after the kulala migration, is the architecture page accurate rather than
  inferred, has the validation guide ever been run end to end — are still worth asking, but they have
  to be asked of `docs/modules/ROOT/pages/`. Start from `nav.adoc` and read what is actually there.

Deferred *verification* work, as opposed to missing documentation, is inventoried separately in
`openspec/DEFERRED_VERIFICATION.md`.

## Code Quality

- [ ] **Keymaps audit** — some entries in `lua/keymaps.lua` have malformed
  string literals with stray spaces (e.g. `"< S-Down> "`). Review and fix.

- [ ] **`.gitignore`** — currently only ignores `lazy-lock.json`. Consider
  whether `testdocs/` and `.serena/cache/` (already in `.serena/.gitignore`)
  should also be excluded at repo level.
