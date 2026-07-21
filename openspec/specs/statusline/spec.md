# statusline Specification

## Purpose
TBD - created by archiving change 04-modernize-editing-plugins. Update Purpose after archive.
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

