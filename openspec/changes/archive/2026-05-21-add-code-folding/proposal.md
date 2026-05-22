## Why

Large files are hard to navigate without folding. The config currently has zero fold configuration — no fold method, no fold expression, no visual fold text. Adding structured folding with annotated foldtext (`▸ function foo() ··· 8 lines`) makes it easy to collapse blocks on demand and quickly grasp file structure, especially in large C# class files with `#region` blocks and in F#/Lisp files with deeply nested definitions.

## What Changes

- Add `nvim-ufo` plugin for annotated foldtext and multi-provider fold ranges
- Configure fold options in `lua/options.lua` (fold-on-demand, everything starts open)
- Update `lua/config/lsp.lua` to pass fold range capabilities to all LSP servers (required for Roslyn/C# `#region` support)
- Add `c_sharp` to treesitter `ensure_installed` as treesitter fallback for C#
- Add fold keymaps (`zR` / `zM` / peek) in `lua/keymaps.lua`

## Capabilities

### New Capabilities

- `code-folding`: Structured fold-on-demand across all supported languages, with annotated foldtext showing fold name and line count. Provider chain: LSP → treesitter → indent.

### Modified Capabilities

<!-- No existing specs require changes -->

## Design Decisions

- **Fold-on-demand**: `foldlevelstart = 99` — files always open fully expanded; user folds explicitly with `za` / `zc` / `zM`
- **Visual style (Option B)**: `▸ function fetchUser() ··· 8 lines` — name visible, count shown, no peek required for orientation
- **Provider chain**: LSP first (Roslyn for C# `#region`), treesitter second (all other languages), indent fallback
- **Keymaps**: built-in `z` keys only; add a peek keymap (not `K` — already LSP hover) for hovering into a closed fold without opening it
- **No which-key dependency**: fold keymaps use standard Vim `z` layer; which-key is a separate upcoming change

## Impact

- `lua/options.lua`: add `foldlevel`, `foldlevelstart`, `foldenable`, `foldcolumn`
- `lua/config/lsp.lua`: build shared `capabilities` with fold range support; pass to all `vim.lsp.config()` calls
- `lua/plugins/treesitter.lua`: add `c_sharp` to `ensure_installed`
- `lua/plugins/ufo.lua`: new file — nvim-ufo plugin spec with provider chain and foldtext config
- `lua/keymaps.lua`: add `zR` / `zM` convenience maps and peek keymap
- External prerequisite: none (nvim-ufo installed via lazy.nvim)
- No breaking changes; additive only
