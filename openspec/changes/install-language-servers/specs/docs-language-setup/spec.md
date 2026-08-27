## MODIFIED Requirements

### Requirement: Language Setup matrix page exists

A "Language Setup" page SHALL exist at `docs/modules/ROOT/pages/languages/setup.adoc` that lists, per language/family, the external prerequisites the config needs, with an install command (or link) for each and a link to that language's detailed guide.

Every language for which the config enables a language server SHALL appear on the page, including Markdown. Install commands SHALL be ones that actually work on the documented platform; a command naming a package that does not exist in the configured repositories SHALL NOT be published.

#### Scenario: A reader can find everything needed for one language
- **WHEN** a reader wants to work with a supported language (e.g. C#)
- **THEN** the page SHALL show that language's row/section with its LSP server, REPL/runtime, formatter, debugger, and treesitter parser, each with a one-line install command or link

#### Scenario: All supported languages are covered
- **WHEN** the page is read
- **THEN** it SHALL cover Lua, .NET (C# and F#), Haskell, Markdown, and the Lisp family (Common Lisp, Clojure, Scheme, Fennel, Janet)

#### Scenario: Each row links to the detailed guide
- **WHEN** a reader needs more than the one-liner
- **THEN** each language entry SHALL link (xref) to that language's guide Prerequisites section

#### Scenario: A published install command runs
- **WHEN** a reader copies an install command from the page
- **THEN** it SHALL be a command that exists on the documented platform, not one that fails with "unable to locate package"
