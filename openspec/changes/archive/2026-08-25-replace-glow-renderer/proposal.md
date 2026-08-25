## Why

`glow` mis-wraps prose. It orphans single words onto their own lines, because when a word overflows the target width it emits that word alone and then re-wraps the remaining text as though the word were not there. This affects every markdown surface rendered through glow — the `<leader>?` cheatsheet, `,pp` forced popup preview, and `:Glow` on any markdown buffer.

There is no configuration that avoids it. Orphaning was reproduced at widths 70, 80, 90, 110, 115, 118, 120 and 140; only 100 and 130 came out clean, and only for one specific paragraph, which is coincidence rather than a safe setting. It is independent of markup — inline code spans, emphasis and hyphenated words were each tested and ruled out, and it still reproduces with all markup stripped. A width workaround (120 → 115) was built, validated live, and **failed**; that branch was dropped. `glow -w 0` does disable wrapping, but `glow.nvim` hardcodes `-w win_width` with no config hook and renders through `nvim_open_term`, whose terminal grid would then hard-wrap long lines mid-word — worse than the original defect.

The defect is invisible until someone opens a popup and reads a paragraph, which is why it went unnoticed: every cheatsheet section was tables and short headers until prose was added. Fixing it in the renderer removes an external binary dependency, makes wrapping Neovim's responsibility — which it performs correctly — and gains reflow on window resize, something glow can never do because its output is pre-wrapped before it reaches the buffer.

## What Changes

- Replace `ellisonleao/glow.nvim` with native in-editor markdown rendering (`render-markdown.nvim` or `markview.nvim` — selection deferred to design).
- Render the `<leader>?` cheatsheet as a markdown buffer in a float with `wrap` and `linebreak`, so Neovim performs the wrapping. `lua/config/cheatsheet.lua` keeps its current job of concatenating `cheatsheets/core.md` with the filetype sheet; only the display path changes.
- Re-point the `,pp` forced popup preview at the new renderer.
- **BREAKING**: the `:Glow` command is removed. Any keymap, doc page or habit referring to it must move to the replacement command.
- **BREAKING**: the `glow` binary is no longer a runtime dependency. Documentation that lists it as a prerequisite must be updated.
- Popup geometry, border and dismiss keys (`q`, `<Esc>`) are preserved so the surfaces feel unchanged.
- The rendered popup reflows on window resize — new behaviour, not previously possible.

## Capabilities

### New Capabilities
- `markdown-native-rendering`: in-editor markdown rendering without an external binary — which renderer is used, how it is lazy-loaded, and the guarantee that prose wraps correctly at any window width and reflows on resize.

### Modified Capabilities
- `markdown-preview-glow`: every requirement is glow-specific — the plugin's availability, the binary check, and glow rendering into a floating popup. Superseded wholesale by the new capability; the spec is retired or rewritten rather than amended.
- `markdown-popup-preview`: "glow.nvim loads in all environments" no longer describes the system. `,pp` must still open a forced popup preview from any markdown buffer, and `,p` smart-routing must remain unchanged, but both are now satisfied by a different renderer.
- `context-aware-cheatsheet`: "Float is dismissible and scrollable" gains a wrapping guarantee — prose must wrap without orphaned words and must reflow on resize. "Content files are maintained as plain Markdown" is unaffected and must stay true.

## Impact

**Code**
- `lua/plugins/markdown.lua` — glow.nvim spec removed, replacement added.
- `lua/config/cheatsheet.lua` — `glow_open()` replaced by the new display path; the concatenation and cache-file logic is unchanged.
- `after/ftplugin/markdown.lua` — `,p` / `,pp` keymaps re-pointed.
- `lua/plugins/plantuml.lua` — comments at lines 40 and 60 describe mirroring "glow.nvim popup geometry" and its 70%/120×80 sizing. The PlantUML preview must keep its current geometry; only the stale reference needs correcting.
- `lua/plugins/ufo.lua:8` — a comment cites `glow` as an example of a special buffer where treesitter folding breaks. Verify the replacement's buffer does not reintroduce that problem.

**Dependencies**
- Removes the external `glow` binary (2.1.2, `f570874`) as a runtime prerequisite.
- Adds a Lua plugin dependency, which pins with the rest via `lazy-lock.json`.
- `markview.nvim` was previously deferred in this repo, but only because `cathaysia/tree-sitter-asciidoc` is absent from nvim-treesitter master. That constraint is AsciiDoc-specific and does not apply to markdown.

**Documentation**
- `docs/modules/ROOT/pages/content/markdown.adoc` and its cheatsheet — glow references, the binary prerequisite, and the `:Glow` command.
- `docs/modules/ROOT/pages/getting-started.adoc` — if it lists `glow` as a prerequisite.
- `cheatsheets/core.md` and `cheatsheets/markdown.md` — any `:Glow` keybinding rows.
- `docs/modules/ROOT/pages/other/architecture.adoc` — the glow.nvim entry.

**Risk**
- Tables are the main content of every cheatsheet. `wrap` is what fixes prose but will soft-wrap a table row wider than the float, which would look worse than the defect being fixed. Design must resolve how wide tables behave.
- Removing `:Glow` breaks existing muscle memory; the replacement command should be documented prominently rather than only as a table row.
