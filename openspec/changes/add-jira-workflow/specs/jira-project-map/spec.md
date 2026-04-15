## ADDED Requirements

### Requirement: Project map resolves Jira project key from current file path
The system SHALL read `docs/jira-project-map.md` at the git root to determine the Jira project key for the current file. Each row in the table SHALL map a local path prefix (directory or file, relative to the git root) to a Jira project key (e.g., `DRIVER`, `ROAD`).

#### Scenario: File path matches project map entry
- **WHEN** the current file's path starts with a prefix listed in `docs/jira-project-map.md`
- **THEN** the corresponding project key is returned and used for issue creation

#### Scenario: Most-specific prefix wins
- **WHEN** multiple entries in the project map could match the current file path
- **THEN** the longest matching prefix is used

#### Scenario: File not matched by any prefix
- **WHEN** no entry in `docs/jira-project-map.md` matches the current file's path
- **THEN** an error notification is shown and no API call is made

### Requirement: Project map is located relative to the git root
The system SHALL find `docs/jira-project-map.md` relative to the git root of the current file, not the Neovim working directory.

#### Scenario: Map found via git root
- **WHEN** the current file is inside a git repository whose root contains `docs/jira-project-map.md`
- **THEN** that file is used as the project map

#### Scenario: No git root or no project map
- **WHEN** the file is outside a git repo, or `docs/jira-project-map.md` does not exist
- **THEN** an error notification is shown and the command aborts
