## ADDED Requirements

### Requirement: Create a Jira issue (Task) from Neovim
The system SHALL provide a `:JiraCreateIssue` command and a `,ji` keymap that prompts the user for a summary and optional description, then creates a Jira `Task` issue in the project mapped to the current file via `docs/jira-project-map.md`, using the Jira Cloud REST API v3.

#### Scenario: Successful issue creation
- **WHEN** the user runs `,ji` or `:JiraCreateIssue`, enters a summary and description, and valid credentials and a project map entry exist
- **THEN** a Jira Task issue is created and a success notification shows the new issue key and URL

#### Scenario: Visual selection used as description
- **WHEN** the user selects text in visual mode before running `,ji`
- **THEN** the selected text is pre-populated as the issue description and only a summary prompt is shown

#### Scenario: Current file not in project map
- **WHEN** no entry for the current file's path exists in `docs/jira-project-map.md`
- **THEN** an error notification is shown and no API call is made

#### Scenario: Creation is non-blocking
- **WHEN** `,ji` is triggered and the API call is in flight
- **THEN** the Neovim UI remains interactive
