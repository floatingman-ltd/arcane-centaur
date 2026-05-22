## ADDED Requirements

### Requirement: Publish converts local markdown to Confluence storage format
The system SHALL convert the current buffer's local markdown file to Confluence storage format using `pandoc` and upload it to the mapped Confluence page via the REST API PUT endpoint, updating the page version atomically.

#### Scenario: Successful publish
- **WHEN** the user runs `,cc` or `:MdToConfluence` on a markdown file listed in the page map
- **THEN** the file is converted with pandoc, the Confluence page is updated, and a success notification including the page URL is shown

#### Scenario: File not in page map
- **WHEN** the user runs `,cc` on a file not listed in `docs/confluence-page-map.md`
- **THEN** an error notification is shown and no API call is made

### Requirement: Publish requires CONFLUENCE_EMAIL and CONFLUENCE_API_TOKEN
The system SHALL abort publish with an error message if either `CONFLUENCE_EMAIL` or `CONFLUENCE_API_TOKEN` environment variables are not set.

#### Scenario: Missing credentials
- **WHEN** either env var is unset and the user runs `,cc`
- **THEN** an error notification `"CONFLUENCE_EMAIL and CONFLUENCE_API_TOKEN must be set"` is shown and no network request is made

### Requirement: Publish script is resolved from standard locations
The system SHALL locate `confluence_publish.sh` using the following priority order: (1) `CONFLUENCE_PUBLISH_SCRIPT` env var, (2) `~/.config/nvim/scripts/`, (3) `<git-root>/scripts/`. If not found, publish fails with a clear error.

#### Scenario: Script found in standard location
- **WHEN** `confluence_publish.sh` exists in `~/.config/nvim/scripts/`
- **THEN** that script is used for the publish

#### Scenario: Script not found
- **WHEN** `confluence_publish.sh` is not found in any of the three locations
- **THEN** an error notification is shown and no publish occurs

### Requirement: Publish is non-blocking
The system SHALL run the publish pipeline asynchronously using `vim.system()` callbacks so the Neovim UI remains responsive during network and pandoc operations.

#### Scenario: UI stays responsive during publish
- **WHEN** the user triggers `,cc` and the API call is in flight
- **THEN** the Neovim editor remains interactive and no blocking wait occurs
