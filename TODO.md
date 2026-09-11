# TODO / Cleanup Backlog

Running list of known loose ends, deferred work, and housekeeping tasks.
Add new items here as they are discovered; remove or move them to the relevant
openspec change when work begins.

---

## Git Housekeeping

**Nothing outstanding as of 2026-09-10.** `origin` carries only `main` and `gh-pages`; locally, `main` is the only branch. Verified with `git ls-remote --heads origin` and `git branch -a`.

The nine `origin/*` branches this section listed on 2026-09-09 had all been deleted on the remote by the time they were re-checked — the local `refs/remotes/origin/*` entries were stale tracking refs, cleared with `git fetch --all --prune`. This is the second consecutive time the list went stale before anyone worked it: the 2026-09-09 rewrite found all 13 of its predecessor's branches already gone too.

**So do not maintain a branch list here.** Two rewrites in two days both produced a list that was wrong when read. Re-derive on the spot instead, and only write something down if a branch turns out to hold unique work:

```sh
git fetch --all --prune                     # clear stale tracking refs first
git ls-remote --heads origin                # what actually exists
git rev-list --count origin/main..<branch>  # per branch, is it ahead?
```

Keep `origin/main` and `origin/gh-pages`. Recovery SHAs for the four branches deleted locally on 2026-09-09, should they ever be wanted: `backup/markserv-pre-collapse` `9c49620`, `feat/markserv-gfm-alerts` `dd43bb9`, `feat/vendor-fsharp-indent` `1d66514`, `fix/install-language-servers` `b562b23` — in the reflog for 90 days from that date.

### Stale stashes

**Dropped 2026-09-10 — nothing outstanding.** Three stashes had accumulated, all on branches that no longer exist. Each contained **only `lazy-lock.json`** — no staged component, no untracked files, no source changes — and each was a *regression* against `main` rather than pending work: they reinstated removed plugins and predated current pins. `stash@{2}` was the clearest case, carrying the whole pre-blink `nvim-cmp`/`cmp-*` family. Restoring any of them would have undone shipped work.

Recovery SHAs, should they ever be wanted — in the reflog for 90 days from 2026-09-10:

| Was | Base | Content |
|---|---|---|
| `b04ebf5` | `16aa6ee` (feat/06 diagnostics panel) | 1 line; `glow.nvim` back, `claudecode.nvim`/`nvim-dap`/`easy-dotnet` gone |
| `2c5e588` | `7c7f53a` (bracey fix) | 12+/14−; `glow.nvim`, `dressing.nvim`, treesitter back on `master` |
| `4619508` | `4d4804e` (asciidoc docs) | 2 lines; pre-blink `nvim-cmp` + five `cmp-*` plugins |

A dropped stash is unreachable by `git stash list`, so `git fsck --unreachable` or the SHAs above are the only routes back.

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

- [X] ~~**avante.nvim version pin** — pinned to `v0.0.27`~~ — **stale, closed 2026-09-11.** `lua/plugins/avante.lua` pins `version = "v0.1.*"` and has done since `avante-runtime`; the `v0.0.27` pin and its do-not-update comment were retired by that change. This entry outlived the problem, which is the same failure the Git Housekeeping section above was rewritten to stop repeating: verify before carrying an item forward.

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
