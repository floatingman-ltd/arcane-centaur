## ADDED Requirements

### Requirement: Annotated foldtext
Closed folds display an annotated summary line showing the fold's opening text and line count.

#### Scenario: Closed fold display
- **WHEN** a fold is closed
- **THEN** the fold line shows `▸ <opening text> ··· N lines` where N is the number of hidden lines

### Requirement: Fold-on-demand
Files always open fully expanded; the user folds explicitly.

#### Scenario: File opens expanded
- **WHEN** any file is opened
- **THEN** all folds are open (nothing is hidden)

#### Scenario: Manual fold toggle
- **WHEN** the user presses `za` on a foldable block
- **THEN** the fold toggles between open and closed

#### Scenario: Collapse all / expand all
- **WHEN** the user presses `zM`
- **THEN** all folds in the buffer are closed
- **WHEN** the user presses `zR`
- **THEN** all folds in the buffer are opened

### Requirement: LSP-aware folds for C#
C# buffers use Roslyn LSP fold ranges, enabling precise folds for `#region`/`#endregion` blocks and method/class boundaries.

#### Scenario: C# region fold
- **WHEN** a C# buffer has `#region` / `#endregion` blocks and Roslyn is attached
- **THEN** each region is foldable as a single fold unit

#### Scenario: LSP fallback to treesitter
- **WHEN** Roslyn is not yet attached (e.g. file just opened)
- **THEN** treesitter folds are used as a fallback

### Requirement: Treesitter folds for all other languages
Non-C# buffers use treesitter AST structure to determine fold ranges.

#### Scenario: Function fold in Lua
- **WHEN** the cursor is inside a Lua function body
- **THEN** the function is a foldable unit

#### Scenario: Indent fallback
- **WHEN** no treesitter grammar is available for the filetype
- **THEN** indentation-based folding is used as a fallback
