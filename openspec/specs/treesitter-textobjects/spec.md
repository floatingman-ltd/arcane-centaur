# treesitter-textobjects Specification

## Purpose
Provides treesitter-based select text objects — `af`/`if` for a function, `ac`/`ic` for a class, `aa`/`ia` for an argument — together with `]f`/`[f`/`]F`/`[F` motions between functions, for F#, Haskell, C# and Lua.

Where it does *not* apply is as much of the capability as where it does. The text objects are disabled for lisp, clojure, scheme, fennel and janet, so vim-sexp keeps `af`/`if`/`aF`/`iF` as s-expression form objects in exactly the languages where a form, not a function, is the unit you want to act on. The motion keys are likewise chosen to avoid vim-unimpaired's bracket maps, gitsigns' `]h`/`[h`, and the class motions `]c`/`[c`.

**One requirement below is out of date, and is left standing rather than silently edited.** *Branch-consistent treesitter setup* requires the `master` branch; both plugins are now pinned to `main` (`lua/plugins/treesitter.lua`), changed by `align-treesitter-providers` because the master-branch API crashes on Neovim 0.12. The intent behind the requirement still holds exactly — the two plugins must be on the same branch, so that the configured API is the one that actually runs — but the branch it names is wrong, and correcting a requirement needs its own change rather than a Purpose rewrite.

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

