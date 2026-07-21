# completion-engine Specification

## Purpose
TBD - created by archiving change 03-migrate-completion-blink. Update Purpose after archive.
## Requirements
### Requirement: blink.cmp is the completion engine
Insert-mode and command-line completion SHALL be provided by `saghen/blink.cmp`, pinned to the stable v1 release line. The legacy nvim-cmp stack (`nvim-cmp`, `cmp-nvim-lsp`, `cmp-buffer`, `cmp-path`, `cmp-cmdline`, `cmp_luasnip`) SHALL be removed.

#### Scenario: Completion menu appears from LSP
- **WHEN** the user types in an LSP-attached buffer (e.g. Lua or F#)
- **THEN** blink.cmp SHALL show completion candidates sourced from the language server, buffer words, and filesystem paths

#### Scenario: Legacy cmp plugins removed
- **WHEN** Neovim finishes loading plugins
- **THEN** `:Lazy` SHALL NOT list `nvim-cmp`, `cmp-nvim-lsp`, `cmp-buffer`, `cmp-path`, `cmp-cmdline`, or `cmp_luasnip`

### Requirement: Completion ergonomics preserved
The completion menu SHALL preserve the prior keybindings and the no-auto-select behavior so that `<CR>` never inserts an unselected first suggestion.

#### Scenario: Enter does not insert an unselected suggestion
- **WHEN** the completion menu is visible with no item highlighted and the user presses `<CR>`
- **THEN** a newline SHALL be inserted and no completion item SHALL be accepted

#### Scenario: Navigate and accept
- **WHEN** the menu is visible and the user presses `<C-n>` then `<CR>`
- **THEN** the next item SHALL be selected and accepted

#### Scenario: Trigger, abort, and scroll docs
- **WHEN** the user presses `<M-Space>`, `<C-e>`, `<C-f>`, or `<C-b>`
- **THEN** completion SHALL respectively trigger, hide, scroll the doc window down, and scroll it up

### Requirement: Conjure completions bridged into blink.cmp
Conjure REPL completions SHALL be available in the blink.cmp menu on lisp-family filetypes via `blink.compat` wrapping `cmp-conjure`. `cmp-conjure` SHALL remain installed as a Conjure dependency.

#### Scenario: Conjure symbols complete in a Clojure buffer
- **WHEN** the user edits a `.clj` / `.lisp` / `.janet` buffer with a Conjure REPL connected and triggers completion
- **THEN** Conjure-provided symbol completions SHALL appear in the blink.cmp menu

### Requirement: Context-gated spell completion preserved
Spell-correction completions SHALL be provided via `blink.compat` wrapping `cmp-spell`, and SHALL appear only when spell checking is enabled for the buffer.

#### Scenario: Spell completion in prose with spell on
- **WHEN** the user types in a buffer with `spell` enabled (e.g. markdown)
- **THEN** spell-correction candidates SHALL appear in the completion menu

#### Scenario: No spell completion in code
- **WHEN** the user types in a code buffer with `spell` disabled
- **THEN** no spell-correction candidates SHALL appear

### Requirement: Command-line completion
blink.cmp SHALL complete on the command line: search (`/`, `?`) from buffer words, and Ex command-line (`:`) from filesystem paths and Ex commands.

#### Scenario: Ex command-line completion
- **WHEN** the user types `:` followed by a partial path or command
- **THEN** path and command candidates SHALL be offered

#### Scenario: Search completion
- **WHEN** the user types `/` followed by a partial word
- **THEN** buffer-word candidates SHALL be offered

### Requirement: Completion capabilities advertised to LSP servers
The completion engine SHALL advertise its client capabilities to language servers via `require("blink.cmp").get_lsp_capabilities()`, merged with the existing folding-range capability used by nvim-ufo.

#### Scenario: Servers receive completion capabilities
- **WHEN** any LSP server configured in `lua/config/lsp.lua` attaches to a buffer
- **THEN** it SHALL be started with capabilities that include blink.cmp's completion capabilities AND the `textDocument.foldingRange` capability (`lineFoldingOnly = true`) required by nvim-ufo

