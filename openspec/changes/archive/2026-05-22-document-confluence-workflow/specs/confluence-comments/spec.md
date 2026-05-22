## ADDED Requirements

### Requirement: Fetch all page comments to a sidecar file
The system SHALL fetch all comments for the mapped Confluence page and write them to `<filename>.comments.md` in the same directory as the source file. If the sidecar file already exists it SHALL be overwritten.

#### Scenario: Successful comment fetch
- **WHEN** the user runs `,ck` or `:MdConfluenceComments` on a file listed in the page map
- **THEN** all page comments are fetched and written to `<filename>.comments.md`

#### Scenario: Existing sidecar overwritten
- **WHEN** `<filename>.comments.md` already exists and the user runs `,ck`
- **THEN** the existing file is overwritten with fresh comments

#### Scenario: No comments on page
- **WHEN** the Confluence page has no comments and the user runs `,ck`
- **THEN** an empty or header-only `<filename>.comments.md` is created and a notification confirms completion

### Requirement: Comment fetch requires valid credentials
The system SHALL abort with an error if `CONFLUENCE_EMAIL` or `CONFLUENCE_API_TOKEN` are not set.

#### Scenario: Missing credentials on comment fetch
- **WHEN** either env var is unset and the user runs `,ck`
- **THEN** an error notification is shown and no network request is made
