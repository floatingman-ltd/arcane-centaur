## ADDED Requirements

### Requirement: marksman is configured as the markdown LSP server

The config SHALL register `marksman` via the native `vim.lsp.config`/`vim.lsp.enable` API using the shared `on_attach` function defined in `lua/config/lsp.lua`, providing hover documentation, go-to-definition, references, rename, document symbols, code actions and completion in markdown buffers.

`marksman` SHALL be installed from its GitHub release binary onto `$PATH`, matching how `lua-language-server` is installed. The documented install command SHALL be one that works; `sudo apt install marksman` SHALL NOT be documented, as no such package exists in the configured repositories.

#### Scenario: LSP attaches on markdown buffer open

- **WHEN** the user opens a `.md` file and `marksman` is on `$PATH`
- **THEN** `marksman` attaches to the buffer and the shared LSP keymaps (`gd`, `K`, `gr`, `<leader>rn`, `<leader>ca`, `<leader>e`, `[d`, `]d`) are active

#### Scenario: Missing binary does not crash

- **WHEN** `marksman` is not installed or not on `$PATH`
- **THEN** Neovim starts without error and no LSP attaches to markdown buffers

### Requirement: marksman supplies no folding ranges or formatting

`marksman` SHALL NOT be relied upon for fold ranges or document formatting. It advertises neither `foldingRangeProvider` nor `documentFormattingProvider`, so markdown folding SHALL come from other providers and no LSP-backed markdown formatter SHALL be configured.

#### Scenario: Folding does not regress when the server is installed

- **WHEN** `marksman` is attached to a markdown buffer
- **THEN** fold ranges SHALL still come from the treesitter and indent providers
- **THEN** installing the server SHALL NOT change which folds appear

#### Scenario: No markdown formatter appears

- **WHEN** a markdown buffer is written
- **THEN** no LSP-backed reformatting SHALL occur
