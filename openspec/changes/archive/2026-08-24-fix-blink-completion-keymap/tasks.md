## 1. Confirm the replacement trigger actually works

- [X] 1.1 Before editing anything, verify in a live Neovim session under WSL that the candidate trigger reaches Neovim, via a temporary `vim.keymap.set({"i","c"}, <key>, function() vim.notify("reached") end)`. This is the whole premise of the change — if the key is swallowed like `Alt-Space`, stop and pick a different trigger before writing any config.

  > **Result: `<C-Space>` FAILED this check.** Tested live in the target WSL console: the notification never fired, so `<C-Space>` is swallowed exactly as `Alt-Space` is. Per the stop rule above, no config was written against it. Trigger changed to **`<C-n>`**, taking on `show` in addition to `select_next` — a plain `Ctrl`-plus-letter chord, which is the fallback `design.md` nominated. Artifacts updated: proposal key table, design D2, and the `completion-engine` delta spec. See design.md D2 for the full rationale and the rejected alternatives (`<C-l>`, both, `<C-x>`).

- [X] 1.2 Confirm the chosen trigger is not claimed by the terminal emulator or window manager in the environment actually used day to day.

  > `<C-n>` is a plain `Ctrl`-plus-letter chord — nothing for a Windows console to reserve, unlike the `Alt`/`Space` chords that failed. Also confirmed free of *config* conflicts in the relevant modes: probed `nvim_get_keymap` for `i` and `c`, and the only existing `<C-n>` bindings are blink's own stock cmdline `select_next` (which this change replaces) and the normal-mode file-tree map in `lua/keymaps.lua:89`, which is a different mode and so cannot collide.

- [X] 1.3 Confirm the `show`/`select_next` double duty is actually safe in blink, rather than assuming it. Read the installed source: `cmp.show()` returns `true` only when the menu is closed and `nil` when it is already open (`lua/blink/cmp/init.lua:67`), and the keymap dispatcher consumes the key only on a truthy return, otherwise trying the next command in the list (`lua/blink/cmp/keymap/apply.lua:62-63`). So `{ "show", "select_next", "fallback" }` shows on a closed menu and selects on an open one.

## 2. Rewrite the keymap in `lua/plugins/blink.lua`

- [X] 2.1 Define the shared keymap once as a local table: `<C-n>` = `{ "show", "select_next", "fallback" }`, `<C-p>` select_prev, `<C-y>` `select_and_accept`, `<C-e>` `cancel`, `<C-k>` `show_documentation`, `<C-b>`/`<C-f>` scroll docs — each ending in a `"fallback"` entry. Note `<C-n>` takes **three** commands in order; the other keys take one plus the fallback.
- [X] 2.2 Assign it to `opts.keymap` with `preset = "none"`, replacing the current table. Remove the `<M-Space>` and `<CR>` entries.
- [X] 2.3 Assign the same table to `opts.cmdline.keymap` with `preset = "none"`, replacing `preset = "cmdline"`.
- [X] 2.4 Update the comment at `lua/plugins/blink.lua:57` — it currently explains why cmdline needs its own preset, which stops being true. Replace it with a note that both modes share one table deliberately.
- [X] 2.5 Leave `completion.list.selection` (`preselect = false, auto_insert = false`) untouched; `select_and_accept` depends on it staying as-is.
- [X] 2.6 Syntax-check: `find . -name '*.lua' -print0 | xargs -0 luac -p`.

## 3. Update the documentation surfaces

- [X] 3.1 `docs/modules/ROOT/pages/editor/keybindings.adoc:306` — replace the `Alt-Space` row; add the accept, cancel, and select keys.
- [X] 3.2 `docs/modules/ROOT/pages/editor/code-intelligence.adoc:170` — same, and state plainly that `<CR>` does not accept.
- [X] 3.3 `cheatsheets/core.md:172` — same. This is the `<leader>?` in-editor surface, so it must not drift from the other two.
- [X] 3.4 State the accept key for **both** insert and command line. All three surfaces currently document `Enter` as the insert-mode accept key and say nothing at all about the command line — so each one is wrong twice over after this change, and both halves need correcting.
- [X] 3.4a Fix the stale `cheatsheets/core.md:168` heading — it still reads "Auto-Completion (nvim-cmp)" although blink replaced nvim-cmp in change 03.
- [X] 3.4b `code-intelligence.adoc:180-181` carries a prose note that "`Enter` only inserts when an entry is actively highlighted — it will not accidentally confirm the first suggestion (`preselect = false`)". That sentence becomes false; rewrite it around `<C-y>` and the fact that `Enter` now never accepts.
- [X] 3.4c Document the `<C-n>` double duty explicitly — that the same key opens the menu and then walks it — rather than listing it only as "select next". A reader who sees just "select next" will not know how to open the menu at all.
- [X] 3.5 Call out the `<CR>` change prominently, not as a table row. Anyone with existing muscle memory will hit it first.
- [X] 3.6 Grep for `M-Space`, `Alt-Space`, and `Alt+Space` across `docs/` and `cheatsheets/`; the count must be zero.
- [X] 3.7 Rebuild the site: `./docker/antora/run.sh antora-playbook.yml` — confirm no AsciiDoc/xref errors. Run `rm -rf build/site` first; Antora does not prune.

## 4. Log the deferred snippet gap

- [X] 4.1 Add an entry to `recommendations/ideas.md`: `snippet_forward` / `snippet_backward` are bound nowhere despite `snippets` being an active source (`lua/plugins/blink.lua:26`), so snippet placeholders cannot be navigated. Explicitly out of scope here.

## 5. Manual validation (required — this is a runtime change)

- [X] 5.1 Add a `## Change · fix-blink-completion-keymap` section to `openspec/TEST_PLAN.md` following the structure of the existing `Change NN` sections (branch name, prerequisites, then numbered Prepare / Validate / Raise PR & merge / Post-merge subsections).
- [X] 5.2 Validate in a live session — insert mode: `<C-n>` with the menu closed opens it **with nothing highlighted**; `<C-n>` again selects the first item; further `<C-n>`/`<C-p>` move; `<C-y>` accepts the highlighted item; `<C-y>` with nothing highlighted accepts the top item; `<C-e>` dismisses and restores the typed text; `<C-b>`/`<C-f>` scroll the doc window; `<CR>` inserts a newline and accepts nothing.
- [X] 5.3 Validate on the command line — the same keys do the same things at the `:` prompt; `<CR>` still executes the command; `/` search completion still offers buffer words.
- [X] 5.4 Specifically exercise `<Tab>` at the `:` prompt and record whether losing blink's `<Tab>` selection is acceptable (design.md Open Question). If it is missed, add `<Tab>` to the shared table as a select-next alias.
- [X] 5.5 Confirm the no-auto-select behavior survives: opening the menu highlights nothing until `<C-n>` is pressed.
- [X] 5.6 Check the lisp-family filetypes still get Conjure completions and that spell completions still appear only with `spell` on — both ride on the same menu and are covered by other requirements in this capability.
- [X] 5.7 Check `<C-n>` in normal mode still opens the file tree — the shared keymap binds `<C-n>` in insert and cmdline only. This matters more now that `<C-n>` is the trigger: the two meanings sit on one key separated only by mode.
- [X] 5.7a Check command-line history recall at the `:` prompt. Native `<C-n>` recalls the next history entry; blink's stock preset already shadowed it with `select_next` before this change, and `auto_show` means the menu is usually open, so `show` should return `nil` and the key should behave as it does today. Confirm history recall still works in the states where blink declines (the `"fallback"` entry), and record the behavior either way — this is the one place the double duty could plausibly annoy.
- [X] 5.8 Tick each TEST_PLAN box only once genuinely confirmed, logging any defect and its fix inline as a blockquote note.

> Walked live as TEST_PLAN `BC.1`-`BC.12`; outcomes and verdicts are recorded there in full.
> Three things worth carrying here:
>
> - **5.2's own wording was wrong and has been corrected in TEST_PLAN.** It says `<C-n>` opens the
>   menu and a second press selects the first item. That only holds from a *closed* menu.
>   `completion.trigger.show_on_keyword` is on, so while typing a word the menu is already open and
>   `cmp.show()` returns nil, falling through to `select_next` — the **first** press selects item 1.
>   All three doc surfaces repeated the same error and were fixed.
> - **5.4 verdict: keep the native wildmenu, do not bind `<Tab>`.** It is not a dead key —
>   `wildmode=full` completes to the first full match and cycles. Left alone because wildmenu `<Tab>`
>   exists only on the command line, so a habit built on it fails in insert mode, which is the drift
>   this change removes. `design.md`'s Open Question is resolved accordingly.
> - **5.7a verdict: no regression, documented not changed.** `<C-p>` recalls history on an empty
>   prompt via its fallback; `<C-n>` does not, because `show` succeeds and never reaches its
>   fallback. `<Up>`/`<Down>` remain the proper history keys and filter by typed prefix. Disabling
>   the cmdline fallback was rejected — it needs a mode-specific override, reintroducing the
>   divergence this change exists to remove.
>
> 5.6's Conjure half was recorded **N/A** (no REPL available); the change is keymap-only and touches
> no source wiring. The spell half passed.
>
> Validation also found `<C-f>`/`<C-b>` were **dead keys** — `documentation.auto_show` defaults false
> and nothing bound `show_documentation`, so the window could never open. Fixed by adding `<C-k>`
> plus `:BlinkDocsToggle`; the shared table is now seven keys.

## 6. Ship

- [X] 6.1 Only once every validation step is ticked, push the branch and raise the PR.
- [X] 6.2 Confirm `openspec validate fix-blink-completion-keymap` passes. (`--strict`: valid; full repo `--all --strict`: 41 passed, 0 failed.)
