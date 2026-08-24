## 1. Settle the load-bearing unknown first

- [ ] 1.1 Add `render-markdown.nvim` to `lua/plugins/markdown.lua` alongside `glow.nvim` — do **not** remove glow yet. Lazy-load on `ft = markdown` plus the commands that will need it, mirroring how `glow.nvim` is specced.
- [ ] 1.2 **Verify the renderer attaches to an unnamed scratch buffer.** Create a scratch buffer, set `filetype=markdown`, put cheatsheet content in it, show it in a float, and confirm it renders. This decides the shape of everything below and is the one thing that could invalidate the design (design.md, first risk).
- [ ] 1.3 If 1.2 fails, fall back to opening the cache file (`stdpath("cache")/cheatsheet_preview.md`) as a **named** buffer in the float — `cheatsheet.lua` already writes it. Record which path was taken and why, in the change record.
- [ ] 1.4 Compare side by side against glow while both are installed: cheatsheet tables, headings, inline code, and a long prose paragraph. Confirm the paragraph wraps with **no orphaned words** — the defect this change exists to fix.

## 2. Build the shared float

- [ ] 2.1 Add `open_float(path)` to `lua/config/cheatsheet.lua`: scratch (or named, per 1.3) buffer, `filetype=markdown`, centred `nvim_open_win`, rounded border, geometry matching today's `min(0.7 * columns, 120)` by `min(0.7 * lines, 80)` so nothing moves on screen.
- [ ] 2.2 Set `wrap`, `linebreak` and `breakindent` on the float (design D3). Set `bufhidden=wipe` and a distinct filetype or buffer-local marker so other plugins can identify it.
- [ ] 2.3 Map `q` and `<Esc>` to close, and confirm focus returns to the previous window — both are existing `context-aware-cheatsheet` requirements.
- [ ] 2.4 Point `open_cheatsheet()` and `open_guide()` at `open_float()`; delete `glow_open()`. All three surfaces share one entry point (design D4).

## 3. Re-point the preview keymaps

- [ ] 3.1 Add a `:MarkdownPopup` user command that renders the current buffer's file through `open_float()` (design D5).
- [ ] 3.2 Re-point `<localleader>pp` in `after/ftplugin/markdown.lua` at the new popup, and **delete its `vim.fn.executable("glow")` guard and install-instruction notification**.
- [ ] 3.3 Re-point the console branch of `<localleader>p` at the new popup and delete its `executable("glow")` guard. Leave the GUI branch (`MarkdownPreviewToggle`) untouched — explicitly a non-goal.
- [ ] 3.4 Leave `<localleader>sp` (markserv/Docker) untouched.

## 4. Remove glow

- [ ] 4.1 Remove the `glow.nvim` spec from `lua/plugins/markdown.lua`.
- [ ] 4.2 Fix the stale comments in `lua/plugins/plantuml.lua:40,60` that describe mirroring "glow.nvim popup geometry". The PlantUML preview must keep its **current** geometry — only the wording changes.
- [ ] 4.3 Check `lua/plugins/ufo.lua:8`, which cites glow as an example of a special buffer where treesitter folding errors. Confirm the new float does not reproduce that problem, then correct the comment.
- [ ] 4.4 `find . -name '*.lua' -print0 | xargs -0 luac -p` and `stylua --check` on every touched file.

## 5. Update the documentation

- [ ] 5.1 `docs/modules/ROOT/pages/content/markdown.adoc` — replace the glow section with in-editor rendering; remove `glow` from prerequisites; document `:MarkdownPopup`.
- [ ] 5.2 `docs/modules/ROOT/pages/content/markdown-cheatsheet.adoc` — same, and update any `:Glow` rows.
- [ ] 5.3 `docs/modules/ROOT/pages/getting-started.adoc` — remove `glow` from the prerequisite list.
- [ ] 5.4 `docs/modules/ROOT/pages/other/architecture.adoc` — replace the `glow.nvim` entry with the new renderer.
- [ ] 5.5 `docs/modules/ROOT/pages/editor/keybindings.adoc` and `cheatsheets/markdown.md` — update `:Glow` keybinding rows.
- [ ] 5.6 `_readme.adoc` and `TODO.md` — check and update their glow mentions.
- [ ] 5.7 `testdocs/ide-layout-verification.md` — a still-runnable checklist that names `:Glow`; update so it stays runnable, as was done for `<leader>T`.
- [ ] 5.8 **Call the `:Glow` removal out prominently**, not as a table row — it is BREAKING and breaks muscle memory. Same treatment the `<leader>t` move got.
- [ ] 5.9 Review the live specs that mention glow incidentally and are **not** covered by this change's deltas: `openspec/specs/asciidoc-inbuffer-preview/spec.md`, `code-folding/spec.md`, `ide-layout/spec.md`. Decide per case whether the mention is now wrong or merely historical; raise a follow-up if any needs a delta of its own rather than editing them here.
- [ ] 5.10 `grep -rn -i 'glow' --include='*.lua' --include='*.md' --include='*.adoc' .` excluding `build/` and `openspec/changes/archive/` — confirm every remaining hit is intentional.
- [ ] 5.11 Rebuild the site: `rm -rf build/site && ./docker/antora/run.sh antora-playbook.yml`. Expect exit 0 and only the five known pre-existing `{name}`/`{pat}`/`{feed}` attribute warnings.

## 6. Manual validation (required — this is a runtime change)

- [ ] 6.1 Add a `## Change · replace-glow-renderer` section to `openspec/TEST_PLAN.md`, following the existing sections' structure (branch, prerequisites, then numbered Prepare / Validate / Raise PR & merge / Post-merge).
- [ ] 6.2 Validate the wrapping fix directly: open `<leader>?` and read the Auto-Completion prose paragraphs. **No orphaned single words.** This is the whole point — compare against the pre-change behaviour if in doubt.
- [ ] 6.3 Resize the editor with the float open — confirm the content reflows. glow could never do this, so it is new behaviour, not a regression check.
- [ ] 6.4 Confirm cheatsheet tables render with visible column structure and are not truncated or wrapped mid-cell at a normal terminal width.
- [ ] 6.5 Check a **narrow** terminal (under ~118 columns), where tables are expected to wrap (design D3). Record whether the degradation is acceptable, and answer the design's open question about a `nowrap` toggle in the float.
- [ ] 6.6 `<leader>?` from several filetypes — confirm the language sheet is still appended below the core sheet, and mini-guides (`<leader>?g`) still open.
- [ ] 6.7 `q` and `<Esc>` both dismiss the float and return focus to the previous window.
- [ ] 6.8 `<localleader>pp` and console `<localleader>p` open the popup; `:MarkdownPopup` works. Confirm **no** "glow not found" notification can appear anywhere.
- [ ] 6.9 Answer the design's other open question: with rendering available in-buffer, does `<localleader>pp` still earn its keep as a popup, or should it become a render toggle? Decide with the tool in front of you and record the verdict.
- [ ] 6.10 Fresh `nvim` — `:messages` shows no plugin, LSP or keymap **errors**. It will not be empty: lazy.nvim's update checker reports available updates at every startup, which is expected.
- [ ] 6.11 Tick each TEST_PLAN box only once genuinely confirmed, logging any defect and its fix inline as a blockquote note.

## 7. Ship

- [ ] 7.1 Only once every validation step is ticked, push the branch and raise the PR.
- [ ] 7.2 Confirm `openspec validate replace-glow-renderer --strict` passes, and `--all --strict` alongside it.
- [ ] 7.3 At archive time, watch the `markdown-preview-glow` retirement: this change removes **every** requirement from that capability. Commit before archiving so a partial spec write can be recovered — archiving is known not to be atomic in this repo.
