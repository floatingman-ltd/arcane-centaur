# statusline Specification

## Purpose
Provides the statusline through `nvim-lualine/lualine.nvim`, themed tokyonight, having replaced vim-airline. A single global statusline (`globalstatus`) serves every window rather than one per split, and icons are enabled only when `vim.g.have_nerd_font` reports a font that can actually draw them.

Its git and diagnostic segments deliberately source from what is already running — gitsigns for the branch and hunk counts, `vim.diagnostic` for errors and warnings — rather than adding plugins whose only job is to feed a statusline. The hunk counts are read from gitsigns' own buffer state rather than lualine's built-in git source, so they reflect unsaved changes rather than only what is committed.

## Requirements
### Requirement: Lua statusline via lualine.nvim
The statusline SHALL be provided by `nvim-lualine/lualine.nvim`, themed `tokyonight`, replacing `vim-airline`. It SHALL use a single global statusline (`globalstatus = true`) and enable icons only when `vim.g.have_nerd_font` is set.

#### Scenario: Statusline renders core segments
- **WHEN** Neovim has loaded a file buffer
- **THEN** the statusline SHALL display the current mode, git branch, diff hunk counts, diagnostics, filetype, and cursor position

#### Scenario: vim-airline removed
- **WHEN** Neovim finishes loading plugins
- **THEN** `:Lazy` SHALL NOT list `vim-airline`

### Requirement: Statusline integrates git and diagnostics
The statusline SHALL source its git information from gitsigns.nvim and its diagnostics from `vim.diagnostic`, without additional plugins.

#### Scenario: Branch and hunk counts reflect the repository
- **WHEN** the current buffer is inside a git repository with uncommitted changes
- **THEN** the statusline SHALL show the branch name and added/changed/removed hunk counts

#### Scenario: Diagnostics counts reflect LSP state
- **WHEN** an LSP server reports diagnostics for the current buffer
- **THEN** the statusline SHALL show the error/warning counts

