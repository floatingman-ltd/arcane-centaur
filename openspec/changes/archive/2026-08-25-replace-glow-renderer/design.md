## Context

Three surfaces render markdown through `glow`, and all three inherit its wrapping defect (see `proposal.md` for the investigation):

- **`<leader>?` cheatsheet** — `lua/config/cheatsheet.lua` concatenates `cheatsheets/core.md` with a filetype sheet, writes `stdpath("cache")/cheatsheet_preview.md`, and calls `glow_open()` → `:Glow <path>`. `open_guide()` uses the same helper for the mini-guides.
- **`<localleader>pp`** — forced popup preview, `:Glow` on the current buffer, guarded by a `vim.fn.executable("glow")` check.
- **`<localleader>p`** — routes on `require("config.terminal").is_console`: console → `:Glow`, GUI → `:MarkdownPreviewToggle` (browser). Only the console branch is in scope.

`glow.nvim` supplies both the renderer *and* the floating window. It shells out to the `glow` binary, passes `min(0.7 × columns, config.width)` as both the float width and glow's `-w`, and pipes the ANSI output into a terminal channel via `nvim_open_term` (`glow.nvim/lua/glow.lua:95-141`). Removing glow therefore means replacing the window as well as the renderer — they are one component today.

Two constraints shape the design:

- `after/ftplugin/markdown.lua:7` already calls `vim.treesitter.start()`, and the `markdown` and `markdown_inline` parsers are installed. Native rendering has what it needs.
- Prose in this repo is written **one line per paragraph** (no hard wrapping) precisely because renderers reflow. That convention only pays off if the renderer wraps correctly.

## Goals / Non-Goals

**Goals:**

- Prose wraps correctly at any width, with no orphaned words, and reflows when the window resizes.
- Remove the `glow` binary as a runtime dependency, and with it the `executable("glow")` guards and the "install glow" documentation.
- Keep the three surfaces feeling the same: same keys, same centred float, same border, same `q`/`<Esc>` dismissal.
- One rendering path shared by the cheatsheet, the mini-guides and the popup preview, so they cannot drift apart the way the completion keymaps did.

**Non-Goals:**

- The GUI branch of `<localleader>p` (`markdown-preview.nvim`, browser-based) is untouched.
- `<localleader>sp` (markserv/Docker server preview) is untouched.
- AsciiDoc rendering. `markview.nvim` was deferred here for want of `cathaysia/tree-sitter-asciidoc`; that is unrelated and stays deferred.
- Changing cheatsheet *content*, or the concatenation logic in `cheatsheet.lua`.
- Fixing glow upstream.

## Decisions

**D1 — Use `render-markdown.nvim` as the renderer.**

- _Why:_ it renders in a normal buffer using the treesitter parsers already installed, so Neovim owns the wrapping — which is the entire point of the change. It draws tables as boxes, so the cheatsheet (which is overwhelmingly tables) does not visually regress against glow. It needs no external binary and no ANSI handling.
- _Alternative rejected — `markview.nvim`:_ comparable and richer, but richer presentation is not the problem being solved, and its larger surface area is more to go wrong on the one config it must not break.
- _Alternative rejected — no plugin at all_ (plain markdown buffer, `vim.treesitter.start()`, `wrap`). Genuinely tempting: zero new dependency, and it fixes wrapping outright. Declined because tables would render as raw `| key | action |` pipe text. On a surface that is ~90% tables that trades glow's prose defect for a table regression, which is not obviously a win. Worth revisiting if `render-markdown.nvim` disappoints — the fallback is cheap.
- _Note:_ `render-markdown.nvim` also renders markdown buffers during ordinary editing, which is a side benefit rather than a reason.

**D2 — Own the float; do not look for a drop-in `glow.nvim` replacement.**

The window and the renderer are separable now, so `lua/config/cheatsheet.lua` grows a small `open_float(path)` helper: create a scratch buffer, read the file, set `filetype=markdown` so the renderer attaches, open a centred `nvim_open_win`, and map `q`/`<Esc>` to close. Geometry copies today's values so nothing moves on screen.

- _Why:_ glow.nvim's float exists only to host a terminal channel for ANSI output. With in-buffer rendering there is nothing to host, and a normal buffer is what makes `wrap` work.
- _Consequence:_ `lua/plugins/plantuml.lua:40,60` mirrors "glow.nvim popup geometry" for its own preview. It must keep its current geometry; only the stale comment changes.

**D3 — `wrap` and `linebreak` on, `nowrap` rejected.**

- _Why:_ `wrap` is what fixes the defect. `linebreak` breaks at word boundaries rather than mid-word, and `breakindent` keeps continuation lines aligned.
- _On tables:_ a table row wider than the float will wrap and look broken, because Vim cannot wrap prose and scroll tables in the same window. Measured: the widest table row across all six cheatsheets is **82 columns**, against a float of `min(0.7 × columns, 120)` — 120 on a typical terminal. Tables fit with room to spare and this is a non-issue for the cheatsheet at normal sizes. It bites only below roughly a 118-column terminal, and for `<localleader>pp` on arbitrary files whose tables can be any width. Accepted: glow currently mangles *all* prose at *every* width, so this is strictly less bad.

**D4 — One rendering entry point for all three surfaces.**

`open_float(path)` serves the cheatsheet, `open_guide()`, and the popup preview. `<localleader>pp` writes nothing new — it points the float at the current buffer's file.

- _Why:_ the completion-keymap change was raised because two code paths for the same job drifted. Three call sites sharing one helper cannot.

**D5 — `:Glow` is removed and replaced by `:MarkdownPopup`.**

- _Why:_ the command belongs to the plugin being removed. A named replacement keeps the capability reachable outside the `<localleader>` maps.
- _Migration:_ **BREAKING**, called out in the proposal. It must be stated prominently in the docs, not left as a table row — muscle memory is the thing being broken.
- _Dropped along with it:_ both `vim.fn.executable("glow")` guards in `after/ftplugin/markdown.lua` and their "install glow" notifications, plus the binary's prerequisite entries in the docs.

## Risks / Trade-offs

- **The renderer may not attach to a scratch buffer.** `render-markdown.nvim` attaches by filetype, and a scratch buffer with `filetype=markdown` should qualify — but the cheatsheet is a generated, unnamed buffer, which is the least-trodden path. → Verify first, before any docs are rewritten. If it only attaches to real files, render from the cache file as a named buffer instead; the file is already written to `stdpath("cache")`.
- **Tables wider than the float wrap.** → Quantified under D3 and accepted. If it proves annoying in practice, the escape hatch is a `nowrap` toggle bound inside the float, not a redesign.
- **`:Glow` removal breaks habits.** → Prominent doc callout plus a named replacement command. The same treatment the `<leader>t` move got.
- **Losing glow's styling.** glow applies a full stylesheet; `render-markdown.nvim` themes from the colorscheme. The cheatsheet will look different even where it does not look worse. → Cosmetic, and TokyoNight integration is arguably more consistent with the rest of the editor.
- **A new plugin on a lazy-loaded config.** → Load it on `ft = markdown` plus the commands that need it, matching how glow.nvim was specced.
- **Reduced-width terminal defect is unrelated.** `recommendations/ideas.md` records a separate defect where the terminal opens narrow from inside the tree. Nothing here touches it; noted only so the two are not conflated during testing.

## Migration Plan

1. Add `render-markdown.nvim` to `lua/plugins/markdown.lua`; leave `glow.nvim` in place initially so both can be compared side by side.
2. **Verify the scratch-buffer question** (first risk above) before anything else — it decides whether `open_float` reads into a scratch buffer or opens the cache file directly.
3. Add `open_float(path)` to `lua/config/cheatsheet.lua` and point `open_cheatsheet()` and `open_guide()` at it.
4. Re-point `<localleader>pp` and the console branch of `<localleader>p`; add `:MarkdownPopup`; drop the `executable("glow")` guards.
5. Remove `glow.nvim`, and the `glow` prerequisite from the docs.
6. Fix the stale glow references in `lua/plugins/plantuml.lua` (comments only) and `lua/plugins/ufo.lua:8`, and confirm the new float does not reproduce the special-buffer folding problem that comment describes.
7. Docs: `content/markdown.adoc` and its cheatsheet, `getting-started.adoc`, `cheatsheets/core.md`, `cheatsheets/markdown.md`, `other/architecture.adoc`.

**Rollback:** steps 1-5 are additive until step 5 deletes the glow spec, so reverting is a single-commit revert at any point before that, and a re-add of one plugin spec after.

## Open Questions

- ~~**Does `<localleader>pp` still make sense?**~~ **Resolved during validation (TEST_PLAN RG.11): no — it is now a render toggle.** With rendering live in the buffer, a popup of the same content was ceremony; toggling between rendered output and raw markup is the useful operation. The popup remains on `,p` (console) and `:MarkdownPopup` (anywhere). This did require the `markdown-popup-preview` delta the proposal had avoided, which was the right trade once the alternative was judged with the tool in front of us rather than guessed at.
- ~~**Should the cheatsheet float be scrollable-by-default with `nowrap` available on a key?**~~ **Resolved during validation (TEST_PLAN RG.4): no.** The terminal runs full-screen almost always, so the float sits at its 120-column cap against a widest table of 82 — the wrap case needs a sub-118-column terminal, which does not occur in practice. A toggle would be an extra key and an extra state serving a situation that does not arise. The behaviour stays documented as a CAUTION in `content/markdown.adoc` in case it is ever met.
