## 1. Check the destination key is free

- [X] 1.1 Grep `lua/` and `after/` for any existing `<leader>T` binding; confirm none. Note that `<leader>t` and `<leader>T` are distinct maps, so the move is safe from Vim's point of view.
- [X] 1.2 Confirm no `<leader>t<something>` map exists that would turn `<leader>t` into a which-key prefix and delay the tree toggle. There is none today — keep it that way.

## 2. Move the keymaps in `lua/keymaps.lua`

- [X] 2.1 Change the terminal binding at line 191 from `<leader>t` to `<leader>T`, keeping `toggle_terminal` and its `desc` ("Toggle terminal split") otherwise untouched.
- [X] 2.2 Add `<leader>t` → `:NvimTreeToggle<CR>` beside the existing tree maps (lines 87–90), with `desc = "File tree: toggle"` to match the `<C-t>` entry.
- [X] 2.3 Leave `<leader>n` and `<C-n>` exactly as they are (design D2). **Revised during validation: the global `<C-t>` toggle is removed** — nvim-tree binds `<C-t>` buffer-locally inside the tree window to *Open: New Tab* (`nvim-tree/keymap.lua:64`), which wins over a global map, so `<C-t>` could open the tree but never close it from inside. Three doc surfaces claimed otherwise; all updated.
- [X] 2.4 Leave `toggle_terminal` and `ide_layout` unmodified — `<leader>L` shares the terminal open path and must keep working.
- [X] 2.5 Syntax-check: `find . -name '*.lua' -print0 | xargs -0 luac -p`.

## 3. Update the documentation surfaces

- [X] 3.1 `docs/modules/ROOT/pages/editor/navigation.adoc:51` — terminal row becomes `<leader>T`.
- [X] 3.2 `docs/modules/ROOT/pages/editor/keybindings.adoc:124` — same.
- [X] 3.3 `cheatsheets/core.md:48` — same. This is the in-editor `<leader>?` surface; if it drifts, the cheatsheet contradicts the running config.
- [X] 3.4 Add the `<leader>t` tree toggle row to the three File Tree tables: `navigation.adoc:117-118`, `keybindings.adoc:71-72`, `cheatsheets/core.md:39-40`.
- [X] 3.5 Call the terminal key move out explicitly rather than only editing a table cell — existing muscle memory will hit it first.
- [X] 3.6 Grep `docs/` and `cheatsheets/` for `<leader>t` and the pandoc-escaped `++<++leader++>++t`; confirm every remaining hit is intentional and none still claims it opens a terminal.
- [X] 3.7 Rebuild the site: `./docker/antora/run.sh antora-playbook.yml` — confirm no AsciiDoc/xref errors. Run `rm -rf build/site` first; Antora does not prune removed pages.

## 4. Manual validation (required — this is a runtime change)

- [X] 4.1 Add a `## Change · fix-tree-terminal-keymaps` section to `openspec/TEST_PLAN.md` following the structure of the existing `Change NN` sections (branch name, prerequisites, then numbered Prepare / Validate / Raise PR & merge / Post-merge subsections).
- [ ] 4.2 Validate the tree in a live session: `<leader>t` opens the tree when closed and closes it when open; `<leader>n` and `<C-n>` open it and leave it open when pressed again; `<C-t>` is unbound outside the tree window (removed — see 2.3).
- [ ] 4.3 Validate the terminal: `<leader>T` opens the full-width bottom split from an editor window *and* from inside the tree window; toggling off and on preserves the shell and its scrollback; the window stays 15 lines when other splits open.
- [ ] 4.4 Confirm `<leader>t` no longer opens a terminal in any state, including after a terminal has already been opened once — the exact scenario in the original report.
- [ ] 4.5 Validate `<leader>L` still assembles the full layout (tree left, terminal bottom, focus in the editor) and is still idempotent.
- [ ] 4.6 Confirm which-key shows both `<leader>t` and `<leader>T` with correct descriptions, and that `<leader>t` fires immediately rather than waiting on a prefix timeout.
- [ ] 4.7 Confirm `:Bd` and the "tree never left as the last window" guardrail still behave — both are `ide-layout` requirements this change must not disturb.
- [ ] 4.8 Tick each TEST_PLAN box only once genuinely confirmed, logging any defect and its fix inline as a blockquote note.

## 5. Ship

- [ ] 5.1 Only once every validation step is ticked, push the branch and raise the PR.
- [X] 5.2 Confirm `openspec validate fix-tree-terminal-keymaps` passes.
