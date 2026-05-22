## ADDED Requirements

### Requirement: Pull fetches the Confluence page and writes it to the local file
The system SHALL fetch the current Confluence page body via GET, convert the storage-format HTML back to markdown using pandoc, and overwrite the local file with the result.

#### Scenario: Successful pull
- **WHEN** the user runs `,cf` or `:MdFromConfluence` on a file listed in the page map
- **THEN** the Confluence page content is fetched, converted to markdown, and the local file is overwritten

#### Scenario: File not in page map
- **WHEN** the user runs `,cf` on a file not in `docs/confluence-page-map.md`
- **THEN** an error notification is shown and the local file is not modified

### Requirement: Pull creates a .bak backup before overwriting
The system SHALL create a `.bak` copy of the current local file before overwriting it with the pulled content, ensuring the previous version is recoverable.

#### Scenario: Backup created on pull
- **WHEN** a successful pull completes
- **THEN** `<filename>.bak` is created in the same directory containing the previous file contents

### Requirement: Pull requires valid credentials
The system SHALL abort with an error if `CONFLUENCE_EMAIL` or `CONFLUENCE_API_TOKEN` are not set.

#### Scenario: Missing credentials on pull
- **WHEN** either env var is unset and the user runs `,cf`
- **THEN** an error notification is shown and no network request is made
