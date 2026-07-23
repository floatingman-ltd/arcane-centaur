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

### Requirement: Edits that bypass format-on-save are kept stylua-clean
Because `conform.nvim`'s format-on-save fires only on a user save in Neovim, edits made through other
paths SHALL also be normalized: a `PostToolUse` hook SHALL format Lua files written by Claude Code's
Edit/Write tools, and the `add-neovim-feature` skill SHALL run stylua as a validation step. The hook
SHALL degrade gracefully — it SHALL NOT block an edit when stylua is unavailable or the file does not
yet parse.

#### Scenario: Claude Code tool edit is auto-formatted
- **WHEN** a `.lua` file is written via Claude Code's Edit or Write tool
- **THEN** the `PostToolUse` hook SHALL run stylua on that file, leaving it stylua-clean

#### Scenario: stylua absent does not break edits
- **WHEN** a `.lua` file is written via a Claude Code tool and `stylua` is not on `$PATH`
- **THEN** the hook SHALL warn but SHALL NOT block or fail the edit

### Requirement: The one-time reformat does not pollute line history
The repository SHALL carry a `.git-blame-ignore-revs` file listing the tree-wide reformat commit, so
that `git blame` (on GitHub automatically, and locally when `blame.ignoreRevsFile` is configured)
attributes lines to their real authoring commit rather than the mechanical formatting commit.

#### Scenario: Blame skips the reformat commit
- **WHEN** `git blame` is run with `.git-blame-ignore-revs` honored on a reformatted file
- **THEN** reformatted lines SHALL be attributed to their prior substantive commit, not the stylua
  reformat commit
