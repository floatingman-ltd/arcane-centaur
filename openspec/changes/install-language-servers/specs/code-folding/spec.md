## MODIFIED Requirements

### Requirement: Per-filetype fold provider exceptions
Markdown and asciidoctor buffers SHALL deviate from the default provider chain.

Markdown SHALL use the treesitter provider with an indent fallback, so that document structure is foldable by heading while list folding is retained. The LSP provider is deliberately omitted: `marksman`, the markdown language server this configuration installs, advertises no `foldingRangeProvider`, so the slot would carry nothing — and with only two provider slots available, including it would displace the indent fallback that list folding depends on.

Asciidoctor SHALL continue to opt out of ufo entirely.

#### Scenario: Markdown folds by heading
- **WHEN** a markdown buffer containing headings is opened
- **THEN** each heading SHALL begin a foldable section
- **AND** nested headings SHALL produce nested fold levels

#### Scenario: Markdown list folding is retained
- **WHEN** a markdown buffer contains nested lists
- **THEN** those lists SHALL remain foldable

#### Scenario: Installing the markdown language server changes nothing
- **WHEN** `marksman` is attached to a markdown buffer
- **THEN** the provider chain SHALL remain treesitter then indent
- **THEN** the folds available SHALL be unchanged from before the server was installed

#### Scenario: Asciidoctor owns its own folds
- **WHEN** an asciidoctor buffer is opened
- **THEN** ufo SHALL supply no fold provider, leaving section folding to `vim-asciidoctor`
