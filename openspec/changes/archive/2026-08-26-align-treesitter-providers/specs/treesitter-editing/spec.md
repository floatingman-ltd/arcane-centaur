## ADDED Requirements

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
