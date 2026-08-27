## ADDED Requirements

### Requirement: fsautocomplete is configured as the F# LSP server

The config SHALL register `fsautocomplete` via the native `vim.lsp.config`/`vim.lsp.enable` API using the shared `on_attach` function defined in `lua/config/lsp.lua`, providing hover documentation, go-to-definition, references, rename, document symbols, signature help, code actions and completion in F# buffers.

`fsautocomplete` SHALL be installed as a global dotnet tool (`dotnet tool install -g fsautocomplete`), matching the other global tools this configuration depends on.

#### Scenario: LSP attaches on F# buffer open

- **WHEN** the user opens a `.fs` file and `fsautocomplete` is on `$PATH`
- **THEN** `fsautocomplete` attaches to the buffer and the shared LSP keymaps (`gd`, `K`, `gr`, `<leader>rn`, `<leader>ca`, `<leader>e`, `[d`, `]d`) are active

#### Scenario: A project file is not required for basic features

- **WHEN** a loose `.fs` file outside any project is opened
- **THEN** `fsautocomplete` SHALL still attach

#### Scenario: Missing binary does not crash

- **WHEN** `fsautocomplete` is not installed or not on `$PATH`
- **THEN** Neovim starts without error and no LSP attaches to F# buffers

### Requirement: F# formatting and folding are supplied by the language server

`fsautocomplete` advertises both `documentFormattingProvider` and `foldingRangeProvider`. The existing `fsharp = { lsp_format = "prefer" }` entry in `lua/plugins/conform.lua` and the existing `{ "lsp", "indent" }` fold provider chain SHALL therefore become active once the server is installed, with no configuration change.

#### Scenario: F# files are formatted on write

- **WHEN** an F# buffer is written
- **THEN** the language server SHALL format it, `conform.lua` preferring LSP formatting for this filetype

#### Scenario: F# folds come from the language server

- **WHEN** an F# buffer containing nested structure is opened
- **THEN** fold ranges SHALL be supplied by `fsautocomplete` through ufo's `lsp` provider, with indent as the fallback

### Requirement: F# indentation remains unsupported

Installing the language server SHALL NOT be taken to mean F# indentation works. There is no `indent/fsharp.vim`, no `ftplugin/fsharp.vim` and no treesitter `indents.scm` for F#, so newline indentation remains plain `autoindent`. This gap SHALL remain recorded until addressed by a dedicated change.

#### Scenario: Newline after a match arm does not indent the body

- **WHEN** the user presses Enter at the end of a line such as `| Circle r ->`
- **THEN** the new line SHALL merely copy the previous indent rather than indenting the body
- **THEN** this SHALL be understood as a known gap, not a regression introduced by installing the server
