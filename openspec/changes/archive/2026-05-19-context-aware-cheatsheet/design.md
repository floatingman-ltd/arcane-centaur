## Context

The AsciiDoc / Antora migration removed the markdown cheatsheet files that previously supported terminal-based reference via `glow`. When editing on headless systems (SSH sessions, single-screen setups) there is no quick way to look up keybindings — the Antora site requires a browser, and the AsciiDoc source files are not human-readable in the terminal.

The feature replaces that capability from *inside* Neovim with a floating window that assembles context-aware content from a small set of Markdown files. The AsciiDoc site remains the canonical rich reference; this is the lean companion for when you're already in the editor.

Two distinct content types exist:
- **Cheatsheets** — keybinding tables, one per language group plus a universal core
- **Mini-guides** — short operational how-to documents (e.g. "launch sbcl-swank Docker and connect Conjure"), linked from cheatsheets and accessible separately

## Goals / Non-Goals

**Goals:**
- Open a context-aware floating window with `<leader>?` from any buffer
- Show universal bindings (LSP, navigation, git, editing, copilot, completion) always
- Append language-specific bindings when the current filetype is recognised
- Provide numbered shortcuts at the bottom of the float to open relevant mini-guides
- Work in any terminal Neovim supports, including headless SSH
- Introduce zero new plugin dependencies

**Non-Goals:**
- Replicating the full AsciiDoc / Antora site inside the editor
- Auto-generating cheatsheet Markdown from AsciiDoc source
- Replacing `glow` as a shell-level tool (the Markdown files remain glow-readable as a side-effect, but that is not the design target)
- A searchable/fuzzy-findable guide browser (out of scope for this change; can be added later)

## Decisions

### 1. Runtime content assembly, not pre-built per-context files

At the moment `<leader>?` is pressed, Lua reads `cheatsheets/core.md` and (if the filetype maps to one) `cheatsheets/<ft>.md`, concatenates them into a scratch buffer, and opens the float.

**Alternatives considered:**
- *Pre-built files* (`LISP_CHEATSHEET.md` = core + lisp): requires a generation script and produces redundant files. Discarded.
- *Single file with section markers*: makes the Lua filter logic non-trivial and the file awkward to browse. Discarded.

Runtime assembly keeps source files small and independently readable. No build step.

### 2. Neovim floating window, not a terminal split or external process

The float is created with `vim.api.nvim_open_win()` (centered, bordered), the scratch buffer's `filetype` is set to `markdown` so treesitter provides highlighting, and `q` / `<Esc>` close it.

**Alternatives considered:**
- *`glow` in a terminal split*: adds an external-process round-trip, requires glow in `PATH` everywhere, and disrupts the split layout. Discarded.
- *Horizontal/vertical split*: shifts the editing area, harder to dismiss cleanly. Discarded.
- *`:help`-style buffer*: familiar but harder to make non-intrusive. Discarded.

Floats are non-disruptive and work in every terminal Neovim supports.

### 3. Filetype → cheatsheet mapping lives in the Lua module, not in the Markdown files

A single table in `lua/config/cheatsheet.lua` maps filetype strings to a record with the cheatsheet filename and a list of guide slugs:

```lua
local ft_map = {
  lisp    = { sheet = "lisp.md",    guides = { "sbcl-swank", "clojure-nrepl" } },
  clojure = { sheet = "lisp.md",    guides = { "clojure-nrepl" } },
  scheme  = { sheet = "lisp.md",    guides = {} },
  fennel  = { sheet = "lisp.md",    guides = {} },
  janet   = { sheet = "janet.md",   guides = { "janet-docker" } },
  fsharp  = { sheet = "fsharp.md",  guides = { "dotnet-fsi" } },
  haskell = { sheet = "haskell.md", guides = { "ghci-workflow" } },
  markdown = { sheet = "markdown.md", guides = {} },
}
```

**Alternative considered:** embed guide metadata as a comment in each Markdown file (`<!-- guides: sbcl-swank,clojure-nrepl -->`). Parsing markdown comments from Lua is fragile. A Lua table is explicit and easy to extend.

### 4. Guide links displayed as numbered shortcuts; opening replaces the current float

The assembled buffer ends with a **GUIDES** section listing `[1] sbcl-swank  [2] clojure-nrepl` (only if the filetype entry has guides). While the float is focused, pressing `1`, `2`, etc. closes the cheatsheet float and opens the guide content in a new float.

**Alternatives considered:**
- *Cursor-navigation select (`Enter`)*: requires the user to move the cursor to the guide link. Numbered keys are faster.
- *Open guide on top (stacked)*: adds complexity around tracking window handles. Replacing keeps the implementation simple; the cheatsheet is a `<leader>?` keypress away if needed again.

### 5. `cheatsheets/` and `guides/` directories at the repo root

These sit alongside `lua/`, `docs/`, etc. They are plain Markdown, independently maintained from the AsciiDoc site.

**Alternative considered:** nest under `docs/terminal/`. This mixes concerns — the Antora pipeline touches `docs/`; keeping cheatsheets and guides outside avoids any risk of the conversion pipeline touching them.

### 6. `<leader>?` as the keymap

`?` is a natural mnemonic ("what are the keys?"). It is unused in `lua/keymaps.lua`. No conflict with any existing binding.

## Risks / Trade-offs

**Drift from AsciiDoc docs** → Both sets of documents are maintained by hand and serve different purposes (quick in-editor reference vs. rich navigable site). Some drift is acceptable. Major keybinding changes should update both. Mitigation: the proposal notes this explicitly so contributors know to keep both in sync.

**Float rendering in minimal terminals** → Very low-capability terminals (e.g. raw Linux console) may not support floats well. Mitigation: Neovim handles graceful degradation; the feature is primarily intended for SSH sessions in capable terminals (GNOME Terminal, WezTerm, Kitty, Windows Terminal).

**Treesitter markdown parser absent** → If the treesitter markdown grammar is not installed, the buffer renders as plain text. Mitigation: acceptable graceful degradation; content remains readable.

**`<leader>?` conflicts** → Unlikely given current keymap audit, but if a future plugin claims it, the cheatsheet keymap will need to move.

## Open Questions

- **Guide float stacking vs replacing**: should pressing `1` in the cheatsheet float open the guide *on top* (so `q` returns to the cheatsheet) or *replace* the float? Stacking is friendlier but requires tracking two window handles. Replacing is simpler. Deferred to implementation; start with replace.

- **Standalone guide entry point**: is `<leader>?g` (a guide picker independent of the cheatsheet) needed in this change, or can it come later? Proposal defers it; implement only if it emerges naturally from the float UX.

- **Scroll behaviour**: the float should be navigable with normal Neovim scroll keys (`Ctrl-d` / `Ctrl-u`, `j` / `k`). Verify this works correctly with a `nomodifiable` scratch buffer — no special handling expected, but confirm during implementation.
