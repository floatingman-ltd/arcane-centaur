## MODIFIED Requirements

### Requirement: LSP folds with indent fallback elsewhere
All other filetypes SHALL use a fold provider chain of LSP, then treesitter, then indent. The LSP provider SHALL be consulted first so server-supplied folds take precedence where a language server is attached. Treesitter folding SHALL be used where the language ships a `folds.scm` query and no LSP folds are available; where no such query exists the provider SHALL degrade to the next in the chain rather than erroring.

Treesitter folding was previously disabled for every filetype. The recorded reason was that it errored on special buffers such as the `glow` preview — a fix made broader than its cause, which removed structural folding from every language to resolve an error in one plugin's terminal buffer. `glow` has since been removed, its replacement float does not reproduce the problem, and `nvim-ufo` now checks for a fold query before using the provider. The exclusion is retained here as history so the reason for the original decision, and the reason it no longer applies, both remain discoverable.

#### Scenario: Function fold in an LSP-backed buffer
- **WHEN** the cursor is inside a Lua function body and a language server is attached
- **THEN** the function SHALL be a foldable unit

#### Scenario: Treesitter folds where no server is attached
- **WHEN** a buffer's language ships a `folds.scm` query and no language server is attached
- **THEN** treesitter SHALL supply structural folds

#### Scenario: Languages without a fold query degrade quietly
- **WHEN** a buffer's language ships no `folds.scm` query
- **THEN** the treesitter provider SHALL be skipped without error
- **AND** indentation-based folding SHALL be used instead

#### Scenario: Indent fallback
- **WHEN** no language server is attached and no fold query exists for the filetype
- **THEN** indentation-based folding SHALL be used as the fallback

### Requirement: Per-filetype fold provider exceptions
Markdown and asciidoctor buffers SHALL deviate from the default provider chain.

Markdown SHALL use the LSP, treesitter and indent providers, so that document structure is foldable by heading. The LSP provider is included although no markdown language server is currently installed: it contributes nothing while absent, and folds improve automatically if one is added.

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

### Requirement: LSP-aware folds for C#
C# buffers SHALL fold using ranges supplied by the Roslyn language server, so that `#region` blocks fold as single units. The LSP provider SHALL remain first in the chain for C#, so that adding treesitter to the chain does not displace server-supplied region folds.

#### Scenario: Region fold
- **WHEN** a C# buffer has `#region` / `#endregion` blocks and Roslyn is attached
- **THEN** each region SHALL be foldable as a single fold unit

#### Scenario: Fallback before the server attaches
- **WHEN** Roslyn is not yet attached (e.g. the file has just opened)
- **THEN** treesitter or indent-based folds SHALL be used as the fallback
