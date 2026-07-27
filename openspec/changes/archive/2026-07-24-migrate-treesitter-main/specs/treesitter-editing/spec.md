## ADDED Requirements

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
