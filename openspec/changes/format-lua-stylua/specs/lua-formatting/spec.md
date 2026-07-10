## ADDED Requirements

### Requirement: Lua style is pinned and the whole tree conforms
The repository SHALL include a `.stylua.toml` pinning stylua to the project style
(`indent_type = "Spaces"`, `indent_width = 2`), and every committed Lua file SHALL already conform
to stylua under that config, so format-on-save is a no-op on files that have not otherwise changed.

#### Scenario: The tree is already stylua-clean
- **WHEN** `stylua --check .` is run at the repository root
- **THEN** it SHALL report no formatting differences

#### Scenario: Editing a file yields a minimal diff
- **WHEN** a contributor edits and saves a Lua file (conform runs stylua on save)
- **THEN** only the lines they changed SHALL differ — stylua SHALL NOT reindent or rewrap unrelated
  lines in the file
