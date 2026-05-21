## Why

The migration to AsciiDoc / Antora removed the markdown cheatsheet files that supported terminal-based reference via `glow`. When editing on headless systems (SSH sessions, single-screen setups) there is no practical way to look up a keybinding or recall an operational workflow — switching to a browser is impractical and `glow` no longer has anything to render.

The solution is a **context-aware floating cheatsheet window inside Neovim itself**:
- No browser required — works in any terminal, including headless SSH
- Filetype-aware — shows language bindings only when relevant (Lisp bindings don't appear in F# buffers)
- Operational guides — mini-guides for "how do I do X?" tasks (e.g., launch sbcl-swank Docker) are linked from the relevant language section
- Zero new plugin dependencies — implemented as a small Lua module using the existing floating window API

The AsciiDoc / Antora site remains the rich, navigable reference. The cheatsheet system is the lean, always-available terminal companion.

## What Changes

- **New `lua/config/cheatsheet.lua`**: floating window implementation — reads `cheatsheets/core.md` + the filetype-appropriate `cheatsheets/<ft>.md`, assembles a scratch buffer, opens a centred float with treesitter markdown highlighting; numbered guide links at the bottom open the relevant `guides/<name>.md` in a second float
- **New `<leader>?` keymap** in `lua/keymaps.lua`: opens the context-aware cheatsheet float from any buffer
- **New `cheatsheets/` directory**: Markdown files maintained independently of the AsciiDoc site
  - `core.md` — universal bindings: LSP, navigation/splits, git, copilot, editing, clipboard, formatting, completion
  - `lisp.md` — Conjure eval/REPL-log, vim-sexp slurp/barf; references sbcl-swank and clojure-nrepl guides
  - `janet.md` — Janet-specific Conjure config; references janet-docker guide
  - `fsharp.md` — iron.nvim REPL commands; references dotnet-fsi guide
  - `haskell.md` — haskell-tools GHCi, Hoogle; references ghci-workflow guide
  - `markdown.md` — mkdnflow, browser preview, MARP, Confluence, Jira
- **New `guides/` directory**: short operational Markdown mini-guides
  - `sbcl-swank.md` — launch the sbcl-swank Docker image and connect Conjure
  - `clojure-nrepl.md` — start an nREPL server and connect
  - `dotnet-fsi.md` — F# REPL via `dotnet fsi` and iron.nvim
  - `ghci-workflow.md` — GHCi via haskell-tools

## Capabilities

### New Capabilities

- `context-aware-cheatsheet`: A floating window (`<leader>?`) that shows keybindings relevant to the current buffer. The universal section (LSP, navigation, git, editing, copilot, completion) is always present. A language-specific section is appended when the filetype matches a known language (lisp, clojure, scheme, fennel, janet, fsharp, haskell, markdown). Numbered guide references at the bottom of the language section open operational mini-guides in a second floating window. In unrecognised filetypes only the universal section is shown.

### Modified Capabilities

<!-- none — existing behaviour unchanged -->

## Impact

- `lua/config/cheatsheet.lua` — new file: floating window, filetype→cheatsheet mapping, guide launching
- `lua/keymaps.lua` — add `<leader>?` mapping for cheatsheet float
- `cheatsheets/` — new top-level directory: `core.md` + per-language markdown files
- `guides/` — new top-level directory: operational mini-guide markdown files
- `docs/modules/ROOT/pages/cheatsheets/index.adoc` — add note pointing to `<leader>?` as the in-editor quick reference
- `readme.md` — add `<leader>?` to keybindings table
