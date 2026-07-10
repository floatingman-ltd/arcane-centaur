## ADDED Requirements

### Requirement: Getting-started documents the complete base toolchain

The getting-started guide SHALL document every shared external tool the config depends on, organised into "required for everyone" versus "required per feature", so a new machine can be provisioned from one page. It SHALL include a feature→dependency table.

#### Scenario: C compiler for treesitter parsers is called out
- **WHEN** a reader provisions a fresh machine
- **THEN** getting-started SHALL state that a C compiler (`cc`/`gcc`; `build-essential`) is required to compile nvim-treesitter parsers
- **THEN** it SHALL note that a missing compiler causes parsers to fail to install silently (no syntax highlighting for those languages)

#### Scenario: Node/npm build requirement is listed
- **WHEN** a reader reviews base dependencies
- **THEN** getting-started SHALL list Node.js + npm as required by plugin build steps, naming both `markdown-preview.nvim` and `bracey.vim`

#### Scenario: Docker feature matrix is present
- **WHEN** a reader wants to know which features require Docker
- **THEN** getting-started SHALL provide a table mapping each Docker-backed feature (AI/Ollama, diagrams/PlantUML, Markdown export, presentations/MARP, AsciiDoc/Antora preview, Lisp REPL containers) to its Docker service/compose file

### Requirement: Getting-started links to the Language Setup matrix

The getting-started guide SHALL link to the Language Setup matrix page for language-specific prerequisites instead of duplicating per-language tool lists.

#### Scenario: Reader is directed to per-language setup
- **WHEN** a reader finishes the base setup and needs language-specific tools
- **THEN** getting-started SHALL link (xref) to the Language Setup page
