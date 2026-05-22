## MODIFIED Requirements

### Requirement: Console detection documentation lives in the Architecture guide
The `term.is_console` console detection documentation SHALL be located in
`documentation/guides/architecture.md` and its generated AsciiDoc equivalent.
The Open URL console behaviour documentation SHALL also move there. Neither
SHALL remain in `cli-console-mode.md` (which is being dissolved). All existing
functional requirements for console detection behaviour SHALL remain unchanged.

#### Scenario: Console detection explanation found in architecture guide
- **WHEN** a reader looks for how console mode is detected
- **THEN** the explanation SHALL be in `documentation/guides/architecture.md`
- **THEN** `cli-console-mode.md` SHALL NOT exist as a standalone file
