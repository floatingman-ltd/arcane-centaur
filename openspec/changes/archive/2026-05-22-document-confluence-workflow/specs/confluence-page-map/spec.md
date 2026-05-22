## ADDED Requirements

### Requirement: Page map file maps local paths to Confluence page URLs
The system SHALL resolve the Confluence page for the current file by reading `docs/confluence-page-map.md` at the git root. Each row in the markdown table SHALL map a local path (relative to `docs/`, with or without a leading `docs/` prefix) to a page title and a full Confluence URL containing a numeric page ID.

#### Scenario: File found in page map
- **WHEN** the current file's path matches an entry in `docs/confluence-page-map.md`
- **THEN** the corresponding Confluence URL and title are returned for use by publish, pull, and comments

#### Scenario: Leading docs/ prefix is normalised
- **WHEN** an entry in the page map is written as `` `docs/lld/foo.md` `` and the current file path is `docs/lld/foo.md`
- **THEN** the entry is matched correctly regardless of whether the leading `docs/` prefix is present

#### Scenario: File not found in page map
- **WHEN** the current file has no matching entry in `docs/confluence-page-map.md`
- **THEN** an error is returned and no network operation is performed

### Requirement: Page map is located relative to the git root
The system SHALL search for `docs/confluence-page-map.md` relative to the git root of the file being operated on, not relative to the Neovim working directory.

#### Scenario: Page map found via git root
- **WHEN** the current file is inside a git repository whose root contains `docs/confluence-page-map.md`
- **THEN** that file is used as the page map

#### Scenario: No git root found
- **WHEN** the current file is not inside a git repository
- **THEN** an error is shown and the command aborts
