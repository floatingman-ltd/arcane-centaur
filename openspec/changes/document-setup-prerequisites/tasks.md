## 1. Base setup — expand getting-started.adoc

- [ ] 1.1 Restructure the dependency coverage into **Required for everyone** (Neovim ≥ 0.12, git, curl, unzip, C compiler/build-essential) vs **Required per feature** (Node/npm, Docker).
- [ ] 1.2 Call out **build-essential / a C compiler (`cc`/`gcc`)** as required to compile nvim-treesitter parsers, and that a missing compiler fails parser install silently (no highlight).
- [ ] 1.3 Update the Node.js section: it's required for plugin build steps of **markdown-preview.nvim AND bracey.vim** (not "optional, markdown-preview only").
- [ ] 1.4 Add/verify a **feature→dependency table**: AI/Ollama, diagrams/PlantUML, Markdown export, presentations/MARP, AsciiDoc/Antora preview, Lisp REPL containers → their Docker service/compose file.
- [ ] 1.5 Add a link (xref) to the new Language Setup matrix page.
- [ ] 1.6 Document the **editor tooling binaries** that are effectively required-for-everyone but currently undocumented: **`ripgrep` (`rg`)** and **`fzf`** — runtime deps of fzf-lua (the picker), todo-comments (`<leader>xT`), and trouble. Include install one-liners; note the config's core UX degrades without them.

## 2. Language Setup matrix — new page

- [ ] 2.1 Create `docs/modules/ROOT/pages/languages/setup.adoc` with a per-language/family section or table.
- [ ] 2.2 Columns/fields per language: LSP server, REPL/runtime, formatter, debugger, treesitter parser — each with a one-line install command or link.
- [ ] 2.3 Cover: **Lua** (lua-language-server, stylua); **.NET C#/F#** (dotnet SDK, Roslyn `Microsoft.CodeAnalysis.LanguageServer`, fsautocomplete, csharpier, csharprepl, netcoredbg [GitHub-release binary — NOT a `dotnet tool`], **EasyDotnet server tool** `dotnet tool install -g EasyDotnet` [required by easy-dotnet.nvim for run/test/debug]); **Haskell** (ghcup, GHC, haskell-language-server, **haskell-debug-adapter**); **Common Lisp** (sbcl, quicklisp, swank); **Clojure** (clojure CLI or lein + nREPL); **Scheme**; **Fennel**; **Janet** (janet, janet-lsp).
- [ ] 2.4 State the C-compiler-for-treesitter-parsers requirement (or xref getting-started).
- [ ] 2.5 Link each entry to that language's guide Prerequisites section.
- [ ] 2.6 In the Lua row, note that **`stylua` is required, not optional** — it is load-bearing for both conform's format-on-save **and** the `PostToolUse` hook added by the `format-lua-stylua` change. State that a missing `stylua` degrades gracefully (formatting simply doesn't apply, edits are never blocked). Cross-reference the `format-lua-stylua` change.

## 3. Normalise language-guide Prerequisites

- [ ] 3.1 Ensure each of dotnet/lisp/haskell/janet/lua has a clearly-headed **Prerequisites** section with its language-specific tools only.
- [ ] 3.2 Remove any duplicated base/system tools from guides (replace with an xref to getting-started).
- [ ] 3.3 Confirm the matrix links resolve to these sections.
- [ ] 3.4 Document **Haskell debugging** setup (TEST_PLAN §7.5 is **deferred** pending it): note that `haskell-debug-adapter` **plus an open cabal/stack project** are required for `require("dap").configurations.haskell` to populate (haskell-tools.nvim registers the config only then). Add to the Haskell guide Prerequisites + the setup matrix, and cross-reference §7.5.

## 4. Nav + build verification

- [ ] 4.1 Add an `xref` to `languages/setup.adoc` in the Languages group of `docs/modules/ROOT/nav.adoc`.
- [ ] 4.2 Rebuild the Antora site (`./docker/antora/run.sh antora-playbook.yml`) — confirm no AsciiDoc/xref errors.
- [ ] 4.3 Spot-check rendered pages: getting-started base tables, the matrix, and a couple of guide Prerequisites cross-links.
