## Why

nvim-treesitter's `master` branch is **frozen** — its own README states it is "provided for backward compatibility only" and that "all future updates happen on the `main` branch, which will become the default branch." On **Neovim 0.12** the frozen branch is already breaking: the text-objects query path calls a core API that 0.12 removed (`nvim-treesitter/tsrange.lua` → `:start()`), so `vaf`/`vif`/`daf`/`]f`/`[f` silently no-op; highlight only works via a `configs.setup` workaround; and markdown highlight had to be force-disabled to avoid a nil-range error. We are pinned to a dead-end branch on an unsupported Neovim version. The durable fix is to move to the maintained `main` branch.

## What Changes

- Repin `nvim-treesitter` **and** `nvim-treesitter-textobjects` from `master` to `main`. **BREAKING** — the `main` config API is entirely different from `master`'s module system.
- Rewrite `lua/plugins/treesitter.lua` to the `main` API:
  - install-only `require("nvim-treesitter").setup{}`; parsers installed via `main`'s mechanism (`:TSInstall` / an install list) instead of the `ensure_installed` module.
  - **highlight** via a `FileType` autocmd calling `vim.treesitter.start()` (no `highlight` module).
  - **indent** via `vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"`.
- Restore **text objects** via `nvim-treesitter-textobjects` `main`: `require('nvim-treesitter-textobjects').setup{}` plus manual keymaps calling its select/move API (these use Neovim's **core** queries, so they work on 0.12). Objects: `af`/`if` (function), `ac`/`ic` (class), `aa`/`ia` (argument); motions `]f`/`[f`/`]F`/`[F`. Gated off for Lisp-family filetypes (vim-sexp keeps those).
- Keep treesitter **highlight for F#/C#/Haskell/Lua**; re-evaluate whether the markdown nil-range `disable`/`vim.treesitter.stop()` workaround is still needed on `main` (likely removable).
- Update `lazy-lock.json` (both plugins → `main`) and docs (`editor/navigation.adoc`, `editor/keybindings.adoc`, `other/architecture.adoc`).
- **Supersedes** the text objects removed from Change 01 (which was re-scoped to highlight-only on `master`).

## Capabilities

### New Capabilities
- `treesitter-editing`: Treesitter-based syntax highlighting, indentation, and semantic text objects/motions for non-Lisp languages (F#/C#/Haskell/Lua), delivered via the maintained nvim-treesitter `main` branch and Neovim's core treesitter APIs.

### Modified Capabilities
<!-- None. No existing spec in openspec/specs/ covers treesitter; code-folding (nvim-ufo)
     and Lisp structural editing (vim-sexp) are unaffected at the requirement level. -->

## Impact

- **Plugins**: `nvim-treesitter`, `nvim-treesitter-textobjects` — branch repin (`master` → `main`) + config rewrite.
- **Files**: `lua/plugins/treesitter.lua` (rewrite), `lazy-lock.json`, possibly `after/ftplugin/markdown.lua` (relax the `vim.treesitter.stop()` workaround), docs pages under `docs/modules/ROOT/pages/editor/` and `.../other/architecture.adoc`.
- **Neovim**: requires ≥ 0.11 for the `main` branch (repo already targets ≥ 0.12).
- **Non-goals / unaffected**: parser compilation still needs a C compiler; Lisp structural editing (vim-sexp) is untouched; code folding (nvim-ufo) is untouched.
- Depends on Change 01's re-scope (text objects already backed out on `master`); this change reintroduces them on `main`.
