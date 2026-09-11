# Deferred verification

Work that needs **human eyes** and has not had them. Every item here was consciously set aside rather than forgotten, but the reasons vary a great deal — some are blocked on hardware, some on a toolchain, and some are simply undone.

This file exists because `openspec/TEST_PLAN.md` records deferrals *inside the section of the change that created them*, which is right for provenance and useless for answering "what still needs looking at?". Sections are ordered oldest-first within each group.

Two entries below record work believed to exist that **does not** — `reorganize-per-plugin-docs` and `document-setup-prerequisites`. Both were checked while compiling this file. That is the strongest argument for the file existing: deferrals tracked only in notes decay into deferrals tracked nowhere.

> **Active work, paused — read this first.** `add-remote-session-profile` is the only change in flight. Code complete and pushed on `feat/add-remote-session-profile`; validation blocked on the remote host being rebuilt as of 2026-09-11, expected back around 2026-09-25. Full state in **group C** below, cases in `openspec/TEST_PLAN.md` § `Change · add-remote-session-profile`. Everything else in this file is older and unblocked.

**A tick in `TEST_PLAN.md` does not always mean a human looked.** Where a box was closed on programmatic evidence with the human check deferred, it is listed below. That is deliberate and recorded in each case, but it means the plan reads greener than reality.

---

## A. Published-site reviews — verified locally, never seen published

The pattern across three changes: every documentation assertion was checked against the **local** Antora build in `build/site/`, the box was ticked on that, and reviewing the **published** site was left to the user. Nobody has confirmed that any of it renders correctly at the hosted URL.

The risk is narrow but real: local and published differ in the Antora playbook used, so a local pass does not prove the published page is right.

| Change | Case | Status |
|---|---|---|
| `install-language-servers` | `LS.10` | Ticked on the local build. Published review deferred. |
| `add-markserv-gfm-alerts` | `MA.6` | Ticked on the local build. User elected to inspect the published site and log defects separately; that has not happened. |
| `add-fsharp-indent` | `FI.8` | Ticked on the local build. Published review deferred (2026-09-09). |

**What to look for, consolidated:**

1. `languages/setup.html` — Markdown row shows `marksman`; a `fantomas` dependency row sits beside `fsautocomplete`; the GitHub-release install, not an apt package.
2. `editor/code-intelligence.html` — marksman's install is the GitHub release; the F# row mentions `dotnet tool install -g fantomas`; the notes render as **boxed callouts**, not run-on prose; the note no longer claims F# lacks indentation.
3. `content/diagrams.html` — the corrected marksman install command.
4. `other/architecture.html` — Markdown row's LSP cell reads `✅ marksman (no folds/format)`.
5. `languages/dotnet.html` — the Fantomas `IMPORTANT` callout with the literal `No Fantomas install was found.` prompt; the `.fsx` `A task was canceled` warning; the new *F# — Indentation* section; the commenting paragraph, with `//` and `///` rendering as slashes rather than stray `+` characters (newest AsciiDoc escaping, least exercised).
6. `content/markdown.html` and `content/markdown-cheatsheet.html` — the five GFM alert markers, the absolute-`MD_DIR` warning, the rebuild note, and **no** mention of port 35729.
7. **Site-wide:** `sudo apt install marksman` appears nowhere.

Ignore `skipping reference to missing attribute` warnings for `name`, `pat` and `feed` — pre-existing, confirmed against an older tree.

---

## B. Cases that were never fully verified

Genuinely incomplete, and each says so in place.

**`Change 07 · add-dotnet-debug-test` §7.5 — Haskell DAP.** Marked `**DEFERRED**` in the plan. Cannot be verified without the Haskell toolchain (ghc/cabal/HLS plus `haskell-debug-adapter`) and a real cabal/stack project. Blocked on toolchain installation. The plan says this is *tracked under* `document-setup-prerequisites` — see group F: that change does not exist, so it is tracked nowhere.

**`Change 03 · migrate-completion-blink` §3.5 — Conjure/Clojure completion.** Deferred as out of scope at the time; the steps are retained in the plan for whenever Clojure work resumes.

**Conjure HUD / eval-popup fold behaviour.** In the `align-treesitter-providers` section: *"the Conjure HUD/eval-popup sub-step was not separately reported, so it is unverified rather than passed."* It needs a running REPL, which is the least accessible part of that step. The markdown float — the buffer type the original defect actually blamed — **was** exercised and is clean, so the specific regression is covered; the Conjure surface is not.

---

## C. Blocked on hardware or environment

**`add-remote-session-profile` — remote validation. Blocked on the remote host, which is being rebuilt as of 2026-09-11; expected back around 2026-09-25.** This is the one live piece of work in the repository, and it is paused rather than abandoned.

The code is complete and pushed: branch `feat/add-remote-session-profile`, commits `f009e6f` (proposal artifacts) and `d35552b` (implementation). It adds `term.is_remote` to `lua/config/terminal.lua` and wires `ttimeoutlen` and lualine's repaint interval to it, closing the code side of GitHub issues #189, #188 and #187. 19 of 31 tasks are done; the remainder is validation plus post-merge close-out.

**To resume, read `openspec/TEST_PLAN.md` § `Change · add-remote-session-profile`.** It holds all 39 boxes, none ticked, each with the headless evidence already gathered recorded underneath it as a blockquote.

| Case | State |
|---|---|
| `RS.1`, `RS.2`, `RS.5`, `RS.6`, `RS.7`, `RS.11`, `RS.12` | Headless evidence recorded. Needs a live session to confirm, which is quick. |
| `RS.3`, `RS.8`, `RS.9`, `RS.10` | **Needs the remote host.** Nothing can be done until it returns. |
| `RS.4` | **Needs the remote host and tmux on it.** The highest-value case — see below. |

`RS.4` is the one worth the setup effort. It is the case the second detection step exists for: a tmux session started *before* the SSH connection hosts a Neovim with no `SSH_*` variables at all, because a process's environment is fixed when it starts and tmux cannot update panes that already exist. The mechanism was reproduced locally on 2026-09-10 by recreating the same asymmetry — pane created first, `tmux set-environment SSH_CONNECTION` set afterwards, `is_remote` read `true` from a pane whose own environment had zero `SSH_*` entries — but never over a real link, which is the whole point of the case.

`RS.10` is a feel-test of `<Esc>` latency at `ttimeoutlen=100` and has no headless equivalent at all. Record the verdict rather than just ticking it; 75 ms is the recorded fallback if 100 ms proves intolerable.

> **One defect was already found and fixed during implementation**, and its regression case is `RS.7`. Adding `User GitSignsUpdate` to lualine's `options.refresh.events` looks correct and is not: lualine builds that list into one command with `string.format("autocmd %s %s %s %s", ...)`, so the space splits the event list and everything after it becomes the pattern — leaving all ten real events bound to the pattern `GitSignsUpdate` instead of `*`, and the statusline silently not refreshing on cursor movement. Fixed by using dedicated autocommands in a `LualineAsyncRefresh` augroup. If a future change revisits lualine's refresh wiring, this is the trap.

**Post-merge close-out is task group 6** in `openspec/changes/add-remote-session-profile/tasks.md`: close the three issues, strip `#187`/`#188`/`#189` from the priority entry in `recommendations/ideas.md` leaving `#190`-`#192`, archive the change, and write the `remote-session-profile` Purpose by hand immediately — `openspec archive` leaves a `TBD` placeholder that no delta can fill, and 14 specs already carry one.

**macOS `open_url`.** No longer deferred — **formally declined**. macOS is out of scope for this configuration; recorded under *Declined* in `recommendations/ideas.md` with the reasoning, and explicitly marked do-not-re-log. Listed here only so nobody reads its absence as an oversight.

**`Alt-Space` completion trigger under WSL.** Reported not working on 2026-07-30 and **never diagnosed** — the cause is presumed to be the Windows host or the terminal swallowing the chord, but that was never confirmed. The runtime is fine: the trigger is now `<C-n>` in `lua/plugins/blink.lua`, and both `editor/code-intelligence.adoc` and `openspec/specs/completion-engine/spec.md` have been corrected, the latter now *requiring* that the trigger not be a host-reserved combination.

> **Found while compiling this file (2026-09-09), and fixed — but it exposed something larger.** `_readme.adoc` still told readers to press `Alt+Space`. Corrected to `Ctrl-n`.
>
> My first characterisation of that file as "the repository's front page" was **wrong**. `_readme.adoc` is an orphan: absent from the Antora site, absent from `nav.adoc`, referenced by nothing but archived task notes, and not in the built output. `readme.md` is the actual readme. It is also stale far beyond one keymap — roughly **30 mentions of GitHub Copilot**, which was removed in favour of Claude, plus nvim-cmp and glow. `replace-glow-renderer` recorded it in August 2026 as *"stale beyond this change and only partly repaired"*, so piecemeal repair has now been attempted three times without converging.
>
> **Resolved 2026-09-09 — deleted.** 776 lines, 31 Copilot mentions, unpublished and unreferenced; git history keeps it. Before deleting, its sections were checked against the Antora pages and one thing was genuinely unique: ~150 lines of terminal and Nerd Font setup guidance, which `getting-started.adoc` did not cover at all. That was condensed and moved there as *Terminal and Nerd Font (optional — enables icons)* rather than dropped.

---

## D. Standing checklists never completed

These are reusable templates in `TEST_PLAN.md` rather than one-off deferrals, but their boxes have never all been ticked, so they read as outstanding.

**`One-Time Test Machine Setup`** — one open box: bring up the Ollama backend **and pull the model** avante is configured for (`qwen2.5:0.5b`). The compose file starts the server but pulls nothing, so avante's default provider has never been exercised end to end on a fresh machine.

**`Per-Branch Sync & Sanity Check`** — five boxes, intended to be re-run per branch: on the expected branch and in sync, clean working tree, right commit, `:Lazy sync` clean, clean startup. Never ticked, because it is meant to be repeated rather than completed. Arguably it should be a template rather than a checklist with permanent empty boxes.

**`Resolved defect (runbook retained) — root filesystem / mounted read-only`** — four boxes retained deliberately as a runbook for if it recurs. Not outstanding work; listed so a box count of the file is not misread.

---

## E. End-to-end and documentation passes from `TODO.md`

Long-standing, and the largest block of genuinely undone eyes-on work.

- **Run the full validation guide** — work through every section rather than the per-change subsets.
- **Test on a fresh machine / clean install** — clone to a new machine and follow the setup docs as written. This is the only thing that would catch missing prerequisites; the `ripgrep`/`fzf` gap was found exactly this way, by accident — and has since been closed.
- **Console-mode E2E** — the validation guide's sections 3–9 in a real console (no GUI), where terminal-capability branching in `lua/config/terminal.lua` actually matters.
- **`docs/guides/validation.md`** — complete a run-through and mark its steps.
- **REST client guide** — may be stale since the kulala migration.
- **`docs/jira-project-map.md`** — a stub; needs real project keys.
- **Architecture doc** — written from inspection rather than use; needs a read-through against reality.

Note several of these reference `docs/guides/*.md` paths that predate the Antora migration, so the file list itself needs checking before the work does.

---

## F. Known mismatches waiting on a decision or a pass

**~~`ripgrep` and `fzf` are undocumented runtime dependencies.~~ Closed — and this entry was stale when written.** `getting-started.adoc` has a *ripgrep and fzf* section documenting both binaries, what breaks without each, and the install command. Found 2026-09-09 while checking `_readme.adoc`'s sections against the docs. The lesson is the same one this file was created for: the note recording the gap outlived the gap, because nothing prompted a re-check. **Verify before carrying a deferral forward.**

**Keymap documentation is unreconciled.** There are three unsynchronised keymap surfaces and none reads the others: which-key (generated from `desc`, always accurate), the `<leader>?` cheatsheet (hand-maintained `cheatsheets/*.md`), and the Antora pages. `editor/keybindings.adoc` is a 518-line sheet **orphaned from `nav.adoc`** that duplicates the per-area cheatsheets.

> **Correction, verified 2026-09-09:** the intended fix was recorded as an OpenSpec change `reorganize-per-plugin-docs` with 4/4 artifacts on a branch `docs/reorganize-per-plugin-docs`. **That change does not exist in this repository** — not in `openspec/changes/`, not in `openspec/changes/archive/`, and no such branch exists locally or on `origin`. Either it was never pushed and the branch was deleted, or the record of it was wrong. The design intent is worth keeping (one page per plugin, leading with a plain-language description, then that plugin's keymaps, piloted on the Git area) but the artifacts must be treated as lost and rewritten.

**The context-aware cheatsheet buries its context.** `<leader>?` concatenates `core.md` then the filetype sheet, so filetype content starts around line 213 of a 259-line float — the "context-aware" part is the least visible part. Found 2026-09-09 while validating `add-fsharp-indent` `FI.8`; **not yet logged in `ideas.md`**. Jumping the cursor to the filetype heading on open would fix it.

**`lua_ls` reports `Undefined global vim` across the whole tree.** Every `after/ftplugin/*.lua` and `lua/**` file shows it. Pre-existing and cosmetic — it is a missing lua_ls workspace/library configuration, not a code defect — but it means real diagnostics are buried in noise, which is how a genuine `unpack` deprecation nearly went unnoticed on 2026-09-08.

---

## Boxes ticked on evidence rather than observation

Recorded here because they are the places where the plan is greenest relative to what was actually witnessed.

- **`install-language-servers` PR/review/merge boxes** — ticked on the evidence of `72a20ef fix/install language servers (#184)` in `main`'s history, not on a fresh observation. Flagged in place; correct them if the record is wrong.
- **The three `LS.10`/`MA.6`/`FI.8` documentation boxes** — see group A.
- **`add-fsharp-indent` `FI.6`** — passed live, and notably *without* the intermittent `.fsx` project-options error appearing. Its absence in one run is not evidence the flake is fixed.

---

## Where this kind of knowledge lives

Decided 2026-09-09, after this file's own compilation found two pieces of work recorded as existing that did not.

Claude Code keeps per-project notes in `~/.claude/projects/-home-walt--config-nvim/memory/`. That directory is **outside the repository and unversioned** — no history, machine-local, not reviewable in a PR. It had accumulated substantive engineering knowledge, which is the wrong place for it.

The split is now:

| Belongs in the repo | Stays in memory |
|---|---|
| `CLAUDE.md` — architecture, conventions, tooling gotchas | How to work with the user: who pushes, how to phrase commands |
| `openspec/DEFERRED_VERIFICATION.md` — eyes-on work outstanding | Environment quirks of *this machine* (e.g. `nvim` being a shell alias) |
| `recommendations/ideas.md` — defects, ideas, declined decisions | Writing and reporting preferences |
| `openspec/TEST_PLAN.md` — per-change validation | |

Nine memory entries were promoted or deleted as a result: the OpenSpec archive gotchas and the Neovim 0.12 API drift note moved into `CLAUDE.md`; the ripgrep/fzf gap, the keymap-docs reconciliation and the `Alt-Space` history were already captured here; and four shipped-work notes were dropped because the git history and the OpenSpec archive already record them.

**If you find yourself writing a project fact into memory, put it in one of the four files above instead.**

