## Purpose

Defines the structure and grouping of the Antora nav sidebar (`docs/modules/ROOT/nav.adoc`).
## Requirements
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

### Requirement: Guides and cheatsheets co-located per topic group

Within each topic group in the nav, an area that has NOT been migrated to the per-plugin page model SHALL list its guide AND cheatsheet together, with the guide before the cheatsheet. An area that HAS been migrated to the per-plugin page model (see the `docs-plugin-page` capability) SHALL instead list one entry per plugin page under that area, and SHALL NOT retain a separate guide+cheatsheet pair for the migrated plugins.

#### Scenario: Git group lists per-plugin pages

- **WHEN** a reader browses the Editor Core group
- **THEN** the Git entries are one nav entry each for the vim-fugitive, gitsigns, and diffview pages
- **AND** no "Git Guide" or "Git Cheatsheet" nav entry remains

#### Scenario: Unmigrated areas keep guide+cheatsheet co-location

- **WHEN** a reader browses an area not yet migrated to the per-plugin model
- **THEN** that area's guide and cheatsheet still appear together, guide before cheatsheet

### Requirement: Lisp and Janet grouped together in nav
The Lisp and Janet guides and cheatsheets SHALL appear adjacent to each other under a
Lisp Family sub-grouping within Languages. They SHALL remain separate files.

#### Scenario: Lisp and Janet are adjacent in nav
- **WHEN** a reader browses the Languages section
- **THEN** Lisp and Janet entries SHALL appear consecutively under a Lisp Family label

