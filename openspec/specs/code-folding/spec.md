## Purpose

Provides structured, on-demand code folding via `nvim-ufo` with annotated foldtext showing the fold's opening text and hidden-line count. Fold ranges come from the LSP provider — which gives C# precise `#region` folds via Roslyn — with an indent fallback. Treesitter folding is deliberately disabled; markdown uses indent only, and asciidoctor is left to manage its own folds.

## Requirements

### Requirement: Annotated foldtext
A closed fold SHALL display a summary line showing the fold's opening text followed by the number of lines it hides.

#### Scenario: Closed fold display
- **WHEN** a fold is closed
- **THEN** the fold line SHALL show the opening text followed by `··· N lines ···`, where N is the number of hidden lines
- **THEN** the appended summary SHALL be highlighted with the `UfoFoldedEllipsis` group

#### Scenario: Long opening line is truncated
- **WHEN** the fold's opening text is too wide to fit alongside the summary
- **THEN** the opening text SHALL be truncated so the summary remains visible

### Requirement: Fold-on-demand
Files SHALL open fully expanded and folds SHALL only close when the user asks; `foldlevel` and `foldlevelstart` are both 99.

#### Scenario: File opens expanded
- **WHEN** any file is opened
- **THEN** all folds SHALL be open (nothing is hidden)

#### Scenario: Manual fold toggle
- **WHEN** the user presses `za` on a foldable block
- **THEN** the fold SHALL toggle between open and closed

#### Scenario: Collapse all / expand all
- **WHEN** the user presses `zM`
- **THEN** all folds in the buffer SHALL be closed
- **WHEN** the user presses `zR`
- **THEN** all folds in the buffer SHALL be opened

### Requirement: LSP-aware folds for C#
C# buffers SHALL use Roslyn LSP fold ranges, giving precise folds for `#region`/`#endregion` blocks and method/class boundaries.

#### Scenario: C# region fold
- **WHEN** a C# buffer has `#region` / `#endregion` blocks and Roslyn is attached
- **THEN** each region SHALL be foldable as a single fold unit

#### Scenario: Fallback before the server attaches
- **WHEN** Roslyn is not yet attached (e.g. the file has just opened)
- **THEN** indent-based folds SHALL be used as the fallback

### Requirement: LSP folds with indent fallback elsewhere
All other filetypes SHALL use the LSP fold provider with an indent fallback. Treesitter folding SHALL NOT be used for any filetype — it errors on special buffers such as the `glow` preview.

#### Scenario: Function fold in an LSP-backed buffer
- **WHEN** the cursor is inside a Lua function body and a language server is attached
- **THEN** the function SHALL be a foldable unit

#### Scenario: Indent fallback
- **WHEN** no language server is attached for the filetype
- **THEN** indentation-based folding SHALL be used as the fallback

### Requirement: Per-filetype fold provider exceptions
Markdown and asciidoctor buffers SHALL opt out of the default provider chain.

#### Scenario: Markdown folds by indent only
- **WHEN** a markdown buffer is opened
- **THEN** the indent provider SHALL be used without the LSP provider

#### Scenario: Asciidoctor owns its own folds
- **WHEN** an asciidoctor buffer is opened
- **THEN** ufo SHALL supply no fold provider, leaving section folding to `vim-asciidoctor`
