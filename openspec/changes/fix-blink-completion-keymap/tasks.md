## 1. Confirm the replacement trigger actually works

- [ ] 1.1 Before editing anything, verify in a live Neovim session under WSL that `<C-Space>` reaches Neovim: `:map <C-Space>` shows no existing binding, and a temporary `vim.keymap.set("i", "<C-Space>", function() vim.notify("reached") end)` fires when pressed. This is the whole premise of the change — if the key is swallowed like `Alt-Space`, stop and pick a different trigger before writing any config.
- [ ] 1.2 Confirm `<C-Space>` is not claimed by the terminal emulator or window manager in the environment actually used day to day.

## 2. Rewrite the keymap in `lua/plugins/blink.lua`

- [ ] 2.1 Define the shared keymap once as a local table: `<C-Space>` show, `<C-n>`/`<C-p>` select next/prev, `<C-y>` `select_and_accept`, `<C-e>` `cancel`, `<C-b>`/`<C-f>` scroll docs — each with a `"fallback"` second entry.
- [ ] 2.2 Assign it to `opts.keymap` with `preset = "none"`, replacing the current table. Remove the `<M-Space>` and `<CR>` entries.
- [ ] 2.3 Assign the same table to `opts.cmdline.keymap` with `preset = "none"`, replacing `preset = "cmdline"`.
- [ ] 2.4 Update the comment at `lua/plugins/blink.lua:57` — it currently explains why cmdline needs its own preset, which stops being true. Replace it with a note that both modes share one table deliberately.
- [ ] 2.5 Leave `completion.list.selection` (`preselect = false, auto_insert = false`) untouched; `select_and_accept` depends on it staying as-is.
- [ ] 2.6 Syntax-check: `find . -name '*.lua' -print0 | xargs -0 luac -p`.

## 3. Update the documentation surfaces

- [ ] 3.1 `docs/modules/ROOT/pages/editor/keybindings.adoc:306` — replace the `Alt-Space` row; add the accept, cancel, and select keys.
- [ ] 3.2 `docs/modules/ROOT/pages/editor/code-intelligence.adoc:170` — same, and state plainly that `<CR>` does not accept.
- [ ] 3.3 `cheatsheets/core.md:172` — same. This is the `<leader>?` in-editor surface, so it must not drift from the other two.
- [ ] 3.4 State the accept key for **both** insert and command line. No page currently documents an accept key for either mode — this is the documentation half of defect 2.
- [ ] 3.5 Call out the `<CR>` change prominently, not as a table row. Anyone with existing muscle memory will hit it first.
- [ ] 3.6 Grep for `M-Space`, `Alt-Space`, and `Alt+Space` across `docs/` and `cheatsheets/`; the count must be zero.
- [ ] 3.7 Rebuild the site: `./docker/antora/run.sh antora-playbook.yml` — confirm no AsciiDoc/xref errors. Run `rm -rf build/site` first; Antora does not prune.

## 4. Log the deferred snippet gap

- [ ] 4.1 Add an entry to `recommendations/ideas.md`: `snippet_forward` / `snippet_backward` are bound nowhere despite `snippets` being an active source (`lua/plugins/blink.lua:26`), so snippet placeholders cannot be navigated. Explicitly out of scope here.

## 5. Manual validation (required — this is a runtime change)

- [ ] 5.1 Add a `## Change · fix-blink-completion-keymap` section to `openspec/TEST_PLAN.md` following the structure of the existing `Change NN` sections (branch name, prerequisites, then numbered Prepare / Validate / Raise PR & merge / Post-merge subsections).
- [ ] 5.2 Validate in a live session — insert mode: `<C-Space>` opens the menu; `<C-n>`/`<C-p>` move; `<C-y>` accepts the highlighted item; `<C-y>` with nothing highlighted accepts the top item; `<C-e>` dismisses and restores the typed text; `<C-b>`/`<C-f>` scroll the doc window; `<CR>` inserts a newline and accepts nothing.
- [ ] 5.3 Validate on the command line — the same keys do the same things at the `:` prompt; `<CR>` still executes the command; `/` search completion still offers buffer words.
- [ ] 5.4 Specifically exercise `<Tab>` at the `:` prompt and record whether losing blink's `<Tab>` selection is acceptable (design.md Open Question). If it is missed, add `<Tab>` to the shared table as a select-next alias.
- [ ] 5.5 Confirm the no-auto-select behavior survives: opening the menu highlights nothing until `<C-n>` is pressed.
- [ ] 5.6 Check the lisp-family filetypes still get Conjure completions and that spell completions still appear only with `spell` on — both ride on the same menu and are covered by other requirements in this capability.
- [ ] 5.7 Check `<C-n>` in normal mode still opens the file tree — the shared keymap binds `<C-n>` in insert and cmdline only.
- [ ] 5.8 Tick each TEST_PLAN box only once genuinely confirmed, logging any defect and its fix inline as a blockquote note.

## 6. Ship

- [ ] 6.1 Only once every validation step is ticked, push the branch and raise the PR.
- [ ] 6.2 Confirm `openspec validate fix-blink-completion-keymap` passes.
