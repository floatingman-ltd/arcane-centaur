## Why

AsciiDoc/Antora is the documentation source of truth for this config, yet AsciiDoc is the least-supported filetype in the editor. Today `.adoc` files get Neovim's built-in (slow, regex) `asciidoc` syntax, no folding, no fenced-code-block highlighting, and the only "preview" is the Docker round-trip in `after/ftplugin/asciidoc.lua` (`<localleader>p`/`pp` → Asciidoctor HTML, `<localleader>pa` → full Antora build). The best-of-breed evaluation flags this as the single largest documentation-workflow gap.

This change adds two complementary layers:

- **`habamax/vim-asciidoctor`** — faster, more accurate syntax, code folding, and fenced-code-block highlighting (the always-on reading/editing layer).
- **`OXY2DEV/markview.nvim`** — opt-in in-buffer extmark rendering for AsciiDoc, so a page can be *read* rendered without spinning up Docker (the focused-reading layer).

Cross-validation of the *actual* config surfaced three facts the evaluation glossed over, and they shape this change:

1. **vim-asciidoctor hijacks the filetype.** It ships an `ftdetect` that remaps `*.adoc`/`*.asciidoc` to filetype **`asciidoctor`**, not Neovim's native `asciidoc`. Installed naively, the existing `after/ftplugin/asciidoc.lua` preview maps (`<localleader>p`/`pp`/`pa`) would silently stop firing, because they are keyed to `asciidoc`. This is the central integration problem this change must solve.
2. **The cheatsheet is unaffected.** `lua/config/cheatsheet.lua`'s `ft_map` has *no* `asciidoc` entry, so the filetype rename does not break context-aware cheatsheet resolution. One less thing to touch.
3. **vim-asciidoctor's compile commands duplicate the Docker pipeline.** `Asciidoctor2HTML`/`2PDF`/`2DOCX` overlap with the ftplugin's Docker preview; they are disabled so the Docker flow remains the single conversion path.

## What Changes

- **Add** `habamax/vim-asciidoctor` in a new `lua/plugins/asciidoc.lua`, lazy-loaded on `ft = { "asciidoctor" }`, with its compile commands disabled and folding / fenced-code highlighting enabled, conceal kept conservative.
- **Register the filetype ourselves** via `vim.filetype.add` in the spec's `init` (mapping `adoc`/`asciidoc`/`asciidoctor` extensions → filetype `asciidoctor`), so the mapping is set at startup without eagerly loading the plugin.
- **Rename** `after/ftplugin/asciidoc.lua` → `after/ftplugin/asciidoctor.lua` so the Docker preview maps continue to fire under the new filetype. Map bodies are unchanged.
- **Add** `OXY2DEV/markview.nvim` to the same `lua/plugins/asciidoc.lua` (or a sibling file), scoped to AsciiDoc, **disabled on attach** and driven by a toggle command/keymap, with `preview.filetypes` pointed at `asciidoctor`.
- **Preserve** the existing Docker/Antora preview workflow verbatim; markview is additive, not a replacement.
- **Leave the Markdown workflow untouched** — markview is not enabled for `markdown` here (markdown-preview.nvim + glow already own that), so this change does not perturb `lua/plugins/markdown.lua`.

## Capabilities

### New Capabilities

- `asciidoc-syntax`: fast AsciiDoc syntax highlighting, folding, and fenced-code-block highlighting via vim-asciidoctor, under a single canonical `asciidoctor` filetype that preserves the existing Docker/Antora preview maps.
- `asciidoc-inbuffer-preview`: opt-in, toggle-able in-buffer rendering of AsciiDoc via markview.nvim, complementing (not replacing) the Docker/Antora browser preview.

### Modified Capabilities

<!-- none — AsciiDoc syntax/preview were never captured as OpenSpec requirements; the Docker preview lives only in after/ftplugin and is preserved, not modified -->

## Impact

- **`lua/plugins/asciidoc.lua`** → new (vim-asciidoctor + markview specs).
- **`after/ftplugin/asciidoc.lua`** → renamed to `after/ftplugin/asciidoctor.lua` (Docker preview maps; bodies unchanged).
- **Filetype**: `*.adoc`/`*.asciidoc` now resolve to filetype `asciidoctor` (was `asciidoc`). Anything keyed to `asciidoc` must move to `asciidoctor` — audited: only the ftplugin (handled). `cheatsheet.lua` `ft_map`, `conform.lua`, and `treesitter.lua` `ensure_installed` contain no `asciidoc` entry, so they are unaffected.
- **No global keymaps** in `lua/keymaps.lua` reference AsciiDoc; nothing migrates there. New markview toggle is a `<localleader>` map in the renamed ftplugin (keeps AsciiDoc maps filetype-local, consistent with the preview maps).
- **Independence**: decoupled from the completion / editing / avante best-of-breed changes (different files). markview adds no snacks dependency.
- **Risk**: the filetype rename is the highest-risk item; markview's AsciiDoc renderer binding to a non-`asciidoc` filetype is the second. See `design.md`.

## Prerequisites and sequencing

**Sequence position:** 02 of 08 — Wave A (independent).

- **Hard prerequisites:** none. Adds `lua/plugins/asciidoc.lua` and renames `after/ftplugin/asciidoc.lua` → `after/ftplugin/asciidoctor.lua`. No other change touches these files. No snacks dependency (independent of the avante change).
- **Implementation wave: A** (independent; parallelizable with the other Wave A changes: `migrate-completion-blink`, `modernize-editing-plugins`, `upgrade-avante-drop-dressing`, `add-treesitter-textobjects`).

## Out of scope

- An AsciiDoc LSP / prose linter (vale) — no production AsciiDoc LSP exists as of mid-2026; deferred.
- A treesitter AsciiDoc parser (`cpkio/nvim-treesitter-asciidoc`) — too early-stage; vim-asciidoctor's syntax is the chosen highlighting source.
- Enabling markview for Markdown — markdown-preview.nvim + glow already cover Markdown; not perturbed here.
- Replacing the Docker/Antora preview — explicitly preserved.
