## Context

`lua/plugins/init.lua` declares five tpope/airline bare specs:

```lua
"tpope/vim-repeat",      -- KEEP (vim-unimpaired needs it)
"tpope/vim-sensible",    -- remove (redundant)
"tpope/vim-surround",    -- replace → nvim-surround
"tpope/vim-unimpaired",  -- KEEP
"vim-airline/vim-airline", -- replace → lualine
```

`vim-commentary` is configured separately in `lua/plugins/vim-commentary.lua` (lazy-loaded on `gcc`/`gc` keys). There is **no** existing lualine/statusline config, no airline theme, and no surround/comment keymaps in `lua/keymaps.lua`. `lua/options.lua` sets `showmode = false`.

This change groups four swaps that all live in (or alongside) `init.lua` so the file is edited once.

## Goals / Non-Goals

**Goals**
- Modern Lua statusline with git + diagnostics integration, TokyoNight-themed.
- Lua surround with the same `ys`/`cs`/`ds` mnemonics and native dot-repeat.
- Remove two redundant plugins (vim-sensible, vim-commentary) with zero behavior loss.
- Keep vim-repeat + vim-unimpaired working.

**Non-Goals**
- Remapping surround to non-default keys.
- A bespoke/custom statusline layout beyond a standard informative set.
- Touching vim-repeat or vim-unimpaired.

## Decisions

### lualine in its own file `lua/plugins/lualine.lua`
One-plugin-per-file is the convention. Spec sketch:

```lua
return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },  -- already present; icons gated by have_nerd_font elsewhere
  event = "VeryLazy",
  opts = {
    options = {
      theme = "tokyonight",
      globalstatus = true,             -- single statusline (laststatus=3)
      icons_enabled = vim.g.have_nerd_font,
    },
    sections = {
      lualine_b = { "branch", "diff", "diagnostics" },
      lualine_x = { "filetype" },
    },
  },
}
```

- `theme = "tokyonight"` — built into lualine; matches the colorscheme with no extra plugin.
- `diff` reads from gitsigns automatically (gitsigns is already installed and attaches on `BufReadPre`).
- `diagnostics` reads from `vim.diagnostic` (LSP already wired).
- `icons_enabled`/devicons gated on `vim.g.have_nerd_font` to match the existing nvim-tree/fzf-lua pattern for non-Nerd-Font terminals.

*Alternative considered*: Neovim 0.12's improved native statusline (zero deps). Rejected — replicating gitsigns branch/hunk + diagnostics segments by hand is more boilerplate than lualine's one-liner, per the evaluation.

### nvim-surround in its own file `lua/plugins/nvim-surround.lua`
```lua
return {
  "kylechui/nvim-surround",
  version = "*",          -- stable
  event = "VeryLazy",
  opts = {},              -- defaults preserve ys/cs/ds
}
```
Defaults match vim-surround's mnemonics (`ys{motion}{char}`, `cs{old}{new}`, `ds{char}`) and add native dot-repeat via `operatorfunc` — so vim-repeat is not needed by nvim-surround. No keymaps in `lua/keymaps.lua` reference surround, so nothing else changes.

*Alternative considered*: `mini.surround`. Rejected — its default `sa`/`sd`/`sr` keys differ from vim-surround muscle memory; nvim-surround is the closer behavioral match.

### vim-commentary → native `gc`
Delete `lua/plugins/vim-commentary.lua` and the bare spec. Neovim core (≥ 0.10) provides `gc` (operator, normal + visual), `gcc` (current line), with dot-repeat and `[count]` — the same interface `vim-commentary.lua` was mapping. No replacement plugin, no keymaps to add. Verify no code calls the `:Commentary` Ex command (grep found none).

### vim-sensible → removed
Delete the bare spec only. Neovim's defaults cover its surface area on 0.12. No file to delete (it has no dedicated config file), no behavior change expected. If any specific option turns out to be wanted, set it explicitly in `lua/options.lua` — but none is expected.

### vim-repeat retained (the key cross-validation outcome)
`vim-unimpaired`'s `yo*` toggles and paste/exchange maps use vim-repeat for dot-repeat. Since vim-unimpaired is KEEP, vim-repeat stays. Removing it would silently degrade unimpaired's `.` behavior. This is the explicit reason the evaluation's "remove vim-repeat" item is declined here.

## Risks / Trade-offs

- **lualine + gitsigns ordering**: lualine's `diff` segment needs gitsigns loaded. gitsigns attaches on `BufReadPre`/`BufNewFile` and lualine on `VeryLazy`; in practice gitsigns is ready first. If diff counts are missing on the very first buffer, it self-corrects on the next gitsigns attach. Low risk.
- **Statusline appearance change** is the most visible user-facing diff; expected and desired.
- **Native `gc` vs vim-commentary edge cases**: behavior is equivalent for normal use; treesitter-aware commenting in the native operator is if anything better. No known regressions for the filetypes in this config.
- **Independence**: fully decoupled from the completion and avante changes — different files.

## Validation outline
1. Remove the four specs; delete `vim-commentary.lua`; add `lualine.lua` + `nvim-surround.lua`.
2. `:Lazy sync` — confirm vim-airline/vim-surround/vim-sensible/vim-commentary are gone and lualine/nvim-surround install.
3. Confirm the statusline shows mode, branch, diff, diagnostics, filetype, position.
4. Confirm `ysiw"`, `cs"'`, `ds"` work and dot-repeat with `.`.
5. Confirm `gcc` and `gc{motion}` toggle comments.
6. Confirm `vim-unimpaired` maps (e.g. `yos`, `]q`) still work and dot-repeat.
7. `luac -p` syntax check.
