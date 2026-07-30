## ADDED Requirements

### Requirement: Language Setup matrix page exists

A "Language Setup" page SHALL exist at `docs/modules/ROOT/pages/languages/setup.adoc` that lists, per language/family, the external prerequisites the config needs, with an install command (or link) for each and a link to that language's detailed guide.

#### Scenario: A reader can find everything needed for one language
- **WHEN** a reader wants to work with a supported language (e.g. C#)
- **THEN** the page SHALL show that language's row/section with its LSP server, REPL/runtime, formatter, debugger, and treesitter parser, each with a one-line install command or link

#### Scenario: All supported languages are covered
- **WHEN** the page is read
- **THEN** it SHALL cover Lua, .NET (C# and F#), Haskell, and the Lisp family (Common Lisp, Clojure, Scheme, Fennel, Janet)

#### Scenario: Each row links to the detailed guide
- **WHEN** a reader needs more than the one-liner
- **THEN** each language entry SHALL link (xref) to that language's guide Prerequisites section

### Requirement: Treesitter parser prerequisite is stated

The Language Setup page SHALL state that treesitter parsers are compiled from source and therefore require a C compiler (`cc`/`gcc`; `build-essential`), cross-referencing the base setup guide.

#### Scenario: Parser compilation prerequisite is discoverable
- **WHEN** a reader checks what a language needs for syntax highlighting
- **THEN** the page SHALL note the C-compiler requirement (or link to getting-started where it is stated)

### Requirement: Language guides keep a consistent Prerequisites section

Each language guide (dotnet, lisp, haskell, janet, lua) SHALL contain a Prerequisites section listing only that language's own tools; base/system tools SHALL NOT be duplicated there (they live in getting-started), and the setup matrix SHALL link to these sections.

#### Scenario: A language guide has its own Prerequisites
- **WHEN** a language guide is opened
- **THEN** it SHALL have a Prerequisites section covering its language-specific tools
- **THEN** it SHALL NOT duplicate base system tools (Docker/Node/build-essential) beyond a cross-reference

### Requirement: The Language Setup page is registered in the nav

The Language Setup page SHALL be listed in `docs/modules/ROOT/nav.adoc` under the Languages group.

#### Scenario: Page appears in the site nav
- **WHEN** the Antora site is built
- **THEN** the Language Setup page SHALL appear as an `xref` entry in the Languages section of the nav
