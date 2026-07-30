## 1. Base setup — expand getting-started.adoc

- [X] 1.1 Restructure the dependency coverage into **Required for everyone** (Neovim ≥ 0.12, git, curl, unzip, C compiler/build-essential) vs **Required per feature** (Node/npm, Docker).
- [X] 1.2 Call out **build-essential / a C compiler (`cc`/`gcc`)** as required to compile nvim-treesitter parsers, and that a missing compiler fails parser install silently (no highlight).
- [X] 1.3 Update the Node.js section: it's required for plugin build steps of **markdown-preview.nvim AND bracey.vim** (not "optional, markdown-preview only").
- [X] 1.4 Add/verify a **feature→dependency table** covering **all nine** services in `docker/`, not just the well-known ones: AI/Ollama (`ollama`), diagrams/PlantUML (`plantuml-server`), Markdown export (`md2pdf`, `pandoc` — two distinct services), presentations/MARP (`marp`), AsciiDoc/Antora preview (`antora`, `asciidoctor` — site build vs single-file conversion), Markdown live preview (`markserv`), Lisp REPL containers (`lisp-swank`).
- [X] 1.5 Add a link (xref) to the new Language Setup matrix page.
- [X] 1.6 Document the **editor tooling binaries** that are effectively required-for-everyone but currently undocumented: **`ripgrep` (`rg`)** and **`fzf`** — runtime deps of fzf-lua (the picker), todo-comments (`<leader>xT`), and trouble. Include install one-liners; note the config's core UX degrades without them.
- [X] 1.7 Document the **feature binaries the config shells out to** that appear nowhere in the setup docs today (all confirmed by `executable()` / `build` checks in `lua/`):
  - **`claude`** — required by *three* AI features: `claude_cli` (`:ClaudeSuggest`/`:ClaudeExplain`), claudecode.nvim (`<leader>gcc`), and research-popup (`<leader>?l` / `<leader>?a`). Note it uses Claude Code's own auth, **not** `ANTHROPIC_API_KEY`, and that a stray `ANTHROPIC_API_KEY` breaks `claude_cli`.
  - **`python3`** — required by `lua/plugins/plantuml.lua` for the diagram encoding step; **both** `:PumlPreview` and `:PumlPreviewAscii` fail without it.
  - **`glow`** — required for console markdown preview; without it the preview keymap only works in a GUI session.
  - **`make`** — required by avante.nvim's `build = "make"` step.
- [X] 1.8 Add a **WSL section**: `win32yank.exe` (clipboard integration) and `wslview` (opening URLs in the Windows browser) are both probed by the config and currently undocumented. Note that without `wslview`, `util.open_url` falls back to a notification.

## 2. Language Setup matrix — new page

- [X] 2.1 Create `docs/modules/ROOT/pages/languages/setup.adoc` with a per-language/family section or table.
- [X] 2.2 Columns/fields per language: LSP server, REPL/runtime, formatter, debugger, treesitter parser — each with a one-line install command or link.
- [X] 2.3 Cover: **Lua** (lua-language-server, stylua); **.NET C#/F#** (dotnet SDK, Roslyn `Microsoft.CodeAnalysis.LanguageServer`, fsautocomplete, csharpier, csharprepl, netcoredbg [GitHub-release binary — NOT a `dotnet tool`], **EasyDotnet server tool** `dotnet tool install -g EasyDotnet` [required by easy-dotnet.nvim for run/test/debug]); **Haskell** (ghcup, GHC, haskell-language-server, **haskell-debug-adapter**); **Common Lisp** (sbcl, quicklisp, swank); **Clojure** (clojure CLI or lein + nREPL); **Scheme**; **Fennel**; **Janet** (janet, janet-lsp).
- [X] 2.4 State the C-compiler-for-treesitter-parsers requirement (or xref getting-started).
- [X] 2.5 Link each entry to that language's guide Prerequisites section.
- [X] 2.6 In the Lua row, note that **`stylua` is required, not optional** — it is load-bearing for both conform's format-on-save **and** the `PostToolUse` hook added by the `format-lua-stylua` change. State that a missing `stylua` degrades gracefully (formatting simply doesn't apply, edits are never blocked). Cross-reference the `format-lua-stylua` change.

## 3. Normalise language-guide Prerequisites

- [X] 3.1 Ensure each of dotnet/lisp/haskell/janet/lua has a clearly-headed **Prerequisites** section with its language-specific tools only.
- [X] 3.2 Remove any duplicated base/system tools from guides (replace with an xref to getting-started).
- [X] 3.3 Confirm the matrix links resolve to these sections.
- [X] 3.4 Document **Haskell debugging** setup (TEST_PLAN §7.5 is **deferred** pending it): note that `haskell-debug-adapter` **plus an open cabal/stack project** are required for `require("dap").configurations.haskell` to populate (haskell-tools.nvim registers the config only then). Add to the Haskell guide Prerequisites + the setup matrix, and cross-reference §7.5.

## 4. Nav + build verification

- [X] 4.1 Add an `xref` to `languages/setup.adoc` in the Languages group of `docs/modules/ROOT/nav.adoc`.
- [X] 4.2 Rebuild the Antora site (`./docker/antora/run.sh antora-playbook.yml`) — confirm no AsciiDoc/xref errors.
- [X] 4.3 Spot-check rendered pages: getting-started base tables, the matrix, and a couple of guide Prerequisites cross-links.
