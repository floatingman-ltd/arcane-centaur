## MODIFIED Requirements

### Requirement: PlantUML ASCII documentation lives in the Diagrams guide
The documentation for the `:PumlPreviewAscii` command SHALL be located in
`documentation/guides/diagrams.md` and its generated AsciiDoc equivalent. It SHALL NOT
be documented in `cli-console-mode.md` (which is being dissolved). All functional
requirements for ASCII preview behaviour are unchanged.

#### Scenario: ASCII preview instructions found in diagrams guide
- **WHEN** a reader looks for how to use or configure PlantUML ASCII preview
- **THEN** the instructions SHALL be in `documentation/guides/diagrams.md`
- **THEN** `cli-console-mode.md` SHALL NOT exist as a standalone file
