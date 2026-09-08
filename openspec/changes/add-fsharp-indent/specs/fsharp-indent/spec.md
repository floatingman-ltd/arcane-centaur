## ADDED Requirements

### Requirement: F# newline indentation follows the code

Pressing Enter in an F# buffer SHALL indent the new line according to the construct being opened, rather than copying the previous line's indent. A line ending in a construct that opens a body — `=`, `->`, `then`, `else`, `do`, `try`, or a `match` arm — SHALL cause the following line to be indented one `shiftwidth` deeper.

Indentation SHALL be provided by a buffer-local `indentexpr`, so it applies to typed input, to `o`/`O`, and to the reindent operators `=`, `>>` and `<<`.

#### Scenario: A let binding indents its body

- **WHEN** the cursor is at the end of a line reading `    let inner y =` and the user presses Enter and types a character
- **THEN** the new line SHALL be indented 8 columns, one `shiftwidth` deeper than the 4 of the line above

#### Scenario: A match arm indents its body

- **WHEN** the cursor is at the end of a line reading `    | Circle r ->` and the user presses Enter and types a character
- **THEN** the new line SHALL be indented deeper than the arm itself

#### Scenario: A top-level binding indents its body

- **WHEN** the cursor is at the end of a line reading `let greet name =` at column 0 and the user presses Enter and types a character
- **THEN** the new line SHALL be indented 4 columns

#### Scenario: An ordinary expression does not gain indentation

- **WHEN** the cursor is at the end of a line reading `    a + 1`, which opens nothing, and the user presses Enter and types a character
- **THEN** the new line SHALL remain at 4 columns

#### Scenario: indentexpr is set

- **WHEN** an F# buffer is open
- **THEN** `indentexpr` SHALL be non-empty
- **AND** the indent function it names SHALL be defined

### Requirement: Indentation is independent of the language server

Indentation SHALL be supplied by the editor alone, with no dependency on `fsautocomplete`. It SHALL work before the server has attached, when the server is not installed, and in files the server cannot resolve project options for — a standalone `.fsx` script being the known case where option resolution is unreliable.

#### Scenario: Indentation works with no language server on PATH

- **WHEN** Neovim is started with `fsautocomplete` absent from `$PATH` and an F# file is opened
- **THEN** `indentexpr` SHALL still be set and indentation SHALL still follow the code
- **AND** no error SHALL be reported

#### Scenario: Indentation works in a standalone script

- **WHEN** a `.fsx` file outside any project is opened
- **THEN** indentation SHALL behave as it does inside a project, regardless of whether project options resolve

### Requirement: The indent script is vendored, not installed as a plugin

The indent implementation SHALL be carried in this repository as a single file under `indent/`, not obtained through the plugin manager. It SHALL record its upstream source and the exact upstream commit it was taken from, and SHALL retain the upstream attribution.

This exists so the file is recognisably third-party rather than homegrown, so a refresh is a diff against a known commit, and so no part of the plugin it came from is loaded — that plugin ships a competing language-server client, a competing fold method, a competing syntax file and competing REPL keymaps, all of which duplicate working configuration.

#### Scenario: No plugin is added for indentation

- **WHEN** the plugin manager's state is inspected
- **THEN** no F# indent or Ionide plugin SHALL be present
- **AND** no entry for one SHALL appear in the lock file

#### Scenario: Provenance is recorded in the file

- **WHEN** a reader opens the vendored file
- **THEN** it SHALL state the upstream repository, the vendored commit, and why it is vendored rather than installed
- **AND** the upstream maintainer attribution SHALL be intact

#### Scenario: Removing the file restores previous behaviour

- **WHEN** the vendored file is deleted
- **THEN** `indentexpr` SHALL be empty again and indentation SHALL revert to `autoindent`
- **AND** nothing else SHALL be affected

### Requirement: Existing F# behaviour is preserved

Adding indentation SHALL NOT alter anything else about F# editing. In particular the language server, format-on-save, folding, comment handling and REPL keymaps SHALL be untouched.

#### Scenario: Indent settings are unchanged

- **WHEN** an F# buffer is open
- **THEN** `tabstop`, `shiftwidth` and `expandtab` SHALL remain 4, 4 and on, as set by the F# ftplugin

#### Scenario: Folding still comes from the language server

- **WHEN** an F# file in a project is opened with the server attached
- **THEN** folds SHALL still be structural, from the language server rather than from indentation or syntax

#### Scenario: Format-on-save still runs

- **WHEN** an F# file in a project is written
- **THEN** it SHALL still be reformatted by the language server via Fantomas

#### Scenario: Comment behaviour is unchanged

- **WHEN** the user comments a line in an F# buffer
- **THEN** the comment leader SHALL be unchanged from before this capability existed

### Requirement: Indentation ignores delimiters inside comments and strings

When resolving the indent of a closing `}`, `]` or `)`, the matching opening delimiter SHALL be sought in code only. A delimiter appearing inside a comment or a string literal SHALL NOT be treated as a real one.

Detection SHALL use the syntactic information the buffer actually has. Where the buffer is highlighted by treesitter, the capture at the position SHALL decide; where it is not, detection SHALL fall back to Vim `:syntax` information, so behaviour is never worse than the upstream implementation.

Detection SHALL NOT force a parse. It runs inside pair matching, which is called repeatedly from `indentexpr` on keystrokes, so it SHALL rely on the buffer's existing tree and treat an unavailable tree as "not a comment or string".

#### Scenario: A brace inside a line comment is not matched

- **WHEN** a file contains a `{` inside a `//` comment above a real brace-delimited expression
- **AND** the indent of a closing `}` on its own line is resolved
- **THEN** the commented `{` SHALL be ignored and the real opening brace SHALL be matched

#### Scenario: A brace inside a string literal is not matched

- **WHEN** a `{` appears inside a string literal, including a verbatim or triple-quoted literal, or inside a character literal
- **THEN** it SHALL NOT be treated as an opening delimiter

#### Scenario: A brace in a block comment is not matched

- **WHEN** a `{` appears inside an `(* ... *)` block comment
- **THEN** it SHALL NOT be treated as an opening delimiter

#### Scenario: Real code is not mistaken for a comment or string

- **WHEN** the position holds ordinary code, such as the brace of a record expression
- **THEN** detection SHALL report that it is not inside a comment or string

#### Scenario: Detection degrades rather than failing without treesitter

- **WHEN** treesitter highlighting is not active for the buffer
- **THEN** detection SHALL fall back to Vim `:syntax` information
- **AND** SHALL NOT error
