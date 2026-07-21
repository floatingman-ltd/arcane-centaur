# diagnostics-panel Specification

## Purpose
TBD - created by archiving change 06-add-diagnostics-todo-panel. Update Purpose after archive.
## Requirements
### Requirement: Persistent diagnostics and list panel via trouble.nvim
A persistent, filterable panel SHALL be available via `folke/trouble.nvim` (stable v3) for diagnostics (project and buffer), symbols, LSP references, the quickfix list, and the location list, opened from the `<leader>x` group.

#### Scenario: Project diagnostics panel
- **WHEN** the user presses `<leader>xx` in a buffer with LSP diagnostics present in the workspace
- **THEN** a trouble panel SHALL open listing diagnostics, and selecting an entry SHALL jump to its location

#### Scenario: Buffer-only diagnostics
- **WHEN** the user presses `<leader>xX`
- **THEN** the panel SHALL show diagnostics for the current buffer only

#### Scenario: Quickfix and location lists
- **WHEN** the user presses `<leader>xq` or `<leader>xl`
- **THEN** trouble SHALL display the quickfix list or location list respectively

### Requirement: Native diagnostics navigation preserved
The trouble panel SHALL be additive: the existing native diagnostics maps SHALL remain unchanged.

#### Scenario: Jump maps and float unchanged
- **WHEN** the user presses `[d`, `]d`, or `<leader>e`
- **THEN** they SHALL jump to the previous/next diagnostic and open the line-diagnostics float respectively, exactly as before this change (not delegated to trouble)

