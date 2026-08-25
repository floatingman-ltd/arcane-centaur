## 1. Settle the load-bearing unknown first

- [x] 1.1 Add `render-markdown.nvim` to `lua/plugins/markdown.lua` alongside `glow.nvim` — do **not** remove glow yet. Lazy-load on `ft = markdown` plus the commands that will need it, mirroring how `glow.nvim` is specced.
- [x] 1.2 **Verify the renderer attaches to an unnamed scratch buffer.** Create a scratch buffer, set `filetype=markdown`, put cheatsheet content in it, show it in a float, and confirm it renders. This decides the shape of everything below and is the one thing that could invalidate the design (design.md, first risk).
- [x] 1.3 ~~If 1.2 fails, fall back to opening the cache file as a **named** buffer.~~ **Not needed — 1.2 passed.** The unnamed scratch buffer renders: 166 extmarks in the `render-markdown.nvim` namespace on a `buftype=nofile`, unnamed buffer. `nofile` is supported by the plugin's own defaults (`overrides.buftype.nofile` sets `render_modes = true` and disables signs).
- [x] 1.4 ~~Compare side by side against glow while both are installed.~~ **Satisfied by RG.1 + RG.3 instead.** The literal side-by-side was overtaken by events: the structural check in 1.2 showed the paragraph stays a single 270-character buffer line with Neovim wrapping at display time, which makes orphaning impossible rather than merely absent — so a comparison could only confirm what the mechanism already guaranteed. glow was removed in 4.1 before the visual pass happened. Live confirmation came instead from RG.1 (prose wraps with no orphaned words) and RG.3 (tables keep visible column structure, nothing truncated or wrapped mid-cell).

> **Implementation constraint found in 1.2 — attach order matters.** Setting `filetype=markdown`
> *before* the buffer is displayed in a window leaves the renderer **unattached** (0 extmarks). It
> attaches only when the filetype is set *after* `nvim_open_win`, followed by
> `require("render-markdown.api").buf_enable()`. `open_float()` must do it in that order, and the
> order needs a comment saying why — it reads like an arbitrary sequence and will otherwise be
> "tidied" back into a silent failure.

## 2. Build the shared float

- [x] 2.1 Add `open_float(path)` to `lua/config/cheatsheet.lua`: scratch (or named, per 1.3) buffer, `filetype=markdown`, centred `nvim_open_win`, rounded border, geometry matching today's `min(0.7 * columns, 120)` by `min(0.7 * lines, 80)` so nothing moves on screen.
- [x] 2.2 Set `wrap`, `linebreak` and `breakindent` on the float (design D3). Set `bufhidden=wipe` and a distinct filetype or buffer-local marker so other plugins can identify it.
- [x] 2.3 Map `q` and `<Esc>` to close, and confirm focus returns to the previous window — both are existing `context-aware-cheatsheet` requirements.
- [x] 2.4 Point `open_cheatsheet()` and `open_guide()` at `open_float()`; delete `glow_open()`. All three surfaces share one entry point (design D4).

> **Two deliberate deviations from the task text, both simplifications.**
>
> `open_float` takes **lines, not a path**. The cheatsheet already holds its combined content in
> memory, and taking lines means `:MarkdownPopup` can render an **unsaved** buffer — something glow
> could never do, since it needed a file on disk.
>
> Consequently the `stdpath("cache")/cheatsheet_preview.md` temp file is **gone**. It existed only to
> give glow a path to read. Nothing else referenced it.
>
> Verified end to end: float 120x35 rounded, `filetype=markdown`, `buftype=nofile`,
> `modifiable=false`, `wrap`/`linebreak`/`breakindent` on, 166 render extmarks attached, `q` mapped
> buffer-locally.

## 3. Re-point the preview keymaps

- [x] 3.1 Add a `:MarkdownPopup` user command that renders the current buffer's file through `open_float()` (design D5).
- [x] 3.2 Re-point `<localleader>pp` in `after/ftplugin/markdown.lua` at the new popup, and **delete its `vim.fn.executable("glow")` guard and install-instruction notification**.
- [x] 3.3 Re-point the console branch of `<localleader>p` at the new popup and delete its `executable("glow")` guard. Leave the GUI branch (`MarkdownPreviewToggle`) untouched — explicitly a non-goal.
- [x] 3.4 Leave `<localleader>sp` (markserv/Docker) untouched.

> **Bug found and fixed while implementing 3.1.** The command was first registered at module level
> in `lua/config/cheatsheet.lua` — but that module is only `require`d lazily from the `<leader>?`
> callback, so `:MarkdownPopup` did not exist until the cheatsheet had been opened once, and
> `<localleader>pp` failed with `E492: Not an editor command`. Moved to `lua/keymaps.lua`, which
> loads at startup and already hosts `:Bd`; the `require` stays inside the callback so the module
> itself remains lazily loaded. Worth noting because `:Glow` came from a `cmd`-lazy plugin spec and
> was therefore always defined — the lazy-loading guarantee did not survive the move, and nothing
> would have caught it except trying the command from a fresh session.

## 4. Remove glow

- [x] 4.1 Remove the `glow.nvim` spec from `lua/plugins/markdown.lua`.
- [x] 4.2 Fix the stale comments in `lua/plugins/plantuml.lua:40,60` that describe mirroring "glow.nvim popup geometry". The PlantUML preview must keep its **current** geometry — only the wording changes.
- [x] 4.3 Check `lua/plugins/ufo.lua:8`, which cites glow as an example of a special buffer where treesitter folding errors. Confirm the new float does not reproduce that problem, then correct the comment.
- [x] 4.4 `find . -name '*.lua' -print0 | xargs -0 luac -p` and `stylua --check` on every touched file.

> 4.3 verified rather than assumed: the new float is `foldmethod=manual`, fold commands run without
> error, and `:messages` stays clean while it is open — so it does not reproduce the special-buffer
> folding problem the comment described. The indent provider is kept for ordinary markdown buffers.
>
> `lazy-lock.json` carries exactly two edits — `glow.nvim` removed, `render-markdown.nvim` added.
> `:Lazy! sync` twice tried to fold in four unrelated plugin bumps (easy-dotnet, nui, nvim-lspconfig,
> nvim-treesitter); both times they were reverted, since they belong to a lock-sync change. Those
> three-plus updates are still pending and still want their own change.

## 5. Update the documentation

- [x] 5.1 `docs/modules/ROOT/pages/content/markdown.adoc` — replace the glow section with in-editor rendering; remove `glow` from prerequisites; document `:MarkdownPopup`.
- [x] 5.2 `docs/modules/ROOT/pages/content/markdown-cheatsheet.adoc` — same, and update any `:Glow` rows.
- [x] 5.3 `docs/modules/ROOT/pages/getting-started.adoc` — remove `glow` from the prerequisite list.
- [x] 5.4 `docs/modules/ROOT/pages/other/architecture.adoc` — replace the `glow.nvim` entry with the new renderer.
- [x] 5.5 `docs/modules/ROOT/pages/editor/keybindings.adoc` and `cheatsheets/markdown.md` — update `:Glow` keybinding rows.
- [x] 5.6 `_readme.adoc` and `TODO.md` — check and update their glow mentions.
- [x] 5.7 `testdocs/ide-layout-verification.md` — a still-runnable checklist that names `:Glow`; update so it stays runnable, as was done for `<leader>T`.
- [x] 5.8 **Call the `:Glow` removal out prominently**, not as a table row — it is BREAKING and breaks muscle memory. Same treatment the `<leader>t` move got.
- [x] 5.9 Review the live specs that mention glow incidentally and are **not** covered by this change's deltas: `openspec/specs/asciidoc-inbuffer-preview/spec.md`, `code-folding/spec.md`, `ide-layout/spec.md`. Decide per case whether the mention is now wrong or merely historical; raise a follow-up if any needs a delta of its own rather than editing them here.
- [x] 5.10 `grep -rn -i 'glow' --include='*.lua' --include='*.md' --include='*.adoc' .` excluding `build/` and `openspec/changes/archive/` — confirm every remaining hit is intentional.
- [x] 5.11 Rebuild the site: `rm -rf build/site && ./docker/antora/run.sh antora-playbook.yml`. Expect exit 0 and only the five known pre-existing `{name}`/`{pat}`/`{feed}` attribute warnings.

> **5.9 outcome — judged, not edited.** Three live specs reference glow and none are covered by this
> change's deltas. Editing them here would be spec drift, so the verdicts are logged in
> `recommendations/ideas.md` as one small follow-up: `asciidoc-inbuffer-preview:30` and
> `ide-layout:70,73` are **wrong** (both put glow in normative scenarios that can no longer hold) and
> need deltas; `code-folding:48` is **cosmetic** (glow appears only as an illustrative example, and
> the requirement stands).
>
> **Two files were stale beyond this change and only partly repaired.** `_readme.adoc` still
> describes a pre-Antora `docs/guides/` tree that no longer exists; its two plugin rows and one
> console-mode mention were corrected, the rest left. `recommendations/best-of-breed-evaluation.md`
> listed glow.nvim as "KEEP" — annotated as superseded rather than rewritten, since it is a dated
> evaluation record.
>
> Site rebuild verified: exit 0, only the five known pre-existing attribute warnings; the renamed
> `popup-preview` anchor resolves; no `glow-preview` xref remains; `MarkdownPopup` appears in the
> markdown guide, its cheatsheet and the keybindings page; `getting-started.html` has no glow at all.
> The only glow left in the entire built site is the three intentional mentions in the markdown guide.

## 6. Manual validation (required — this is a runtime change)

- [x] 6.1 Add a `## Change · replace-glow-renderer` section to `openspec/TEST_PLAN.md`, following the existing sections' structure (branch, prerequisites, then numbered Prepare / Validate / Raise PR & merge / Post-merge).
- [x] 6.2 Validate the wrapping fix directly: open `<leader>?` and read the Auto-Completion prose paragraphs. **No orphaned single words.** This is the whole point — compare against the pre-change behaviour if in doubt.
- [x] 6.3 Resize the editor with the float open — confirm the content reflows. glow could never do this, so it is new behaviour, not a regression check.
- [x] 6.4 Confirm cheatsheet tables render with visible column structure and are not truncated or wrapped mid-cell at a normal terminal width.
- [x] 6.5 Check a **narrow** terminal (under ~118 columns), where tables are expected to wrap (design D3). Record whether the degradation is acceptable, and answer the design's open question about a `nowrap` toggle in the float.
- [x] 6.6 `<leader>?` from several filetypes — confirm the language sheet is still appended below the core sheet, and mini-guides (`<leader>?g`) still open.
- [x] 6.7 `q` and `<Esc>` both dismiss the float and return focus to the previous window.
- [x] 6.8 `<localleader>pp` and console `<localleader>p` open the popup; `:MarkdownPopup` works. Confirm **no** "glow not found" notification can appear anywhere.
- [x] 6.9 Answer the design's other open question: with rendering available in-buffer, does `<localleader>pp` still earn its keep as a popup, or should it become a render toggle? Decide with the tool in front of you and record the verdict.
- [x] 6.10 Fresh `nvim` — `:messages` shows no plugin, LSP or keymap **errors**. It will not be empty: lazy.nvim's update checker reports available updates at every startup, which is expected.
- [x] 6.11 Tick each TEST_PLAN box only once genuinely confirmed, logging any defect and its fix inline as a blockquote note.

## 7. Ship

- [ ] 7.1 Only once every validation step is ticked, push the branch and raise the PR.
- [x] 7.2 Confirm `openspec validate replace-glow-renderer --strict` passes, and `--all --strict` alongside it.
- [ ] 7.3 At archive time, watch the `markdown-preview-glow` retirement: this change removes **every** requirement from that capability. Commit before archiving so a partial spec write can be recovered — archiving is known not to be atomic in this repo.
