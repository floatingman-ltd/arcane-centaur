# Restart handoff — 2026-09-04

Snapshot taken mid-validation, ahead of a possible power-down. Delete this file once work resumes; it is a point-in-time note, not documentation.

## Git state

| | |
|---|---|
| Branch | `feat/markserv-gfm-alerts` — pushed through `f0ac11e` |
| `main` | `4d098c0`, in sync with `origin/main` — nothing to push |
| Working tree | clean |

Everything is committed **and pushed**, so nothing is at risk from a power-down or a disk failure. The only exception is the commit that corrects this very table: if `git log origin/feat/markserv-gfm-alerts..HEAD` returns anything, push it.

## Where we are

Mid-validation on the OpenSpec change `add-markserv-gfm-alerts`. All four artifacts are written and pass `openspec validate --strict`; implementation and documentation are done; the test plan is `## Change · add-markserv-gfm-alerts` in `openspec/TEST_PLAN.md`, cases `MA.1`–`MA.7`.

**Validation progress: 6 of 7.** `MA.1`–`MA.6` are ticked. `MA.7` — the `MD_ALERT_VOCAB` switch — is the only one open, and it is *half done*: steps 1 and 2 are confirmed, steps 3–6 are not.

**Resume at `MA.7` step 3.** The container has already been rebuilt and flipped to `extended`, so no setup is needed — just reload `http://localhost:8090/testdocs/gfm-alerts.md` and look.

What is already confirmed for MA.7, server-side, by reading the served HTML:

- Step 1 (default `gfm`): 5 panels, 7 icons, `[!EXAMPLE]` and `[!NONSENSE]` both literal.
- Step 2: flipping to `extended` recreated the container with **no rebuild** — compose reported `Recreate`, not a build. That is the core claim of the case.
- Under `extended`: 16 panels, 15 icons, `quote` the only iconless one, the GFM five still carrying their own icons, `TL;DR` and `FAQ` titled correctly, `[!EXAMPLE]` now a panel, `[!NONSENSE]` still literal.

What is **not** confirmed, and is what MA.7 still needs: the visual check in a browser. Colours per group (`[!EXAMPLE]` purple, `[!QUESTION]` amber, `[!TODO]` blue, `[!BUG]` red, `[!SUCCESS]` green), and step 6 — flipping back to `gfm` and confirming the *Extended vocabulary* section reverts to plain blockquotes.

## The container is not where you left it

**This matters more than anything else here.** The markserv container has been repointed for validation and is **not** serving the RMVMT docs:

```
mount = /home/walt/.config/nvim      (was /home/walt/src/rmv)
MD_ALERT_VOCAB = extended            (default is gfm)
```

Restore it when validation is done:

```
MD_DIR=/home/walt/src/rmv docker compose -f docker/markserv/docker-compose.yml up -d
```

That also returns the vocabulary to `gfm`, since `MD_ALERT_VOCAB` is unset in that command and the compose default is `gfm`.

## Things that survive the reboot

- `fantomas` 7.0.6 and `fsautocomplete` 0.83.0 in `~/.dotnet/tools`, `marksman` (release `2026-02-08`) in `~/.local/bin`. All on `$PATH`.
- The markserv image, already built with the `MD_ALERT_VOCAB` flag in it. Switching vocabulary afterwards needs only `up -d`, never `--build`.
- Docker services run `restart: unless-stopped` and should come back on their own — including with the validation mount above, so check it before assuming the RMVMT preview works.

## Two warnings for whoever resumes

**MA.7 step 4 is the point of the case — count icons, do not just check panels.** The plugin's `icons` option *replaces* its default map rather than merging into it, so supplying any custom icon silently strips the icons from all five GFM markers. When that bug was live, every panel still rendered in the correct colour and only the octicon count gave it away: 8 where 15 were expected. Scroll to the *five alert types* section at the top of the fixture and confirm those five still have icons.

**Do not read MA.4 in the Neovim buffer.** `render-markdown.nvim` renders `[!EXAMPLE]` as an Obsidian callout and assigns it `RenderMarkdownHint` — the identical highlight group it gives `[!IMPORTANT]` — so in-buffer the two are the same colour by design. That already caused one false defect report this session. MA.4 is a browser assertion.

## Remaining after MA.7

1. Tick `MA.7`, then tasks 3.6 in `openspec/changes/add-markserv-gfm-alerts/tasks.md`.
2. Push, PR, review, squash-merge.
3. Post-merge: rebuild from merged `main`, re-confirm `MA.1` and `MA.2`, archive, then tasks 5.1 (delete `recommendations/nvim-markserv-gfm-alerts-proposal.md`) and 5.2 (`sudo rm -rf docker/markserv/docs` — the stray root-owned tree from the earlier relative-`MD_DIR` failure; still present).
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
