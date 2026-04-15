## ADDED Requirements

### Requirement: Create a Jira story from Neovim
The system SHALL provide a `:JiraCreateStory` command and a `,js` keymap that prompts the user for a summary and optional description, then creates a Jira `Story` issue in the project mapped to the current file, using the Jira Cloud REST API v3.

#### Scenario: Successful story creation
- **WHEN** the user runs `,js` or `:JiraCreateStory`, enters a summary, and valid credentials and a project map entry exist
- **THEN** a Jira Story issue is created and a success notification shows the new issue key and URL

#### Scenario: Visual selection used as description
- **WHEN** the user selects text in visual mode before running `,js`
- **THEN** the selected text is pre-populated as the story description and only a summary prompt is shown

#### Scenario: Story and Issue creation share the same flow
- **WHEN** both `:JiraCreateIssue` and `:JiraCreateStory` are used
- **THEN** the only difference is the `issuetype.name` field sent to the API (`"Task"` vs `"Story"`)

#### Scenario: Current file not in project map
- **WHEN** no entry for the current file's path exists in `docs/jira-project-map.md`
- **THEN** an error notification is shown and no API call is made
