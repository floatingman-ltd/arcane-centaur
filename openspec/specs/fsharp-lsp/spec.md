# fsharp-lsp Specification

## Purpose
Defines F# language-server support: `fsautocomplete` registered through the native `vim.lsp` API with the shared `on_attach`, supplying hover, completion, references, rename, diagnostics, structural fold ranges, and format-on-save via Fantomas.

It also records what F# does **not** get from the *server*, because that is what this capability had to measure and what the next person would otherwise re-measure. Indentation is not among the gaps any more, and never was the server's to supply — LSP has no indent-as-you-type concept. It is provided editor-side and specified by `fsharp-indent`. Formatting depends on a second binary, Fantomas, which `fsautocomplete` does not ship and whose absence blocks every write behind an interactive install prompt rather than degrading. And the server can only answer for files it can resolve options for: a bare `.fs` outside any project answers nothing at all, a `.fsx` script resolves options unreliably, and only a file inside a `.fsproj` supports everything.
## Requirements
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

