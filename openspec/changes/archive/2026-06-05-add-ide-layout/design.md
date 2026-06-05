# Design: Add IDE Layout

## Context

Today the pieces of an IDE workspace exist independently:

- nvim-tree opens left at width 30 (`lua/plugins/nvim-tree.lua`), toggled with `<C-t>`/`<leader>n`.
- A hand-rolled terminal toggle (`lua/keymaps.lua:69-88`, `<leader>t`) keeps one persistent shell in `term_buf` — closing the window leaves the buffer/process running; reopening re-displays it.
- `splitbelow`/`splitright` are set (`lua/options.lua:22-23`).
- Glow, which-key, Conjure HUD, and the Claude CLI scratch window are all floating windows that render above splits.

Two layout-stability defects:
1. `toggle_terminal` uses a plain `split` from the focused window — pressed inside the tree it opens a 30-col terminal in the tree column.
2. Closing the current buffer (`:bd`) or last editor window (`:q`) makes nvim-tree expand to full width, destroying the layout.

Target layout (VS Code-style full-width bottom panel):

```
┌────────────┬───────────────────┐
│  nvim-tree │      editor       │
├────────────┴───────────────────┤
│   terminal (full width, 15)    │
└────────────────────────────────┘
```

## Goals / Non-Goals

**Goals:**
- One keystroke (`<leader>L`) assembles tree + editor + terminal, idempotently, focus returning to the editor.
- Terminal toggle is focus-independent and full-width; its height is stable across window re-equalization.
- Buffer/window close operations no longer collapse the layout.
- Minimum custom code; zero new plugins.

**Non-Goals:**
- No startup autocmd — layout is on-demand only (quick edits and `git commit` stay unaffected).
- No managed "bottom slot" that swaps shell ↔ REPL. Conjure stays a float; iron.nvim/GHCi keep their own windows. (If iron's 40-line split ever annoys, `iron.view.bottom(40)` → `bottom(15)` in `lua/plugins/dotnet.lua:29` is a later one-liner.)
- No changes to floating UIs — they already render above splits.
- No session persistence of the layout.

## Decisions

**1. Full-width bottom terminal via `botright split` (vs right-side-only panel)**
A `botright` horizontal split is focus-independent by construction — it always spans the full editor width at the bottom, no matter which window invokes it. The right-side-only (IntelliJ-style) variant requires "find the main editor window first" logic. User explicitly accepted full-width for less code. This one-word change also fixes defect 1.

**2. Extend the hand-rolled toggle (vs toggleterm.nvim / edgy.nvim)**
The existing ~20-line toggle already has the hard part right (persistent buffer reuse). toggleterm adds a plugin dependency for the same behavior; edgy is a full layout manager. Both rejected as heavier than the ~40 lines of Lua this needs.

**3. `winfixheight` on the terminal window**
Set when the window is created so opening/closing other splits doesn't re-equalize the 15-line panel.

**4. `ide_layout()` lives in `lua/keymaps.lua` beside `toggle_terminal` (vs new `lua/config/layout.lua` module)**
It shares `term_buf` state with the toggle; a separate module would need to export/import that state. At ~12 lines it doesn't warrant a module. Assembly order: record current window → `NvimTreeOpen` (idempotent) → ensure terminal visible (reuse the window-scan loop; `stopinsert` after opening) → restore focus to the recorded window, falling back to `wincmd t` + `wincmd l` when the original window was the tree or terminal.

**5. Layout-preserving delete as a `:Bd` user command (vs bufdelete.nvim/mini.bufremove plugin)**
~10 lines: switch every window showing the target buffer to an alternate/next listed buffer (or a fresh empty one), then `:bdelete`. Plugin rejected per minimal-dependency convention. Plain `:bd` remains available and unpatched — `:Bd` is opt-in.

**6. Last-window handling via `QuitPre` autocmd in nvim-tree's plugin config**
On `QuitPre`, if the windows remaining after the quit would be only nvim-tree (and/or the terminal panel), close them too so Neovim exits instead of leaving a full-width tree. Lives in `lua/plugins/nvim-tree.lua`'s `config` function, next to the plugin it protects. This is the repo's first autocmd: use `vim.api.nvim_create_autocmd` with a named augroup (`ide_layout`) to set the pattern for future ones.

## Risks / Trade-offs

- [`QuitPre` fires for floats and `:wq` too; over-eager closing could exit nvim unintentionally] → Guard: only act when every other window is nvim-tree or the known `term_buf`; ignore floating windows (`nvim_win_get_config(win).relative ~= ""`).
- [Repo previously had zero autocmds; this introduces runtime event handling] → Keep it to one narrowly-scoped autocmd in a named augroup, documented in the architecture notes.
- [`:Bd` is opt-in; muscle-memory `:bd` still collapses the layout] → Documented in navigation guide + cheatsheet; remapping `:bd` itself via cabbrev rejected as too magical.
- [Full-width terminal sits under the tree, stealing 15 lines of tree height] → Accepted explicitly by user (VS Code-style trade-off).
- [iron.nvim REPL (40 lines) stacking on the 15-line shell squeezes the editor] → Out of scope; documented one-line mitigation in Non-Goals.
