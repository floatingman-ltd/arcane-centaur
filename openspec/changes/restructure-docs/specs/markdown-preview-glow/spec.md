## MODIFIED Requirements

### Requirement: Glow documentation lives in the Markdown guide
The documentation for the Glow console preview feature SHALL be located in
`documentation/guides/markdown.md` and its generated AsciiDoc equivalent. It SHALL NOT
be documented in `cli-console-mode.md` (which is being dissolved). All functional
requirements for glow behaviour are unchanged.

#### Scenario: Glow setup instructions found in markdown guide
- **WHEN** a reader looks for how to install or configure glow
- **THEN** the instructions SHALL be in `documentation/guides/markdown.md`
- **THEN** `cli-console-mode.md` SHALL NOT exist as a standalone file
