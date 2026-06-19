# Spec: lisp-learning-series

## ADDED Requirements

### Requirement: All eleven core lessons exist as Antora pages
The eleven core lessons SHALL each have a hand-authored AsciiDoc file at `docs/modules/ROOT/pages/learning/lisp/NN-topic.adoc`. No Markdown copies SHALL exist alongside them.

#### Scenario: Core lessons are reachable
- **WHEN** a reader navigates to the Lisp learning section of the docs site
- **THEN** all eleven lessons (01 Setup … 11 Web RESTful Service) SHALL be accessible as Antora pages

### Requirement: Series index exists as an Antora page
A `docs/modules/ROOT/pages/learning/lisp/index.adoc` SHALL list all eleven lessons and the six appendices with links to each page.

#### Scenario: Index reachable from nav
- **WHEN** a reader opens the Lisp Learning section in the sidebar
- **THEN** the index page SHALL be listed and navigable

### Requirement: Each lesson has a consistent nav bar
Every lesson SHALL include an AsciiDoc xref nav bar with previous / index / next links appropriate to its position. Lesson 01 SHALL omit the previous link; lesson 11 SHALL omit the next link.

#### Scenario: Middle lesson nav bar
- **WHEN** a reader opens lesson 06 (CLOS)
- **THEN** the nav bar SHALL link to lesson 05, the index, and lesson 07

#### Scenario: Last lesson nav bar
- **WHEN** a reader opens lesson 11 (Web RESTful Service)
- **THEN** the nav bar SHALL link to lesson 10 and the index, with no next link

### Requirement: Each lesson is REPL-driven with Conjure eval examples
Every lesson SHALL contain `[source,lisp]` code blocks intended for evaluation in a Conjure REPL, and SHALL open with an instruction to start the REPL container and open the Conjure log.

#### Scenario: Lesson contains evaluable examples
- **WHEN** a reader opens any lesson with a Conjure REPL running
- **THEN** every code block SHALL be evaluable via `,ee` or `,eb`

### Requirement: REPL-as-IDE content replaces an LSP
The arc SHALL teach editor-like intelligence (arglists, documentation, `describe`, source location) from the live image via Conjure/Swank, and SHALL NOT instruct readers to install a Common Lisp LSP.

#### Scenario: Introspection without an LSP
- **WHEN** a reader reaches lesson 02
- **THEN** it SHALL show how to obtain documentation, arglists, and source location from the running image, with no LSP install step

### Requirement: Implementation appendices exist
The series SHALL include appendices A (SBCL), B (CCL), C (ECL), D (ABCL), E (CLISP), and F (commercial: Allegro, LispWorks). Appendices A–D SHALL each reference the implementation's `docker/lisp-swank/<impl>/Dockerfile` and its executable-build method; E and F SHALL describe non-containerized use.

#### Scenario: Reader consults the ECL appendix
- **WHEN** a reader opens appendix C (ECL)
- **THEN** it SHALL cover the ECL container, the start command, ECL's compile-through-C model, and its native-binary build

### Requirement: Building-an-application lesson covers all containerized implementations
Lesson 09 SHALL build one ASDF system into an executable and show the implementation-specific result for SBCL, CCL, ECL, and ABCL.

#### Scenario: Four build artifacts
- **WHEN** a reader completes lesson 09
- **THEN** they SHALL have seen the SBCL core, CCL application, ECL native binary, and ABCL uberjar build paths

### Requirement: Nav sidebar lists all lessons, the index, and appendices
`docs/modules/ROOT/nav.adoc` SHALL list the series index, lessons 01–11, and appendices A–F under a Lisp Learning section.

#### Scenario: All pages appear in the sidebar
- **WHEN** a reader opens the docs site
- **THEN** the index, eleven lessons, and six appendices SHALL appear in the Lisp Learning section of the nav sidebar

### Requirement: No Markdown copies
`docs/learning/lisp/` SHALL NOT contain Markdown copies of lessons. AsciiDoc under `docs/modules/ROOT/pages/learning/lisp/` is the sole canonical source.

#### Scenario: No stale Markdown
- **WHEN** the repository is inspected
- **THEN** no `.md` lesson files SHALL exist for the Lisp series
