# todo-comments Specification

## Purpose
Highlights `TODO`, `FIXME`, `HACK`, `NOTE`, `WARN` and `PERF` annotations with signs across every buffer via `folke/todo-comments.nvim`, and makes them listable project-wide through both pickers this configuration already uses — fzf-lua at `<leader>xT` and trouble at `<leader>xt`.

One constraint is explicit rather than incidental: it must not map `]t` or `[t`. Those are vim-unimpaired's tag-navigation maps, and todo-comments' defaults would otherwise claim them.

## Requirements
### Requirement: Annotation comment highlighting and listing
`TODO`, `FIXME`, `HACK`, `NOTE`, `WARN`, and `PERF` comments SHALL be highlighted with signs across all buffers via `folke/todo-comments.nvim`, and SHALL be listable project-wide through both fzf-lua and trouble.

#### Scenario: Annotations are highlighted
- **WHEN** a buffer contains a `TODO:` or `FIXME:` comment
- **THEN** the keyword SHALL be highlighted and a sign SHALL appear for the line

#### Scenario: List todos via fzf-lua
- **WHEN** the user presses `<leader>xT` (`:TodoFzfLua`)
- **THEN** all project annotation comments SHALL be listed in an fzf-lua picker

#### Scenario: List todos via trouble
- **WHEN** the user presses `<leader>xt` (`:TodoTrouble`)
- **THEN** all project annotation comments SHALL be listed in a trouble panel

### Requirement: No collision with vim-unimpaired
todo-comments SHALL NOT map `]t` / `[t`; those bindings SHALL remain vim-unimpaired's tag-navigation maps.

#### Scenario: Tag navigation preserved
- **WHEN** the user presses `]t` or `[t`
- **THEN** vim-unimpaired's `:tnext` / `:tprev` behavior SHALL run, not a todo jump

