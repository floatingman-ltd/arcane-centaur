# avante-runtime Specification

## Purpose
TBD - created by archiving change 05-upgrade-avante-drop-dressing. Update Purpose after archive.
## Requirements
### Requirement: avante.nvim pinned to a maintained release with Linux binaries
`avante.nvim` SHALL be pinned to a current stable release (`v0.1.x` or later) that ships prebuilt Linux binaries, and built via the build step documented for that release. The previous `v0.0.27` pin and its "do not update" comment SHALL be retired.

#### Scenario: avante loads on the upgraded version
- **WHEN** Neovim loads avante.nvim after `:Lazy update` and the documented build step
- **THEN** avante SHALL load with no `release not found` build error and no opts-validation warnings

### Requirement: dressing.nvim removed from the dependency set
`stevearc/dressing.nvim` SHALL NOT be a dependency of avante.nvim. The dependency set SHALL be `plenary.nvim`, `nui.nvim`, and `nvim-web-devicons`.

#### Scenario: dressing.nvim not installed
- **WHEN** `:Lazy clean` has run after the upgrade
- **THEN** `:Lazy` SHALL NOT list `dressing.nvim`

#### Scenario: Native vim.ui still functions
- **WHEN** a `vim.ui.select` or `vim.ui.input` prompt is triggered (e.g. an LSP code action) with dressing removed
- **THEN** the native Neovim selection/input UI SHALL appear and function

### Requirement: diffview remains functional after the dependency edit
Retaining `plenary.nvim` in avante's dependency list SHALL keep `diffview.nvim` (which depends on plenary transitively) working.

#### Scenario: Diffview opens after the avante upgrade
- **WHEN** the user runs `:DiffviewOpen` after the avante upgrade and dependency edit
- **THEN** the diff view SHALL open without a missing-plenary error

### Requirement: avante is Ollama-only after the upgrade
The upgraded avante SHALL configure **only** the `ollama` provider (default), model `qwen2.5:0.5b`, with no `claude` provider. The keymaps SHALL be `<leader>aa` (open with current provider) and `<leader>ao` (select ollama and open); `<leader>ac` SHALL NOT be mapped.

#### Scenario: Ollama keymaps work; claude keymap absent
- **WHEN** the user presses `<leader>aa` or `<leader>ao` on the upgraded avante
- **THEN** avante SHALL open with the current (ollama) provider, and `<leader>ao` SHALL select ollama and open
- **WHEN** the user presses `<leader>ac`
- **THEN** no avante action SHALL occur (the mapping does not exist)

