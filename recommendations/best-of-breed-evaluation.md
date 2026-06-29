# Best-of-Breed Plugin Evaluation — arcane-centaur

**Date:** 2026-06-29
**Neovim target:** ≥ 0.12
**Plugin manager:** lazy.nvim
**Total installed:** 47 plugins

This report evaluates every installed plugin against the current Neovim ecosystem (mid-2026). Verdicts are one of: **KEEP (best-of-breed)**, **KEEP (good, minor caveats)**, **CONSIDER SWITCHING**, or **REPLACE/RECONSIDER**.

---

## Executive Summary — Top 5 Prioritized Changes

1. **Replace nvim-cmp stack with blink.cmp** — Largest quality-of-life gain available. blink.cmp is dramatically faster, has typo-resistant fuzzy matching, ships LSP/buffer/path/snippets built-in, and is now the default in LazyVim 14. The migration cost is moderate but well-documented; cmp-conjure bridges via `blink.compat`.

2. **Replace vim-airline with lualine.nvim** — vim-airline is Vimscript-era, notoriously slow at startup, and loads many airline-specific plugins. lualine is pure Lua, loads only what you configure, integrates natively with gitsigns/LSP/diagnostics, and matches TokyoNight beautifully out-of-the-box.

3. **Remove vim-sensible and vim-commentary** — Both are dead weight on Neovim 0.12. Neovim's defaults already cover everything in vim-sensible. Neovim 0.10 shipped a built-in `gc` operator (written by the mini.nvim author) that is comment-syntax-aware and dot-repeatable — identical interface to vim-commentary.

4. **Unpin and upgrade avante.nvim** — v0.0.27 is roughly 18 months stale. Linux x86_64 binaries are available from v0.0.29 onward; the current stream builds prebuilt libs for both lua51 and luajit. The config comment warning is now outdated. Upgrade to latest stable (≥ v0.1.0) and switch `:AvanteBuild` instead of `make`.

5. **Wire up fzf-lua keymaps** — fzf-lua is installed but has zero keymaps configured (`opts = {}`). It is one of the best fuzzy finders available (LazyVim's new default) and is already present as a dependency path. Adding a standard keymap set (`<leader>ff`, `<leader>fg`, `<leader>fb`, `<leader>fd`) costs nothing and unlocks immediate value.

---

## Group 1 — Completion

### nvim-cmp + cmp-nvim-lsp + cmp-buffer + cmp-path + cmp-cmdline + cmp_luasnip + cmp-spell + cmp-conjure

**Current state:** Full vanilla nvim-cmp stack with spell, conjure, and luasnip sources. Config is clean and correct.

**Verdict: CONSIDER SWITCHING → blink.cmp**

[blink.cmp](https://github.com/saghen/blink.cmp) has become the dominant completion plugin in the Neovim ecosystem. Key advantages over nvim-cmp:

- **Performance:** Updates on every keystroke with 0.5–4 ms overhead vs. nvim-cmp's 60 ms default debounce with 2–50 ms hitches. Relevant for REPL-driven work where the buffer changes constantly.
- **Built-in sources:** LSP, buffer, path, and snippets are built-in — no separate `cmp-*` packages needed.
- **Typo-resistant fuzzy matching:** Uses a Rust-based matcher (frizbee) achieving ~6x the throughput of fzf while tolerating transpositions.
- **LuaSnip support:** blink.cmp supports LuaSnip natively via the `snippets.preset = "luasnip"` option. The `blink_luasnip` community package also exists as a fallback.
- **cmp-conjure bridge:** No native blink.cmp source for Conjure exists yet, but [blink.compat](https://github.com/saghen/blink.compat) lets you use any nvim-cmp source on blink.cmp. cmp-conjure works via blink.compat.
- **V1 is stable;** V2 is in active development with breaking changes. Recommend pinning V1 until V2 stabilises.

Migration note: Replacing 8 nvim-cmp packages with 2 (blink.cmp + blink.compat for conjure) is a net reduction of 6 plugin specs. The cmdline completion configuration is slightly different but fully supported.

---

## Group 2 — Statusline

### vim-airline

**Current state:** Bare-string spec in `init.lua`, no airline-specific configuration. No airline-themes installed.

**Verdict: REPLACE/RECONSIDER → lualine.nvim**

vim-airline is a Vimscript plugin from the Vim era. It has well-known startup overhead and loads a large internal plugin table even when minimally configured. With zero configuration it shows minimal benefit over Neovim's built-in statusline (which itself improved significantly in 0.12 with `vim.diagnostic.status()` integration).

[lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) is the modern replacement: pure Lua, loads only the components you configure, has a TokyoNight theme built in, and integrates natively with gitsigns (branch display, hunk counts), LSP (diagnostics, active server name), and conform (format status). The statusline becomes genuinely informative with almost no configuration.

Neovim 0.12's improved default statusline is a viable minimal alternative if you want zero dependencies, but lualine's gitsigns + LSP integration is hard to replicate without it.

---

## Group 3 — File Explorer

### nvim-tree.lua

**Current state:** Well-configured — case-sensitive sort, width 30, fallback icons for non-Nerd-Font terminals, dotfiles hidden, custom `QuitPre` autocmd to close the tree when it would be the last window. Keymaps: `<leader>n`, `<C-n>`, `<C-t>`, `<C-f>`.

**Verdict: KEEP (good, minor caveats)**

nvim-tree.lua remains the most popular tree-based file explorer and is actively maintained. The configuration here is solid and includes thoughtful WSL/terminal accommodations.

The main alternative worth knowing:
- [oil.nvim](https://github.com/stevearc/oil.nvim) — edits the filesystem like a buffer. A fundamentally different mental model that aligns with modal editing philosophy. Excellent for bulk renames and reorganisation. Could complement nvim-tree rather than replace it (oil as `<leader>e` for quick edits, tree for navigation).

neo-tree.nvim has better defaults and easier configuration, but migration from nvim-tree has no compelling reason given the existing setup's quality.

The `lazy = false` means nvim-tree loads at startup — this is intentional given the IDE layout (`<leader>L`) use case, but worth noting that it adds unconditional startup cost. Switching to `cmd = "NvimTreeToggle"` and adjusting the `ide_layout` function to require it on demand would recover a small startup win.

---

## Group 4 — Fuzzy Finder

### fzf-lua

**Current state:** Installed but configured with only `opts = {}` — no keymaps, no customisation. The plugin is present only as a declared dependency path.

**Verdict: KEEP (good, minor caveats) — but needs keymaps wired up**

fzf-lua is one of the best fuzzy finders for Neovim. It replaced Telescope as the default in [LazyVim 14](https://www.lorenzobettini.it/2024/12/lazyvim-14-some-new-and-breaking-features/). The plugin is already installed and paying no return because no keymaps reach it.

Suggested minimal keymap set (add to `lua/plugins/fzf-lua.lua`):

```lua
keys = {
  { "<leader>ff", "<cmd>FzfLua files<CR>",    desc = "Find files" },
  { "<leader>fg", "<cmd>FzfLua live_grep<CR>", desc = "Live grep" },
  { "<leader>fb", "<cmd>FzfLua buffers<CR>",   desc = "Buffers" },
  { "<leader>fd", "<cmd>FzfLua diagnostics_workspace<CR>", desc = "Diagnostics" },
  { "<leader>fh", "<cmd>FzfLua help_tags<CR>", desc = "Help tags" },
  { "<leader>fr", "<cmd>FzfLua oldfiles<CR>",  desc = "Recent files" },
},
```

Note: `<C-f>` is mapped to `NvimTreeFindFile` in `keymaps.lua`; no conflict on `<leader>f` prefix since `<leader>f` is bound to conform format. Use `<leader><space>` or another prefix if collisions arise.

---

## Group 5 — Git

### vim-fugitive + gitsigns.nvim + diffview.nvim

**Current state:** All three well-configured with proper keymaps. fugitive handles CLI-level Git operations, gitsigns handles inline hunk management, diffview handles visual diff/history.

**Verdict: KEEP (best-of-breed)**

This is the canonical three-plugin Git stack for Neovim. vim-fugitive remains unmatched for `:Git` command-line integration and is still actively maintained by tpope. gitsigns is the standard for gutterline hunk display. diffview.nvim has no serious competitor for side-by-side diff views and file history browsing. Nothing to change here.

---

## Group 6 — REPL / Language (Lisp Family)

### conjure + vim-sexp + vim-sexp-mappings-for-regular-people + nvim-parinfer + rainbow-delimiters.nvim + cmp-conjure

**Current state:** Full Lisp stack. Conjure lazy-loads on `ft = { "lisp", "clojure", "scheme", "fennel", "janet" }` with correctly placed `init` globals. Parinfer provides structural balancing. Rainbow delimiters provide nesting visualisation. vim-sexp + mappings give ergonomic s-expression manipulation.

**Verdict: KEEP (best-of-breed)**

This is as good as Lisp development in Neovim gets. Conjure is the definitive REPL integration tool for Lisp-family languages; parinfer + vim-sexp is the conventional pairing for structural editing. No alternatives approach this stack's maturity for Common Lisp, Clojure, Scheme, Fennel, and Janet simultaneously.

The HUD configuration (`conjure#log#hud#enabled`, `passive_close_delay = 5000`, `jump_to_latest`) is thoughtful and will serve async evaluation well.

---

## Group 7 — REPL / Language (.NET)

### roslyn.nvim + iron.nvim

**Current state:** iron.nvim for F# (`dotnet fsi`) and C# (`csharprepl`) REPLs. roslyn.nvim for C# LSP. Both ft-gated to avoid loading on non-.NET files.

**Verdict: KEEP (best-of-breed)**

roslyn.nvim (seblyng fork) uses the official Microsoft Roslyn language server, which is demonstrably better than OmniSharp for C# in 2025+. iron.nvim is the right REPL driver for both `dotnet fsi` and csharprepl. fsautocomplete via nvim-lspconfig handles F# LSP — a proven pairing. This stack is current best-of-breed for .NET in Neovim.

---

## Group 8 — Language (Haskell)

### haskell-tools.nvim

**Current state:** Pinned to `version = "^6"`, ft-gated, `lazy = false` (plugin self-manages laziness as noted in the comment).

**Verdict: KEEP (best-of-breed)**

haskell-tools.nvim wraps haskell-language-server, provides GHCi integration, and is the recommended Haskell setup for Neovim. The `^6` pin is appropriate for stability. No alternatives at this level of Haskell-specific integration.

---

## Group 9 — LSP Infrastructure

### nvim-lspconfig + conform.nvim

**Current state:** nvim-lspconfig wires all servers to a shared `on_attach` in `lua/config/lsp.lua`. conform.nvim handles format-on-save with a clean per-ft config; Lua uses stylua, all others defer to LSP.

**Verdict: KEEP (best-of-breed)**

nvim-lspconfig is the standard LSP configuration layer. conform.nvim is the best dedicated formatter plugin — its `lsp_format = "prefer"` fallback is exactly the right pattern for languages where the LSP is the formatter. No changes needed.

**Neovim 0.12 note:** Neovim 0.12 introduces native insert-mode auto-completion (`autocomplete` option) that could theoretically replace nvim-cmp/blink.cmp. As of mid-2026 it is still maturing and lacks the source ecosystem. Not recommended to rely on it yet, but worth monitoring.

---

## Group 10 — Treesitter

### nvim-treesitter

**Current state:** Ensures parsers for lisp, clojure, scheme, lua, fsharp, vim, markdown, markdown_inline, plantuml, http, c_sharp. Highlight and indent both enabled.

**Verdict: KEEP (best-of-breed)**

nvim-treesitter is mandatory for the modern Neovim experience. The parser list is well-targeted. The workaround in `ufo.lua` (disabling treesitter provider for markdown, using indent instead to avoid errors in glow buffers) is appropriate.

---

## Group 11 — Folding

### nvim-ufo + promise-async

**Current state:** LSP + indent provider selector, custom virtual text handler showing `··· N lines ···` suffix. Markdown uses indent-only to avoid glow buffer errors. `zR`/`zM` keymaps in `keymaps.lua`.

**Verdict: KEEP (good, minor caveats)**

nvim-ufo still provides meaningful value over raw Neovim folding in 2026: the virtual text handler is notably better, and the LSP-first / indent-fallback provider chain is more reliable than native `foldexpr = treesitter`. Native Neovim folding has improved in 0.10/0.11/0.12 but still lacks the refined virtual text and multi-provider fallback that nvim-ufo delivers.

The main caveat is `promise-async` as an extra dependency and occasional jankiness on special buffers (addressed here by the markdown workaround). If you ever want to simplify, native `foldmethod=expr` with `foldexpr=v:lua.vim.treesitter.foldexpr()` plus `foldtext` customisation is viable, but requires more boilerplate to match the current output quality.

---

## Group 12 — UI Chrome

### dressing.nvim

**Current state:** Listed as an avante.nvim dependency. Provides improved `vim.ui.select` and `vim.ui.input` overlays.

**Verdict: CONSIDER SWITCHING**

dressing.nvim has been **archived** by its author (stevearc), who now recommends [snacks.nvim](https://github.com/folke/snacks.nvim) for `vim.ui` improvements. The plugin still works but receives no new development. Since dressing.nvim is only present as an avante dependency, the practical path is:

1. After upgrading avante.nvim (see Priority 4), check whether the new release has dropped or updated its dressing dependency.
2. If avante no longer needs it, remove dressing.nvim.
3. If a `vim.ui` replacement is still wanted, snacks.nvim's `vim.ui` module is the current recommendation.

### which-key.nvim

**Current state:** Two group labels registered (`<leader>gc` → Claude, `<leader>os` → OpenSpec). Default opts otherwise.

**Verdict: KEEP (best-of-breed)**

which-key.nvim is the standard keymap discovery tool. The minimal group registration is exactly the right amount of configuration. No alternatives needed.

### nui.nvim + nvim-web-devicons + plenary.nvim

**Verdict: KEEP** (dependency plumbing — avante, fzf-lua, diffview all need these)

---

## Group 13 — tpope Plugin Bloc

### vim-sensible

**Verdict: REPLACE/RECONSIDER — remove it**

vim-sensible provides Vim defaults that Neovim already sets. [Neovim's defaults have covered the vim-sensible surface area since at least Neovim 0.7](https://www.rogin.dev/blog/sensible-neovim/). On Neovim 0.12 (which sets even better defaults, including an improved statusline and new `autocomplete` option), vim-sensible is entirely redundant. It silently sets options that Neovim already owns — at best a no-op, at worst a source of confusion when defaults change upstream.

**Action:** Remove from `lua/plugins/init.lua`.

### vim-commentary

**Verdict: REPLACE/RECONSIDER — remove it**

[Neovim 0.10 shipped built-in commenting](https://echasnovski.com/blog/2024-04-05-neovim-now-has-builtin-commenting.html) — a `gc` operator in normal and visual mode, `gcc` for current line, dot-repeat and `[count]` support, treesitter-enhanced comment syntax. The interface is identical to vim-commentary. The built-in is authored by the mini.nvim author (echasnovski) and is part of Neovim core as of 0.10.

`lua/plugins/vim-commentary.lua` explicitly maps `gcc` and `gc` — these work identically with the built-in. Removing vim-commentary and deleting `lua/plugins/vim-commentary.lua` requires no other changes.

**Action:** Delete `lua/plugins/vim-commentary.lua` and remove the spec.

### vim-surround

**Verdict: CONSIDER SWITCHING → nvim-surround or mini.surround**

vim-surround is a Vimscript plugin with no dot-repeat without vim-repeat. Both [nvim-surround](https://github.com/kylechui/nvim-surround) and [mini.surround](https://github.com/nvim-mini/mini.surround) are Lua rewrites.

- **nvim-surround** is the closer behavioural match to vim-surround (same `ys`/`ds`/`cs` mnemonics, dot-repeat native, cursor-aware).
- **mini.surround** is designed after vim-sandwich (different default keymaps: `sa`/`sd`/`sr`) but can be remapped to vim-surround style. Part of the larger mini.nvim library.

Given that vim-repeat is already installed (providing dot-repeat for vim-surround), the current setup works. The migration to nvim-surround is low-risk and gains native dot-repeat and Lua integration.

### vim-repeat

**Verdict: CONSIDER SWITCHING — conditional on vim-surround decision**

vim-repeat patches `.` to work with plugin maps. Modern Neovim plugins implement dot-repeat via `operatorfunc`/`vim.o.operatorfunc` natively without needing vim-repeat. If vim-surround is replaced with nvim-surround, vim-repeat becomes vestigial (nvim-surround doesn't need it). Its only remaining consumer would be vim-unimpaired.

**Action:** Evaluate after vim-surround decision. Can be removed once no installed plugin requires it.

### vim-unimpaired

**Verdict: KEEP (good, minor caveats)**

vim-unimpaired provides the `[q`/`]q` (quickfix), `[b`/`]b` (buffers), `[f`/`]f` (files), `[e`/`]e` (exchange lines), `yo` (toggle options) bracket-pair mappings. These are genuinely useful and not replicated by any Neovim built-in. mini.nvim has a `mini.bracketed` module that covers the same territory in Lua, but migration is not urgent — vim-unimpaired is stable, lightweight, and well-understood.

---

## Group 14 — Markdown & Documentation

### markdown-preview.nvim + glow.nvim + mkdnflow.nvim

**Current state:** markdown-preview.nvim provides browser preview (WSL-aware, wslview/explorer.exe). glow.nvim provides in-editor terminal preview. mkdnflow.nvim handles wiki-style link navigation.

**Verdict: KEEP (good, minor caveats)**

markdown-preview.nvim is the standard browser-preview solution despite its npm build step. glow.nvim is a solid terminal-preview option. mkdnflow.nvim is active and purpose-built for linked Markdown navigation — useful for the AsciiDoc-adjacent Markdown files in this config.

Caveat: the `lazy = false` implicit in the file-level globals (`vim.g.mkdp_preview_options`) means these globals are set at startup even on non-Markdown files. This is fine in practice but could be moved into the plugin's `init` callback for cleanliness.

---

## Group 15 — HTTP / REST

### kulala.nvim

**Current state:** ft-gated to `http`, keymaps in `after/ftplugin/http.lua`. Clean.

**Verdict: KEEP (best-of-breed)**

[kulala.nvim](https://github.com/mistweaverco/kulala.nvim) supports HTTP, gRPC, GraphQL, WebSocket, and Streaming. Active development — versions 6.0.7 and 6.1.0 shipped in May 2025. The JetBrains `.http` spec support is a distinguishing feature. No competitor in Neovim matches its protocol breadth.

---

## Group 16 — AI Assistance

### avante.nvim (pinned v0.0.27)

**Current state:** Pinned to v0.0.27 with comment noting Linux binaries unavailable beyond that version. Ollama default, Claude API optional. Three keymaps.

**Verdict: CONSIDER SWITCHING — upgrade to current release**

The pin comment is outdated. Linux x86_64 and aarch64 binaries (both lua51 and luajit) are available in releases from v0.0.29 forward, and the versioning scheme has moved to v0.1.0+. The build step has also changed: `.so` files now install to a location Neovim finds automatically, and `:AvanteBuild` replaces the raw `make` invocation.

To upgrade:
1. Change `version = "v0.0.27"` to `version = false` (track latest) or a specific newer tag.
2. Change `build = "make"` to `build = ":AvanteBuild"`.
3. After `:Lazy update`, run `:AvanteBuild` once.

The Ollama/Claude provider configuration is still valid in newer releases.

---

## Group 17 — Colorscheme & Theme

### tokyonight.nvim

**Current state:** `style = "moon"`, terminal colours synced, fallback underline for terminals without undercurl, transparency off (terminal-managed). Well-considered.

**Verdict: KEEP (best-of-breed)**

TokyoNight is actively maintained, has first-class support from plugin authors (lualine theme built-in, which-key integrates, gitsigns colours correct). No reason to change.

---

## Group 18 — Miscellaneous / Live Preview

### bracey.vim (live HTML/CSS/JS preview)
**Verdict: KEEP (good, minor caveats)** — ft-gated, niche but correct tool for the task. Turbio/bracey.vim receives infrequent updates but is stable. No strong Lua alternative.

### plantuml-syntax + custom preview logic
**Verdict: KEEP (best-of-breed)** — custom Python-based encoder is clever and avoids a server-side dependency. The ASCII/PNG routing via `term.is_console` is WSL-aware. `aklt/plantuml-syntax` is the standard syntax plugin.

---

## Summary Table

| Plugin | Role | Verdict | Best Alternative | Notes |
|---|---|---|---|---|
| nvim-cmp | Completion engine | CONSIDER SWITCHING | blink.cmp | 8 packages → 2; major perf gain |
| cmp-nvim-lsp | LSP source | CONSIDER SWITCHING | blink.cmp built-in | Drops with nvim-cmp |
| cmp-buffer | Buffer source | CONSIDER SWITCHING | blink.cmp built-in | Drops with nvim-cmp |
| cmp-path | Path source | CONSIDER SWITCHING | blink.cmp built-in | Drops with nvim-cmp |
| cmp-cmdline | Cmdline source | CONSIDER SWITCHING | blink.cmp built-in | Drops with nvim-cmp |
| cmp_luasnip | Snippet source | CONSIDER SWITCHING | blink.cmp native | `snippets.preset = "luasnip"` |
| cmp-spell | Spell source | CONSIDER SWITCHING | blink.cmp compat | Via blink.compat if needed |
| cmp-conjure | Conjure source | CONSIDER SWITCHING | blink.compat bridge | No native blink source yet |
| vim-airline | Statusline | REPLACE/RECONSIDER | lualine.nvim | Vimscript; slow startup |
| vim-sensible | Defaults | REPLACE/RECONSIDER | Remove | Entirely redundant on Nvim 0.12 |
| vim-commentary | Commenting | REPLACE/RECONSIDER | Neovim built-in (0.10+) | `gc` operator is now native |
| vim-repeat | Dot-repeat | CONSIDER SWITCHING | Remove after surround swap | Only needed for vim-surround |
| vim-surround | Surround ops | CONSIDER SWITCHING | nvim-surround | Lua, native dot-repeat |
| vim-unimpaired | Bracket mappings | KEEP (good, minor caveats) | mini.bracketed | Stable, no urgent migration |
| avante.nvim | AI chat | CONSIDER SWITCHING | Upgrade to v0.1.0+ | Pin comment is outdated |
| dressing.nvim | vim.ui overlays | CONSIDER SWITCHING | snacks.nvim | Archived by author |
| fzf-lua | Fuzzy finder | KEEP (good, minor caveats) | — | Needs keymaps wired up |
| nvim-tree.lua | File explorer | KEEP (good, minor caveats) | oil.nvim (complement) | Consider lazy-loading |
| nvim-ufo | Folding | KEEP (good, minor caveats) | Native foldexpr | Still best virtual text |
| vim-fugitive | Git CLI | KEEP (best-of-breed) | — | Unmatched |
| gitsigns.nvim | Git gutter | KEEP (best-of-breed) | — | Standard |
| diffview.nvim | Git diff/history | KEEP (best-of-breed) | — | No competitor |
| conjure | Lisp REPL | KEEP (best-of-breed) | — | Definitive Lisp integration |
| vim-sexp | S-expr ops | KEEP (best-of-breed) | — | Structural editing |
| vim-sexp-mappings | Sexp ergonomics | KEEP (best-of-breed) | — | Companion to vim-sexp |
| nvim-parinfer | Paren balancing | KEEP (best-of-breed) | — | Correct tool |
| rainbow-delimiters.nvim | Bracket colours | KEEP (best-of-breed) | — | ft-gated; no cost |
| roslyn.nvim | C# LSP | KEEP (best-of-breed) | — | Official MS Roslyn |
| iron.nvim | .NET REPL | KEEP (best-of-breed) | — | Best REPL driver |
| haskell-tools.nvim | Haskell | KEEP (best-of-breed) | — | Integrates HLS + GHCi |
| nvim-lspconfig | LSP config | KEEP (best-of-breed) | — | Standard |
| conform.nvim | Formatting | KEEP (best-of-breed) | — | Best formatter plugin |
| nvim-treesitter | Syntax/folding | KEEP (best-of-breed) | — | Mandatory |
| kulala.nvim | HTTP client | KEEP (best-of-breed) | — | Actively maintained |
| which-key.nvim | Keymap help | KEEP (best-of-breed) | — | Standard |
| tokyonight.nvim | Colorscheme | KEEP (best-of-breed) | — | Well-maintained |
| markdown-preview.nvim | MD browser preview | KEEP (good, minor caveats) | — | WSL-aware config |
| glow.nvim | MD terminal preview | KEEP (good, minor caveats) | — | Complement to mkdp |
| mkdnflow.nvim | MD link nav | KEEP (good, minor caveats) | — | Active |
| plantuml-syntax | PlantUML syntax | KEEP (best-of-breed) | — | Standard |
| bracey.vim | HTML live preview | KEEP (good, minor caveats) | — | No better Lua alt |
| nvim-ufo | Folding | KEEP (good, minor caveats) | Native foldexpr | Still best UX |
| promise-async | UFO dep | KEEP | — | Required by ufo |
| nui.nvim | UI component lib | KEEP | — | Avante/diff dep |
| plenary.nvim | Utility lib | KEEP | — | Fugitive/diffview dep |
| nvim-web-devicons | Icons | KEEP | — | Widely used dep |
| lazy.nvim | Plugin manager | KEEP (best-of-breed) | vim.pack (Nvim 0.12) | vim.pack is minimal; lazy still superior for complex configs |

---

## Neovim 0.10–0.12 Built-ins Overlapping Installed Plugins

| Built-in | Available since | Plugin superseded |
|---|---|---|
| `gc` comment operator | Neovim 0.10 | vim-commentary (remove it) |
| `vim.ui.select` / `vim.ui.input` hooks | Neovim 0.6 | dressing.nvim (improve via snacks.nvim if desired) |
| Native LSP (`:lsp` command) | Neovim 0.12 | Supplements nvim-lspconfig, does not replace |
| Treesitter folding (`vim.treesitter.foldexpr`) | Neovim 0.10 | Partially overlaps nvim-ufo; ufo still adds value |
| Default statusline with diagnostic integration | Neovim 0.12 | Overlaps vim-airline; lualine is still the better choice |
| `vim.pack` plugin manager | Neovim 0.12 | Supplements lazy.nvim; lazy still superior for complex configs |
| Native insert-mode completion (`autocomplete`) | Neovim 0.12 | Not mature enough to replace blink.cmp/nvim-cmp yet |

---

## References

- [blink.cmp GitHub](https://github.com/saghen/blink.cmp)
- [blink.cmp documentation](https://main.cmp.saghen.dev/)
- [blink.compat — use nvim-cmp sources on blink.cmp](https://github.com/saghen/blink.compat)
- [lualine.nvim GitHub](https://github.com/nvim-lualine/lualine.nvim)
- [Neovim 0.10 built-in commenting — echasnovski blog](https://echasnovski.com/blog/2024-04-05-neovim-now-has-builtin-commenting.html)
- [Neovim 0.12 — What's New](https://dotfiles.substack.com/p/whats-new-in-neovim-012)
- [vim.pack guide — echasnovski blog](https://echasnovski.com/blog/2026-03-13-a-guide-to-vim-pack)
- [avante.nvim releases](https://github.com/yetone/avante.nvim/releases)
- [dressing.nvim archived, recommends snacks.nvim](https://github.com/stevearc/dressing.nvim)
- [oil.nvim GitHub](https://github.com/stevearc/oil.nvim)
- [mini.surround documentation](https://nvim-mini.org/mini.nvim/readmes/mini-surround.html)
- [LazyVim 14 — fzf-lua as new default](https://www.lorenzobettini.it/2024/12/lazyvim-14-some-new-and-breaking-features/)
- [vim-sensible and Neovim](https://www.rogin.dev/blog/sensible-neovim/)
- [kulala.nvim GitHub](https://github.com/mistweaverco/kulala.nvim)
- [nvim-ufo GitHub](https://github.com/kevinhwang91/nvim-ufo)
