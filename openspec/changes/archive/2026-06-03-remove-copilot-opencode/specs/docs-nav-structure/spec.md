## MODIFIED Requirements

### Requirement: Nav sidebar grouped by topic family
`docs/modules/ROOT/nav.adoc` SHALL organise all pages into named topic groups rather
than a flat alphabetical list. The groups SHALL be:
- **Languages** — .NET Ecosystem (C# + F#), Lisp Family (Lisp + Janet), Haskell
- **Editor Core** — Editing, Navigation, Code Intelligence, Git
- **AI & Automation** — AI Tools
- **Content Creation** — Markdown, Diagrams, Presentations, REST Client
- **Project Tooling** — Jira, Confluence
- **Reference** — Architecture, Clipboard, Getting Started

#### Scenario: Language guides appear under Languages group
- **WHEN** a reader opens the nav sidebar
- **THEN** dotnet, fsharp (merged), lisp, janet, and haskell guides SHALL appear under a Languages heading
- **THEN** dotnet/fsharp SHALL be visually grouped under a .NET Ecosystem sub-entry

#### Scenario: Flat list is replaced
- **WHEN** the nav sidebar is rendered
- **THEN** no ungrouped top-level guide entries SHALL appear outside a named group
