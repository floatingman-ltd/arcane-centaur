# Restart handoff — 2026-09-04

Snapshot taken with validation complete, awaiting PR. Delete this file once work resumes; it is a point-in-time note, not documentation.

## Git state

| | |
|---|---|
| Branch | `feat/markserv-gfm-alerts` — pushed through `f0ac11e` |
| `main` | `4d098c0`, in sync with `origin/main` — nothing to push |
| Working tree | clean |

Everything is committed **and pushed**, so nothing is at risk from a power-down or a disk failure. The only exception is the commit that corrects this very table: if `git log origin/feat/markserv-gfm-alerts..HEAD` returns anything, push it.

## Where we are

`add-markserv-gfm-alerts` — **validation complete**. All four artifacts pass `openspec validate --strict`, implementation and documentation are done, and `MA.1`–`MA.7` in `openspec/TEST_PLAN.md` are all ticked. Tasks stand at 20 of 21, the remainder being post-merge by design.

**Waiting on the user to push and raise the PR**, which along with the merge are theirs to do.

Title `Render GFM alerts in the markserv preview`. Compare URL:

```
https://github.com/floatingman-ltd/arcane-centaur/compare/main...feat/markserv-gfm-alerts?expand=1
```

Squash-merge, matching every merge since #171.

## The container is back where it belongs

Restored after validation — no action needed:

```
mount = /home/walt/src/rmv
MD_ALERT_VOCAB = gfm
```

Confirmed serving the RMVMT tree again (`0021/one-pager.md` returns 200). If the post-merge re-confirmation of `MA.1`/`MA.2` needs the fixture, repoint temporarily with `MD_DIR=/home/walt/.config/nvim`, then restore with the mount above.

## Things that survive the reboot

- `fantomas` 7.0.6 and `fsautocomplete` 0.83.0 in `~/.dotnet/tools`, `marksman` (release `2026-02-08`) in `~/.local/bin`. All on `$PATH`.
- The markserv image, already built with the `MD_ALERT_VOCAB` flag in it. Switching vocabulary afterwards needs only `up -d`, never `--build`.
- Docker services run `restart: unless-stopped` and should come back on their own — including with the validation mount above, so check it before assuming the RMVMT preview works.

## Two warnings for whoever resumes

**MA.7 step 4 is the point of the case — count icons, do not just check panels.** The plugin's `icons` option *replaces* its default map rather than merging into it, so supplying any custom icon silently strips the icons from all five GFM markers. When that bug was live, every panel still rendered in the correct colour and only the octicon count gave it away: 8 where 15 were expected. Scroll to the *five alert types* section at the top of the fixture and confirm those five still have icons.

**Do not read MA.4 in the Neovim buffer.** `render-markdown.nvim` renders `[!EXAMPLE]` as an Obsidian callout and assigns it `RenderMarkdownHint` — the identical highlight group it gives `[!IMPORTANT]` — so in-buffer the two are the same colour by design. That already caused one false defect report this session. MA.4 is a browser assertion.

## Remaining on this change

1. **User pushes**, raises the PR in the browser, reviews, squash-merges.
2. Post-merge: `git checkout main && git pull`, rebuild the container from merged `main`, re-confirm `MA.1` and `MA.2`, archive the change and promote the deltas.
3. Tasks 5.1 (delete `recommendations/nvim-markserv-gfm-alerts-proposal.md`) and 5.2 (`sudo rm -rf docker/markserv/docs` — the stray root-owned tree from the earlier relative-`MD_DIR` failure; still present, needs the user's sudo).
4. Delete this file.

## Left unfinished on the previous change

`install-language-servers` shipped in **PR #184** but was never closed out. `openspec/changes/install-language-servers/` is still unarchived, and **9 boxes remain open** in its TEST_PLAN section:

- `LS.10` — the docs render check. The user opted to review the published site and log defects separately; that has not happened.
- The whole `Raise PR & merge` and `Post-merge` blocks, including re-confirming `LS.4`/`LS.5` on merged `main`, archiving, and hand-correcting the Purpose of `openspec/specs/code-folding/spec.md` (tasks 5.3 — `openspec archive` never touches Purpose prose, and it still claims treesitter folding is disabled and markdown uses indent only).

The local and remote `fix/install-language-servers` branches also still exist.

## Known defect, logged nowhere yet

`docs/modules/ROOT/pages/content/markdown-cheatsheet.adoc` and `lua/config/mdpreview.lua:9` both say markserv live reload runs on **port 35729**. It does not — this build delivers it over SSE on `/__livereload` on port 8090. 35729 is upstream markserv's LiveReload port and this server never uses it. Pre-existing, unrelated to the current change, and not yet in `recommendations/ideas.md`.

## Queue after this change

1. **blink spell suggestions are filtered out** — `cmp-spell` sets each suggestion's `filterText` to itself, so a correction never matches its own misspelling. **Try native `<C-x>s` first**; that lead is untested and could make the change unnecessary.
2. **F# has no indent support of any kind** — measured but deliberately not fixed by `install-language-servers`. Needs a plugin decision (`ionide/Ionide-vim` ships an `indent/fsharp.vim`), so it wants a decision before an edit.
3. Fourteen capability specs with placeholder Purposes.
4. `open_url` never reaches `open` on macOS — understood, needs a Mac to verify.

## Standing conventions

- The user runs `git push`, `gh pr create` and `gh pr merge`; echo the commands, never execute them.
- No PR until every test-plan box is genuinely ticked.
- Every runtime change gets its own branch and a TEST_PLAN section, verified live before push. `lazy-lock.json`-only commits are the documented exception and go straight to `main`.
- Prose is one line per paragraph. No arbitrary hard returns.
- Squash-merge, matching every merge since #171.
