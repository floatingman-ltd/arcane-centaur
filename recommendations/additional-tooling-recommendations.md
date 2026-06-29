# Additional Tooling Recommendations — arcane-centaur

**Date:** 2026-06-29
**Config target:** Neovim ≥ 0.12 (Neovim 0.12 shipped 2026-03-29)
**Focus:** REPL-driven dev, Claude-centric AI, AsciiDoc/Antora docs source of truth

---

## How to read this report

Each candidate is rated:

- **HIGH** — clear gap; worth adding soon
- **MEDIUM** — genuine value, lower urgency
- **LOW** — situational; install if you hit the specific itch
- **SKIP** — redundant, conflicting, or not worth the complexity

---

## 1. AsciiDoc tooling (critical section)

AsciiDoc/Antora is the documentation source of truth for this config. The current state: there is an `after/ftplugin/asciidoc.lua` that wires up Docker-based preview (single-file Asciidoctor and full Antora site build), but no AsciiDoc-specific syntax plugin, no treesitter grammar, no LSP, and no in-editor rendering. This is the most significant gap.

### 1a. vim-asciidoctor — PRIORITY: HIGH

**What it does:** The gold-standard Vim/Neovim AsciiDoc plugin. Provides significantly faster and more accurate syntax highlighting than Vim's built-in, code folding, fenced code block language highlighting, concealment of formatting characters (bold markers, URLs), and commands to compile to HTML/PDF/DOCX. 188 stars, 308 commits, actively maintained.

**Gap filled:** Without this, AsciiDoc files get Vim's ancient and slow built-in syntax rules. The faster highlighting and folding alone make this worth installing.

**Caveats:** Its compile commands (`Asciidoctor2HTML` etc.) duplicate what `after/ftplugin/asciidoc.lua` already does via Docker, so you would disable or ignore those. The syntax and folding improvements are the value.

- Repository: [habamax/vim-asciidoctor](https://github.com/habamax/vim-asciidoctor)

```lua
-- lua/plugins/asciidoc.lua
return {
  {
    "habamax/vim-asciidoctor",
    ft = { "asciidoc", "adoc" },
    init = function()
      -- Disable built-in compile commands — Docker ftplugin handles that
      vim.g.asciidoctor_executable = "asciidoctor"
      vim.g.asciidoctor_extensions = {}
    end,
  },
}
```

### 1b. markview.nvim for AsciiDoc in-buffer preview — PRIORITY: MEDIUM

**What it does:** In-buffer rendering for Markdown, HTML, LaTeX, Typst, and AsciiDoc using Neovim's extmark system. Version 28.3.0 (May 2026) lists AsciiDoc as a supported filetype. 3,500 stars, actively maintained with 924 commits.

**Gap filled:** The current Docker-based preview is heavyweight (requires Docker daemon, converts to HTML, opens browser). markview.nvim renders inline without leaving Neovim, giving instant visual feedback when reading or lightly editing AsciiDoc. It is explicitly not a full Antora render — it works at the document level. For writing and reviewing individual pages, this beats spinning up Docker.

**Caveats:** AsciiDoc support is newer than Markdown in markview; expect rougher edges. The hybrid mode (disappears on cursor movement) can be jarring. Worth trialing; easy to disable per-buffer if it interferes with editing.

- Repository: [OXY2DEV/markview.nvim](https://github.com/OXY2DEV/markview.nvim)

### 1c. AsciiDoc LSP — PRIORITY: LOW (not ready)

**Current state of the ecosystem:**

- [ViToni/asciidoc-lsp](https://github.com/ViToni/asciidoc-lsp): 2 stars, 1 commit, VSCode-only client. Not usable.
- [basking2/asciidoc-lsp-server](https://github.com/basking2/asciidoc-lsp-server): Exploratory, not production-ready.
- The Asciidoctor project has an [open issue from 2019](https://github.com/asciidoctor/asciidoctor/issues/3630) requesting an LSP; it remains open as of 2026.
- The VS Code AsciiDoc extension does not use LSP (uses native JetBrains/VSCode APIs), so there is no battle-tested LSP to reuse.

**Verdict:** No production AsciiDoc LSP exists as of mid-2026. The nvim-lspconfig docs list `vale` (a prose linter) which works on AsciiDoc for spelling and style, and is the closest practical option. Install vale + `vale-ls` if prose linting matters for documentation quality.

### 1d. nvim-treesitter-asciidoc — PRIORITY: LOW

[cpkio/nvim-treesitter-asciidoc](https://github.com/cpkio/nvim-treesitter-asciidoc): 7 stars, 6 commits, no releases. Too early-stage to depend on; vim-asciidoctor's syntax file is more battle-tested and immediately useful.

### 1e. nvim-asciidoc-preview — PRIORITY: LOW

[tigion/nvim-asciidoc-preview](https://github.com/tigion/nvim-asciidoc-preview): 54 stars, Node.js-based live preview, explicitly marked "early stage not fully tested." Requires Node.js + npm as a runtime dependency. The existing Docker-based ftplugin preview covers the same use case without adding a Node.js dependency. Skip in favor of the existing ftplugin or markview.

---

## 2. Debugging: nvim-dap + nvim-dap-ui

**Priority: HIGH (for .NET); MEDIUM (for Haskell)**

### 2a. .NET (C# / F#)

**What it does:** nvim-dap implements the Debug Adapter Protocol in Neovim. For .NET, the adapter is netcoredbg (the open-source .NET Core debugger). nvim-dap-ui adds a full debugging UI with variable inspection, call stack, breakpoints panel, and REPL.

**Gap filled:** There is currently no debugging capability in this config. The .NET REPL via iron.nvim (dotnet fsi / csharprepl) covers evaluation but not breakpoint-based debugging of running applications.

**Two paths:**

**Option A — Manual nvim-dap + nvim-dap-cs:**
- Install `nvim-dap`, `nvim-dap-ui`, `nvim-dap-cs`
- Install netcoredbg via `dotnet tool install -g netcoredbg` or from releases
- Wire up launch configurations per project

See: [nvim-dap-cs](https://github.com/NicholasMata/nvim-dap-cs), [Debugging C# in Neovim](https://aaronbos.dev/posts/debugging-csharp-neovim-nvim-dap)

**Option B — easy-dotnet.nvim (recommended):**
A plug-and-play .NET plugin (835 stars, 611 commits) that bundles Roslyn LSP, netcoredbg debugging, and a neotest adapter in one plugin. It explicitly supports C# and F#. Since roslyn.nvim is already installed and managed separately, easy-dotnet would be additive for the debugging and testing layers.

The key advantage: easy-dotnet auto-discovers launch configurations from the project structure rather than requiring manual `launch.json` authoring.

See: [easy-dotnet.nvim](https://github.com/GustavEikaas/easy-dotnet.nvim), [debugging docs](https://github.com/GustavEikaas/easy-dotnet.nvim/blob/main/docs/debugging.md)

**Recommendation:** Add easy-dotnet.nvim scoped to `ft = { "cs", "fsharp" }`, configure it to skip Roslyn setup (since roslyn.nvim is already in place), and let it own the debug and test runner surface.

### 2b. Haskell

**What it does:** haskell-tools.nvim (already installed) will automatically discover DAP configurations if nvim-dap is present — no manual configuration needed. It discovers configurations from cabal/stack projects.

Two Haskell debug adapters exist:
- [phoityne/haskell-debug-adapter](https://github.com/phoityne/haskell-debug-adapter): the established adapter, uses GHCi under the hood
- [well-typed/haskell-debugger](https://well-typed.github.io/haskell-debugger/): newer GHC 9.14 native debugger (DAP-compatible), announced January 2026

**Verdict:** If nvim-dap is added for .NET, Haskell debugging comes for free via haskell-tools.nvim auto-discovery. The incremental cost is zero.

---

## 3. Testing: neotest

**Priority: MEDIUM**

**What it does:** An extensible test framework for Neovim. You install the core + adapters for each language.

**Relevant adapters:**
- **neotest-dotnet** ([Issafalcon/neotest-dotnet](https://github.com/Issafalcon/neotest-dotnet)): Runs .NET tests, supports xUnit/NUnit/MSTest, requires C# treesitter parser (already installed).
- **neotest-vstest** ([Nsidorenco/neotest-vstest](https://github.com/nsidorenco/neotest-vstest)): Alternative .NET adapter using `dotnet test` with vstest runner; includes `.runsettings` file selection.
- **easy-dotnet built-in adapter**: If easy-dotnet.nvim is adopted (see above), it ships its own neotest adapter that reuses the internal test runner state — no separate adapter installation.

**Haskell:** There is no stable neotest-haskell adapter. Test output is typically driven via GHCi or `cabal test`; the REPL workflow via Conjure/haskell-tools covers this case adequately.

**Verdict:** Neotest adds genuine value for the .NET side — inline pass/fail markers, jump-to-failing test, run-nearest-test workflow. If easy-dotnet.nvim is adopted, you get the adapter for free. Otherwise, neotest-dotnet is the straightforward add.

---

## 4. trouble.nvim

**Priority: MEDIUM**

**What it does:** A prettier diagnostics panel, quickfix list, location list, and LSP references viewer. The v3 rewrite supports tree views, filtering by severity, project-wide vs buffer-local views, and quickfix/location list replacement.

**Gap filled:** The current config surfaces diagnostics via `<leader>e` (floating window) and `[d`/`]d` (jump between diagnostics). There is no persistent list or project-wide diagnostics view. For multi-file codebases (C# solutions, Haskell projects), a project-wide error list that doesn't require running a build is valuable.

**Interaction with fzf-lua:** fzf-lua already provides a diagnostics picker (`<leader>d` if mapped). trouble.nvim is complementary — a persistent split vs. a fuzzy-pick modal.

**Verdict:** The v3 API is stable. Adds genuine value once the codebase grows beyond single-file edits. Low configuration overhead.

- Repository: [folke/trouble.nvim](https://github.com/folke/trouble.nvim)

---

## 5. Flash.nvim or leap.nvim

**Priority: LOW**

**What they do:** Enhanced motion plugins. Both let you jump to any visible position using 2-character search labels. flash.nvim additionally integrates with Treesitter for semantic jumps and has character-motion enhancements (enhanced `f`/`t`/`F`/`T`).

**Assessment for this config:** The existing toolset (fzf-lua for fuzzy file/buffer navigation, vanilla Vim motions, `]d`/`[d` for diagnostic jumps, `]h`/`[h` for git hunks) covers most navigation needs. Neither plugin conflicts with anything present. The value-add is real but personal — power users of `f`/`t` motions report significant speed gains; casual users barely notice.

**Recommendation:** Flash.nvim is the higher-value pick in 2025-2026 (Treesitter integration, active development), but this is a quality-of-life addition rather than a gap. Try flash.nvim if vanilla character motions feel slow; skip if you don't miss it.

- [folke/flash.nvim](https://github.com/folke/flash.nvim)
- [ggandor/leap.nvim](https://codeberg.org/andyg/leap.nvim)

---

## 6. nvim-treesitter-textobjects

**Priority: MEDIUM**

**What it does:** Adds semantic text objects using Treesitter: `af`/`if` (outer/inner function), `ac`/`ic` (class), `aa`/`ia` (argument/parameter), and many more. Also adds move operations (`]f`, `[f` to jump between functions) and swap operations.

**Gap filled:** The current treesitter config enables highlight and indent but has no textobjects module. The Lisp workflows are well-served by vim-sexp (structural s-expression navigation), but F# and Haskell editing has no structural navigation beyond vanilla motions.

**Conflict check:** No conflict with vim-sexp — textobjects can be disabled per-filetype, so you would enable them for fsharp/haskell/lua/cs but leave lisp/clojure/scheme to vim-sexp.

**Note:** The treesitter parsers for `fsharp` and `haskell` are not in `ensure_installed` in `lua/plugins/treesitter.lua`. Adding them is a prerequisite for textobjects to work in those filetypes.

- Repository: [nvim-treesitter/nvim-treesitter-textobjects](https://github.com/nvim-treesitter/nvim-treesitter-textobjects)

---

## 7. render-markdown.nvim vs markview.nvim (Markdown)

**Priority: LOW** (Markdown preview already covered; AsciiDoc case covered in section 1b)

**What they do:** Both render Markdown in-buffer using extmarks. render-markdown.nvim renders persistently (formatting stays visible while editing). markview.nvim uses a hybrid mode (preview disappears on cursor movement in the editing area).

**Current state:** markdown-preview.nvim (browser preview) and glow.nvim (terminal-pager render) are already installed. These cover the "preview markdown" workflow.

**The gap:** Neither existing plugin renders inline while you edit. render-markdown.nvim would add that. However, for this config's actual Markdown usage (the root `readme.md` and occasional notes), it is marginal. The AsciiDoc in-buffer render case (markview.nvim) is more valuable (section 1b).

**If you want one:** render-markdown.nvim is the more polished choice for pure Markdown rendering ([MeanderingProgrammer/render-markdown.nvim](https://github.com/MeanderingProgrammer/render-markdown.nvim)). markview.nvim is the choice if you want AsciiDoc in-buffer rendering as well (covers both).

---

## 8. todo-comments.nvim

**Priority: MEDIUM**

**What it does:** Highlights TODO / FIXME / HACK / NOTE / WARN / PERF / TEST comments in all buffers with configurable colours and signs. Provides `:TodoTelescope` (or `:TodoFzfLua`) to list all tracked comments project-wide, and integrates with trouble.nvim.

**Gap filled:** No comment annotation highlighting exists in the current config. For a config with Lua, Lisp, F#, Haskell, and AsciiDoc all in one repo, project-wide TODO navigation is a practical time-saver.

**Integration:** Works out of the box with fzf-lua via `:TodoFzf`. If trouble.nvim is also added, you get a `Trouble todo` view. Zero configuration required to get value.

**Maintenance:** Actively maintained by folke; dropping plenary.nvim dependency in 2026.

- Repository: [folke/todo-comments.nvim](https://github.com/folke/todo-comments.nvim)

---

## 9. noice.nvim

**Priority: SKIP**

**Reasoning:** Neovim 0.12 shipped `ui2`, a native redesign of the cmdline, messages, and pager that covers the primary reasons people installed noice.nvim: avoiding "Press ENTER" interruptions, styled cmdline, messages as floating windows. Enabling it: `require('vim._core.ui2').enable()`.

noice.nvim is experimental, frequently breaks on Neovim updates, and adds a heavy dependency on nui.nvim (already present) with significant startup overhead. Given that Neovim 0.12's ui2 is the target, the right move is to trial ui2 natively first. If the native implementation has gaps, reconsider noice.nvim then.

- [Dropping noice.nvim for native ui2](https://tduyng.com/blog/neovim-drop-noice-ui2/)
- [Neovim 0.12 news](https://neovim.io/doc/user/news-0.12/)

---

## 10. snacks.nvim

**Priority: LOW (selective)**

**What it is:** A collection of 20+ quality-of-life modules from folke (lazy.nvim author): fuzzy picker, dashboard, file explorer, terminal, notifications, indent guides, scope highlighting, git integration, lazygit wrapper, scroll animations, and more.

**The problem:** snacks.nvim is designed as an opinionated bundle. This config already has purpose-built equivalents for most of its modules: fzf-lua (picker), nvim-tree (explorer), gitsigns (git gutters), diffview (git diff). Installing snacks as a whole would create redundancy and potential conflicts.

**Selective value:** Two snacks modules are worth considering in isolation:
- `snacks.bigfile` — automatically disables expensive features (syntax, treesitter, LSP) for files over a threshold. Useful if you ever open large generated files.
- `snacks.notifier` — a better notification display (replaces default `vim.notify` with a stack of floating windows). Genuinely nicer than the default, and lighter than noice.nvim.

**Caveat:** claudecode.nvim (coder/claudecode.nvim) lists snacks.nvim as a dependency. If claudecode.nvim is adopted, snacks becomes a transitive dependency anyway — at that point, enabling a few of its modules costs nothing extra.

- Repository: [folke/snacks.nvim](https://github.com/folke/snacks.nvim)

---

## 11. neogit

**Priority: LOW**

**What it does:** A Magit-inspired interactive git UI for Neovim. Provides popup-driven workflows: press `r` for a full rebase popup, `b` for branch management, `c` for commit, etc. Far more interactive than fugitive's command-driven approach.

**Current stack:** vim-fugitive (command-driven status/log/blame/push), gitsigns (hunk operations), diffview (side-by-side diffs and file history). This is a solid, complete git stack.

**Assessment:** Neogit and fugitive serve different workflows. Neogit is better for complex interactive operations (interactive rebase, cherry-pick, complex merges). If you live in fugitive and find it sufficient, neogit adds weight without filling a gap. If you frequently perform multi-step git operations that require navigating fugitive's `:Git rebase -i` equivalent, neogit is worth trying.

**Verdict:** Try neogit only if you miss Magit's interactive popups. It coexists peacefully with fugitive — you can keep both.

- Repository: [NeogitOrg/neogit](https://github.com/NeogitOrg/neogit)

---

## 12. lazygit.nvim

**Priority: LOW**

**What it does:** Opens lazygit in a floating terminal window inside Neovim (`<leader>lg` → lazygit floating pane → `q` to close).

**Assessment:** lazygit is a powerful TUI git client. The integration is thin — it is essentially just a well-packaged `vim.fn.jobstart` that opens lazygit. The value depends entirely on whether you already use lazygit at the terminal level. If you do, a quick keymap to open it without leaving Neovim is genuinely useful. If you don't use lazygit, there is no reason to install this plugin.

**Note:** snacks.nvim includes a `snacks.lazygit` module; if snacks is adopted for any reason, the dedicated lazygit.nvim plugin becomes redundant.

- Repository: [kdheepak/lazygit.nvim](https://github.com/kdheepak/lazygit.nvim)

---

## 13. nvim-autopairs

**Priority: SKIP**

**Why:** nvim-parinfer is already installed for Lisp/Clojure/Scheme/Fennel/Janet and is active for those filetypes. nvim-autopairs and parinfer conflict: autopairs inserts a closing paren, then parinfer re-manages indentation, producing double-close or garbled parens. Users have documented the need to disable autopairs on Lisp filetypes as a workaround.

For non-Lisp filetypes (F#, Haskell, Lua, C#), autopairs adds value. But the configuration complexity of per-filetype enable/disable combined with the risk of subtle parinfer interference makes this not worth it. The existing workflow (type-the-close-paren manually) works fine. If this becomes painful, consider the [dundalek/parpar.nvim](https://github.com/dundalek/parpar.nvim) approach, which is specifically designed to integrate Parinfer and Paredit cleanly and can pause parinfer to allow other plugins to operate.

---

## 14. Session management (persistence.nvim / auto-session)

**Priority: LOW**

**What they do:** Automatically save and restore the window/buffer layout for a directory when Neovim exits and relaunches.

**Assessment for this config:** This is a personal dotfiles config — most sessions in it are short, exploratory edits. Session management pays off most for long-lived project environments with many open buffers and splits. If Neovim is typically opened with `nvim .` in a project directory and you want to resume exactly where you left off, persistence.nvim is a 10-line install with zero ongoing maintenance. If you use the terminal and editor together fluidly (as the REPL-driven workflow implies), session state may be more disruptive than helpful.

**Recommendation:** persistence.nvim if you want it (simple, folke-maintained). auto-session if you want branch-aware session isolation.

- [folke/persistence.nvim](https://github.com/folke/persistence.nvim)
- [rmagatti/auto-session](https://github.com/rmagatti/auto-session)

---

## 15. indent-blankline.nvim (ibl)

**Priority: LOW**

**What it does:** Adds visual indentation guides (thin vertical lines at each indent level). The v3 rewrite adds scope highlighting — the guide corresponding to the current scope is highlighted differently.

**Assessment:** For Lisp-family code, rainbow-delimiters.nvim already provides stronger structural visual feedback (colored parens per nesting level). ibl is most useful for Python-style or significant-whitespace languages. For F# and Haskell, where indentation is significant, ibl can genuinely help track nesting levels. For Lua configuration code, it is mild quality of life.

**Verdict:** Worthwhile for F#/Haskell if you edit complex deeply-nested code. Low priority overall.

- Repository: [lukas-reineke/indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim)

---

## 16. claudecode.nvim (coder/claudecode.nvim)

**Priority: HIGH** (if you want full IDE-parity Claude Code integration)

**What it does:** Implements the same WebSocket MCP protocol that the official Claude Code VS Code and JetBrains extensions use. Rather than shelling out to `claude -p` (as `lua/config/claude_cli.lua` does), it creates a persistent WebSocket server that Claude Code connects to, enabling:

- Real-time file and selection context sharing with Claude (Claude sees what you have open and selected)
- Native diff viewing with accept/reject keymaps
- File context management (add/remove files from Claude's context from the editor)
- Visual selection sending

**Gap filled:** The existing `claude_cli.lua` is a one-shot `claude -p <prompt>` invocation — good for quick suggestions and explanations. claudecode.nvim provides the full two-way integration: Claude can read your editor state, propose diffs, and you can accept/reject inline. This is the difference between "ask Claude a question" and "Claude is a co-pilot watching your session."

**Caveats:**
- Requires snacks.nvim as a dependency (for the default terminal provider). This is a meaningful dependency addition. The `provider = "none"` or `provider = "external"` options allow use without snacks for the WebSocket/MCP features, but you lose the integrated terminal window.
- Beta status (v0.3.0 as of September 2025). 2,900 stars, actively maintained by Coder.

**If adopted:** Disable or deprecate `lua/config/claude_cli.lua` — the ClaudeSuggest/ClaudeExplain one-shot commands become redundant.

- Repository: [coder/claudecode.nvim](https://github.com/coder/claudecode.nvim)

---

## 17. overseer.nvim

**Priority: LOW**

**What it does:** A task runner and job management plugin. Reads VS Code `tasks.json`, make targets, npm scripts, cargo commands, and more. Provides `:OverseerRun` to select and run a task, `:OverseerToggle` for a task list panel, and component-based task lifecycle hooks.

**Assessment for this config:** The .NET build workflow already uses iron.nvim for F# interactive and dotnet commands. Antora builds are triggered from `after/ftplugin/asciidoc.lua`. If easy-dotnet.nvim is adopted, it handles .NET build/run tasks. Overseer would add value if the workflow involves many heterogeneous build targets (Makefile + npm + dotnet simultaneously), but that is not the current profile.

**Verdict:** Install only if you accumulate tasks that don't fit iron.nvim or the existing ftplugin patterns. This is a future consideration, not a current gap.

- Repository: [stevearc/overseer.nvim](https://github.com/stevearc/overseer.nvim)

---

## 18. Popular plugins — quick verdicts

| Plugin | Stars | Verdict | Reason |
|---|---|---|---|
| [lazy.nvim](https://github.com/folke/lazy.nvim) | 19k | Installed | Already present |
| [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | 16k | SKIP | fzf-lua is already the fuzzy picker; telescope and fzf-lua conflict if both are configured as the primary picker |
| [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | 10k | Installed | Already present |
| [mason.nvim](https://github.com/mason-org/mason.nvim) | 8k | LOW | Installs LSP servers/formatters/debuggers automatically. Useful but not essential when servers are managed manually via dotnet tool / jpm / stylua on PATH |
| [oil.nvim](https://github.com/stevearc/oil.nvim) | 7k | LOW | File editing as a buffer; different philosophy to nvim-tree. Add if nvim-tree feels limiting |
| [mini.nvim](https://github.com/echasnovski/mini.nvim) | 6.5k | LOW (selective) | Mini modules are individually excellent (mini.surround, mini.indentscope, mini.comment). vim-surround and vim-commentary are already installed and cover the overlap |
| [harpoon](https://github.com/ThePrimeagen/harpoon) | 6k | LOW | Mark/jump to frequently-used files. fzf-lua buffers picker partially substitutes this; add if you want pinned per-project file marks |
| [copilot.vim](https://github.com/github/copilot.vim) | 9k | SKIP | Deliberately removed from this config in favour of Claude |
| [nvim-surround](https://github.com/kylechui/nvim-surround) | 3.5k | SKIP | vim-surround is already installed; nvim-surround is a drop-in Lua replacement with minor ergonomic improvements — not worth migrating |
| [lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | 7k | LOW | More configurable than vim-airline. Add if vim-airline starts causing issues or you want deeper statusline customisation |
| [bufferline.nvim](https://github.com/akinsho/bufferline.nvim) | 4k | SKIP | Visual buffer tabs. This config intentionally has no bufferline; fzf-lua buffer picker is the navigation model |
| [nvim-notify](https://github.com/rcarriga/nvim-notify) | 3.5k | LOW | Better notification display. snacks.notifier is a lighter modern alternative; either would improve on the default `vim.notify` |
| [vim-dadbod](https://github.com/tpope/vim-dadbod) | 2.5k | LOW | Database UI from tpope. Useful if SQL / database work is part of the workflow; irrelevant otherwise |

---

## Executive summary — shortlist ranked

These are the changes worth acting on, in order of impact:

### 1. vim-asciidoctor — Install now (HIGH)

The single most impactful addition given that AsciiDoc is the documentation source of truth. Better syntax highlighting and folding for every `.adoc` file, immediately. Zero integration complexity.

### 2. claudecode.nvim — Evaluate seriously (HIGH)

Upgrades Claude integration from one-shot `claude -p` queries to a full bidirectional session. The snacks.nvim dependency is non-trivial, but with 2,900 stars and active Coder maintenance, this is the closest thing to the official VS Code extension for Neovim. If you do significant Claude-assisted coding, this changes the workflow qualitatively.

### 3. easy-dotnet.nvim — Install for .NET debugging (HIGH → unlocks debugging + testing)

The existing .NET stack has no debugging. easy-dotnet.nvim bundles netcoredbg debugging, a neotest adapter, and solution management in a single coherent plugin. It explicitly supports F# and C#. Scoping it to `ft = { "cs", "fsharp" }` keeps it lazy-loaded and non-intrusive.

### 4. nvim-treesitter-textobjects — Install (MEDIUM, complements existing treesitter)

Structural text objects for F# and Haskell (where vim-sexp does not help). `af`/`if` for functions, `ac`/`ic` for classes, `]f`/`[f` to jump between definitions — zero-cost complement to the existing treesitter setup. Prerequisite: add `fsharp` and `haskell` to `ensure_installed`.

### 5. markview.nvim — Trial for AsciiDoc in-buffer rendering (MEDIUM)

AsciiDoc support landed in markview v28+ (2026). In-buffer rendering fills the gap between "edit raw AsciiDoc markup" and "view the rendered Antora page" without requiring Docker. Worth trialing for the doc-editing workflow; easy to disable per-buffer if the rendering interferes with editing.

### 6. todo-comments.nvim — Install (MEDIUM, zero config)

Minimal install cost, immediate project-wide TODO/FIXME/NOTE visibility. Integrates with fzf-lua out of the box. Add it alongside trouble.nvim if diagnostics lists become useful.

### 7. trouble.nvim — Install when .NET debugging is active (MEDIUM)

Pairs naturally with the debugging and LSP workflow once easy-dotnet is in place. Project-wide diagnostics list and quickfix navigation.

---

*Items not listed in the shortlist (noice.nvim, nvim-autopairs, neogit, session managers, lazygit.nvim, overseer.nvim) are genuine SKIPs or LOW-priority situational adds — revisit them if you hit the specific itch they solve.*
