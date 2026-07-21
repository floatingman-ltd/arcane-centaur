# treesitter-textobjects Specification

## Purpose
TBD - created by archiving change 01-add-treesitter-textobjects. Update Purpose after archive.
## Requirements
### Requirement: Treesitter select and move text objects for non-Lisp languages
Treesitter-based select text objects (`af`/`if` function, `ac`/`ic` class, `aa`/`ia` argument) and function move motions (`]f`/`[f`/`]F`/`[F`) SHALL be available via `nvim-treesitter-textobjects` for F#, Haskell, C#, and Lua. The `haskell` parser SHALL be added to `ensure_installed`.

#### Scenario: Select a function
- **WHEN** the user runs `vaf` (or `daf`/`yaf`) in an F#, Haskell, C#, or Lua buffer with the cursor in a function
- **THEN** the whole function SHALL be selected (or deleted/yanked)

#### Scenario: Select inner and argument objects
- **WHEN** the user runs `vif` or `via` in a supported buffer
- **THEN** the function body or the argument under the cursor SHALL be selected respectively

#### Scenario: Move between functions
- **WHEN** the user presses `]f` or `[f` in a supported buffer
- **THEN** the cursor SHALL jump to the start of the next or previous function

### Requirement: Lisp-family editing reserved for vim-sexp
Treesitter text objects SHALL be disabled for lisp, clojure, scheme, fennel, and janet filetypes so that vim-sexp retains the `af`/`if`/`aF`/`iF` form text objects.

#### Scenario: vim-sexp keeps form objects in Lisp
- **WHEN** the user runs `vaf` in a `.clj`, `.lisp`, `.scheme`, or `.janet` buffer
- **THEN** vim-sexp's s-expression form SHALL be selected, not a Treesitter function object

### Requirement: Branch-consistent treesitter setup
nvim-treesitter and nvim-treesitter-textobjects SHALL be pinned to the `master` branch so the existing `opts`-style configuration (`ensure_installed`/`highlight`/`indent`/`textobjects`) is the API that runs, and Treesitter highlighting SHALL be active.

#### Scenario: Highlighting is active
- **WHEN** the user opens a Lua, F#, C#, or Haskell buffer
- **THEN** Treesitter highlighting SHALL be applied

#### Scenario: Motion keys do not collide
- **WHEN** the move motions are registered
- **THEN** they SHALL use `]f`/`[f`/`]F`/`[F` only, and SHALL NOT remap vim-unimpaired's bracket maps, gitsigns' `]h`/`[h`, or class-motion `]c`/`[c`

