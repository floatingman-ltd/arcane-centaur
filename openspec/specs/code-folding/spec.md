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
C# buffers SHALL fold using ranges supplied by the Roslyn language server, so that `#region` blocks fold as single units. The LSP provider SHALL remain first in the chain for C#, so that adding treesitter to the chain does not displace server-supplied region folds.

#### Scenario: Region fold
- **WHEN** a C# buffer has `#region` / `#endregion` blocks and Roslyn is attached
- **THEN** each region SHALL be foldable as a single fold unit

#### Scenario: Fallback before the server attaches
- **WHEN** Roslyn is not yet attached (e.g. the file has just opened)
- **THEN** treesitter folds SHALL be used as the fallback, C# having a `folds.scm` query

### Requirement: Per-filetype fold provider exceptions
Markdown and asciidoctor buffers SHALL deviate from the default provider chain.

Markdown SHALL use the treesitter provider with an indent fallback, so that document structure is foldable by heading while list folding is retained. The LSP provider is deliberately omitted: no markdown language server is currently installed, and with only two provider slots available including it would displace the indent fallback that list folding depends on.

Asciidoctor SHALL continue to opt out of ufo entirely.

#### Scenario: Markdown folds by heading
- **WHEN** a markdown buffer containing headings is opened
- **THEN** each heading SHALL begin a foldable section
- **AND** nested headings SHALL produce nested fold levels

#### Scenario: Markdown list folding is retained
- **WHEN** a markdown buffer contains nested lists
- **THEN** those lists SHALL remain foldable

#### Scenario: Asciidoctor owns its own folds
- **WHEN** an asciidoctor buffer is opened
- **THEN** ufo SHALL supply no fold provider, leaving section folding to `vim-asciidoctor`

### Requirement: LSP folds with a query-appropriate fallback elsewhere
All other filetypes SHALL use the LSP fold provider first, so server-supplied folds take precedence where a language server is attached. The fallback provider SHALL be treesitter where the language ships a `folds.scm` query, and indent where it does not. The fallback SHALL be selected by checking for the query rather than from a fixed list of filetypes, so it stays correct as queries are added or removed upstream.

Exactly two providers SHALL be supplied. `nvim-ufo` accepts only a main and a fallback; supplying a third causes it to raise an error and produce no folds at all, so a three-stage LSP/treesitter/indent chain is not available.

Treesitter folding was previously disabled for every filetype. The recorded reason was that it errored on special buffers such as the `glow` preview — a fix made broader than its cause, which removed structural folding from every language to resolve an error in one plugin's terminal buffer. `glow` has since been removed, its replacement float does not reproduce the problem, and `nvim-ufo` now checks for a fold query before using the provider. The exclusion is retained here as history so the reason for the original decision, and the reason it no longer applies, both remain discoverable.

#### Scenario: Function fold in an LSP-backed buffer
- **WHEN** the cursor is inside a Lua function body and a language server is attached
- **THEN** the function SHALL be a foldable unit

#### Scenario: Treesitter folds where no server is attached
- **WHEN** a buffer's language ships a `folds.scm` query and no language server is attached
- **THEN** treesitter SHALL supply structural folds

#### Scenario: Languages without a fold query fall back to indent
- **WHEN** a buffer's language ships no `folds.scm` query
- **THEN** the indent provider SHALL be supplied as the fallback instead of treesitter
- **AND** folding SHALL remain available for that filetype

#### Scenario: No more than two providers are supplied
- **WHEN** the fold provider list is produced for any filetype
- **THEN** it SHALL contain at most two entries
- **AND** no `UnhandledPromiseRejection` SHALL occur, and folds SHALL be produced

