## ADDED Requirements

### Requirement: All seven core lessons exist as Antora pages
The seven core lessons of the Janet learning series SHALL each have a hand-authored AsciiDoc
file at `docs/modules/ROOT/pages/learning/janet/NN-topic.adoc`. Lessons 01 and 02 already
exist and are frozen. Lessons 03–07 SHALL be created as part of this change. Lesson 03 SHALL
be created from the existing Markdown source. Lessons 04–07 SHALL be newly authored. No
Markdown copies SHALL be created alongside these `.adoc` files.

### Requirement: Stale Markdown files are removed
The files `docs/learning/janet/README.md` and `docs/learning/janet/03-functions.md` SHALL be
deleted once their AsciiDoc counterparts exist in `docs/modules/ROOT/pages/learning/janet/`.
AsciiDoc is the sole canonical source. If the `docs/learning/janet/` directory becomes empty
after removal, it SHALL also be deleted.

#### Scenario: Lesson 03 Antora page exists
- **WHEN** a reader navigates to the Janet learning section of the docs site
- **THEN** lesson 03 (Functions in Depth) SHALL be accessible as an Antora page

#### Scenario: Lessons 04–07 Antora pages exist
- **WHEN** a reader navigates to the Janet learning section of the docs site
- **THEN** lessons 04 (Sequences), 05 (Modules), 06 (Error Handling), and 07 (Macros) SHALL each be accessible as Antora pages

### Requirement: Series index exists as an Antora page
A `docs/modules/ROOT/pages/learning/janet/index.adoc` page SHALL exist listing all seven
core lessons with links to each `.adoc` page.

#### Scenario: Index page is reachable from nav
- **WHEN** a reader opens the Janet Learning section in the sidebar
- **THEN** the index page SHALL be listed and navigable

### Requirement: Each lesson (03–07) has a consistent nav bar
Every lesson page in the range 03–07 SHALL include a nav bar at the top using AsciiDoc xref
format with `← Previous`, `Index`, and `Next →` links appropriate to its position in the
series. Lesson 03 SHALL include a `← Previous` link to `02-first-steps.adoc`. Lesson 07
SHALL omit the `Next →` link. Lessons 01 and 02 are frozen and are not in scope for nav bar
changes.

#### Scenario: Middle lesson nav bar
- **WHEN** a reader opens lesson 04 (Sequences)
- **THEN** the nav bar SHALL contain a link to lesson 03, the index, and lesson 05

#### Scenario: Last lesson nav bar
- **WHEN** a reader opens lesson 07 (Macros)
- **THEN** the nav bar SHALL contain a link to lesson 06 and the index
- **THEN** there SHALL be no `Next →` link

### Requirement: Each lesson is REPL-driven with Conjure eval examples
Every lesson SHALL contain interactive code examples intended to be evaluated directly
in a Conjure REPL. Examples SHALL be presented in `[source,janet]` code blocks. Each
lesson SHALL open with an instruction to open a scratch file and the Conjure log.

#### Scenario: Lesson contains evaluable examples
- **WHEN** a reader opens any lesson with a Conjure REPL running
- **THEN** every code block in the lesson SHALL be evaluable by copying it into a Janet buffer and pressing `,ee` or `,eb`

### Requirement: Nav sidebar lists lessons 03–07
`docs/modules/ROOT/nav.adoc` SHALL list lessons 03–07 under the Janet Learning section,
following the existing pattern for 01 and 02.

#### Scenario: All lessons appear in sidebar
- **WHEN** a reader opens the docs site
- **THEN** all seven lessons SHALL appear in the Janet Learning section of the nav sidebar
