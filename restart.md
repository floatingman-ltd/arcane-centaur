# Restart handoff — 2026-09-02

Snapshot taken before a system reboot. Delete this file once work resumes; it is a point-in-time note, not documentation.

## Git state

| | |
|---|---|
| Branch | `fix/install-language-servers` — **not pushed** |
| Branch commits | `fd32a46`, `c92c046`, `9c7a730`, `a3cde85` (4, on top of main) |
| `main` | `56b841b`, in sync with `origin/main` — nothing to push |
| Working tree | clean |

Nothing is uncommitted. The reboot cannot lose anything.

## Where we are

Mid-validation on the OpenSpec change `install-language-servers`. All four artifacts are written and pass `openspec validate --strict`; implementation and documentation are done; the test plan is written as `## Change · install-language-servers` in `openspec/TEST_PLAN.md`, cases `LS.1`–`LS.10`.

**Validation progress: 1 of 10.** `LS.1` is ticked. The `Prepare` box is not — it was never explicitly confirmed, so re-run it after the reboot rather than assuming.

**Resume at `LS.2`.** Full steps are in `openspec/TEST_PLAN.md` under `#### LS.2`. In short: open `testdocs/test.md`, confirm `:lua print(vim.lsp.get_clients({ bufnr = 0 })[1].server_capabilities.documentFormattingProvider)` prints `nil`, add ragged spacing mid-sentence to a prose line, `:w`, and confirm the spacing survives exactly as typed.

## Things that survive the reboot

Both language servers are installed on disk and will still be there:

- `~/.local/bin/marksman` — release `2026-02-08`, 22 MB
- `~/.dotnet/tools/fsautocomplete` — 0.83.0

Both directories are already on `$PATH`. If `command -v marksman fsautocomplete` fails after the reboot, that is a `$PATH` problem, not a missing install, and the whole test-plan section is invalid until it is fixed rather than merely failing.

The Docker preview services run with `restart: unless-stopped` and should come back by themselves. Only `LS.10` needs Docker, and only for the on-demand Antora build.

## Two warnings for whoever resumes

**`LS.5` rewrites the buffer.** It deliberately triggers F# format-on-save, which is the most significant effect of this change and has no diff behind it — `lua/plugins/conform.lua:10` already said `fsharp = { lsp_format = "prefer" }` and was inert for want of the binary. Copy the fixture first: `cp testdocs/hello.fs /tmp/hello.fs.bak`. If the formatting result is unwelcome, that is a finding worth recording, and the fix would be dropping `fsharp` from `conform.lua` — but it should be a deliberate call.

**`LS.3` and `LS.7` assert that nothing changed.** LS.3 proves installing marksman did not alter markdown folding (it advertises no `foldingRangeProvider`); LS.7 proves F# indentation is still broken, which is a known gap and explicitly out of scope. Both are easy to skip because nothing is expected to happen, and both are where a regression would hide.

## Remaining after validation

1. Close-out tasks 5.1–5.3 in `openspec/changes/install-language-servers/tasks.md` — strip the entry from the `ideas.md` queue, delete the stale `indentexpr` entry that is still under *Things that seem broken* despite being shipped, and after archiving hand-correct the Purpose of `openspec/specs/code-folding/spec.md`, which still claims treesitter folding is disabled and markdown uses indent only. `openspec archive` never touches Purpose prose.
2. Push, PR, review, squash-merge, archive.
3. Delete this file.

## Queue after this change

1. **blink spell suggestions are filtered out** — logged on `main` as `56b841b`, queue position 1. `cmp-spell` sets each suggestion's `filterText` to the suggestion itself, and blink filters on `filterText`, so a correction never matches its own misspelling: 0 of 5 suggestions survive today, 5 of 5 with `keep_all_entries = true` at `lua/plugins/blink.lua:83`. **Try native `<C-x>s` first** — that lead is untested and could make the change unnecessary. The treeview part of the original report was a red herring: normal-mode `<C-n>` is `:NvimTreeOpen` (`lua/keymaps.lua:99`), and blink's keys are insert-mode and buffer-local.
2. Fourteen capability specs with placeholder Purposes.
3. `open_url` never reaches `open` on macOS — understood, needs a Mac to verify.

## Standing conventions

- The user runs `git push`, `gh pr create` and `gh pr merge`; echo the commands, never execute them.
- No PR until every test-plan box is genuinely ticked.
- Prose is one line per paragraph. No arbitrary hard returns.
- `lazy-lock.json`-only commits go straight to `main`, no branch or PR. If `:Lazy sync` finds an upstream update during `Prepare`, that is what to do with it.
- Squash-merge, matching every merge since #171.
