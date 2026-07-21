# asciidoc-syntax Specification

## Purpose
TBD - created by archiving change 02-enhance-asciidoc-authoring. Update Purpose after archive.
## Requirements
### Requirement: AsciiDoc syntax, folding, and fenced-code highlighting
AsciiDoc files SHALL be highlighted, foldable, and fenced-code-aware via `habamax/vim-asciidoctor`, loaded lazily on the `asciidoctor` filetype. The plugin's own document-compile commands SHALL be disabled so the existing Docker/Antora preview remains the single conversion path.

#### Scenario: AsciiDoc syntax highlighting is active
- **WHEN** the user opens a `.adoc` or `.asciidoc` file
- **THEN** vim-asciidoctor syntax highlighting SHALL be applied (headings, attributes, lists, inline formatting)

#### Scenario: Fenced code blocks are language-highlighted
- **WHEN** the buffer contains a `[source,lua]` (or other configured language) delimited block
- **THEN** the block contents SHALL be highlighted as that language

#### Scenario: Sections fold
- **WHEN** the user folds within an AsciiDoc document
- **THEN** section/heading-based folds SHALL be available

### Requirement: Canonical `asciidoctor` filetype with preserved preview maps
`*.adoc` / `*.asciidoc` files SHALL resolve to the filetype `asciidoctor`, registered at startup via `vim.filetype.add` (not dependent on the plugin's `ftdetect` load order). The existing Docker Asciidoctor and Antora preview keymaps SHALL continue to work under this filetype.

#### Scenario: Files resolve to the asciidoctor filetype
- **WHEN** the user opens a `.adoc` file (including the first one opened in a session, cold)
- **THEN** `:set filetype?` SHALL report `asciidoctor`

#### Scenario: Docker HTML preview still works
- **WHEN** the user presses `<localleader>p` or `<localleader>pp` in an AsciiDoc buffer in a graphical environment with Docker running
- **THEN** the buffer SHALL be converted to HTML via Docker Asciidoctor and opened in the system browser, exactly as before the change

#### Scenario: Antora full-site preview still works
- **WHEN** the user presses `<localleader>pa` in an AsciiDoc buffer with Docker running
- **THEN** the Antora site SHALL build via Docker and `build/site/index.html` SHALL open in the browser

#### Scenario: No stale asciidoc-keyed behavior
- **WHEN** the configuration is loaded after the change
- **THEN** no code keyed to the legacy `asciidoc` filetype SHALL remain (the ftplugin is renamed to `asciidoctor.lua`; no other module keys on `asciidoc`)

