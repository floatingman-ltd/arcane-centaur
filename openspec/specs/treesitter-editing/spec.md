# treesitter-editing Specification

## Purpose

Provides Treesitter-based syntax highlighting and semantic text objects/motions for non-Lisp languages (F#, C#, Haskell, Lua), delivered via the maintained `main` branch of `nvim-treesitter` (and `nvim-treesitter-textobjects`) through Neovim's core treesitter APIs. Treesitter indentation is applied only where `nvim-treesitter` ships an `indents.scm` for the language — among these, Lua alone — so that filetypes without a query keep their own indent handling rather than having it suppressed. Text objects and motions (`af`/`if`, `ac`/`ic`, `aa`/`ia`, `]f`/`[f`, `]F`/`[F`) are gated off for Lisp-family filetypes so vim-sexp retains structural editing there, and no bracket mappings owned by other plugins (gitsigns, vim-unimpaired, diff mode) are overridden.
## Requirements
### Requirement: Treesitter provided via the maintained `main` branch

The configuration SHALL use the `main` branch of `nvim-treesitter` (and `nvim-treesitter-textobjects`), configured through Neovim's core treesitter APIs, and MUST NOT depend on the frozen `master` branch's module system.

#### Scenario: Plugins pinned to main
- **WHEN** `lazy-lock.json` is inspected
- **THEN** both `nvim-treesitter` and `nvim-treesitter-textobjects` are recorded on `branch: "main"`

#### Scenario: No master-only module API is used
- **WHEN** `lua/plugins/treesitter.lua` is loaded on startup
- **THEN** it does not call `require("nvim-treesitter.configs").setup(...)` and `:messages` shows no treesitter configuration errors

### Requirement: Syntax highlighting active for supported non-core languages

The configuration SHALL enable treesitter syntax highlighting for F#, C#, Haskell, and Lua buffers by starting the core highlighter for those filetypes.

#### Scenario: Highlight attaches in an F# buffer
- **WHEN** a `.fsx`/`.fs` file is opened and its parser is installed
- **THEN** `vim.treesitter.highlighter.active[bufnr]` is non-nil for that buffer

#### Scenario: Highlight attaches in a C# buffer
- **WHEN** a `.cs` file is opened and its parser is installed
- **THEN** `vim.treesitter.highlighter.active[bufnr]` is non-nil for that buffer

### Requirement: Selection text objects in non-Lisp buffers

The configuration SHALL provide treesitter selection text objects — `af`/`if` (function outer/inner), `ac`/`ic` (class outer/inner), and `aa`/`ia` (argument outer/inner) — usable with any operator in F#/C#/Haskell/Lua buffers.

#### Scenario: Select a whole function
- **WHEN** the cursor is inside a function in a Lua/C#/F# buffer and the user presses `vaf`
- **THEN** the entire function (signature through end) is visually selected

#### Scenario: Delete a function body
- **WHEN** the cursor is inside a function and the user presses `dif`
- **THEN** only the function body is deleted

#### Scenario: Text objects do not silently no-op on Neovim 0.12
- **WHEN** any select text object is invoked on Neovim 0.12
- **THEN** it selects the corresponding node and does not raise a `tsrange`/removed-API error

### Requirement: Function motions in non-Lisp buffers

The configuration SHALL provide treesitter function motions `]f`/`[f` (next/previous function start) and `]F`/`[F` (next/previous function end), adding each jump to the jumplist.

#### Scenario: Jump to next function
- **WHEN** the user presses `]f` in a buffer with multiple functions
- **THEN** the cursor moves to the start of the next function

#### Scenario: Class motions are not mapped
- **WHEN** the user presses `]c`/`[c`
- **THEN** the built-in diff-mode change navigation is used (not a treesitter motion)

### Requirement: Text objects disabled in Lisp-family buffers

The configuration SHALL NOT attach treesitter text objects in `lisp`, `clojure`, `scheme`, `fennel`, or `janet` buffers, so that vim-sexp continues to provide structural `af`/`if` form objects there.

#### Scenario: vim-sexp retained in a Clojure buffer
- **WHEN** the user presses `vaf` on a form in a `.clj` buffer
- **THEN** the selection follows the s-expression (vim-sexp), not a treesitter function node

### Requirement: Unrelated bracket mappings preserved

The configuration SHALL NOT override existing bracket mappings owned by other plugins — gitsigns hunk motions (`]h`/`[h`), vim-unimpaired buffer motions (`]b`/`[b`), and diff-mode change motions (`]c`/`[c`).

#### Scenario: gitsigns hunk motion still works
- **WHEN** the user presses `]h` in a buffer with unstaged hunks
- **THEN** the cursor jumps to the next hunk (gitsigns), unaffected by treesitter motions

### Requirement: Treesitter indentation only where a query exists

Treesitter indentation SHALL be enabled for a filetype only when `nvim-treesitter` ships an `indents.scm` query for that filetype's language. Where no query exists, `indentexpr` SHALL be left unset so the filetype's own indent handling applies — `'lisp'` and `lispwords` in the Lisp-family ftplugins, and `autoindent`/`smartindent` elsewhere.

The check SHALL be performed at runtime against the queries actually present, rather than against a hardcoded list of filetypes, so it remains correct as queries are added or removed upstream. Because filetype and treesitter language names differ (`lisp` is `commonlisp`, `janet` is `janet_simple`, `cs` is `c_sharp`), the filetype SHALL be resolved to its language before the query is looked up.

#### Scenario: A filetype with an indent query gets treesitter indenting
- **WHEN** a Lua buffer is opened
- **THEN** `indentexpr` SHALL be set to the treesitter indent expression

#### Scenario: A filetype without an indent query is left alone
- **WHEN** a C# or Haskell buffer is opened
- **THEN** `indentexpr` SHALL be empty
- **AND** pressing Enter on an indented line SHALL produce a new line at the same indent, via `autoindent`/`smartindent`

#### Scenario: Lisp-family indent configuration is not suppressed
- **WHEN** a Common Lisp, Clojure, Scheme or Janet buffer is opened
- **THEN** `indentexpr` SHALL be empty
- **AND** the `'lisp'` option set by that filetype's ftplugin SHALL govern indentation
- **AND** the `lispwords` entries added for Common Lisp SHALL take effect

#### Scenario: Filetype names are resolved to language names
- **WHEN** the query lookup is performed for the `lisp`, `janet` or `cs` filetypes
- **THEN** it SHALL resolve them to `commonlisp`, `janet_simple` and `c_sharp` respectively before checking for a query

#### Scenario: The rule follows upstream rather than a fixed list
- **WHEN** `nvim-treesitter` adds an `indents.scm` for a language already in use
- **THEN** that filetype SHALL gain treesitter indenting with no configuration change

