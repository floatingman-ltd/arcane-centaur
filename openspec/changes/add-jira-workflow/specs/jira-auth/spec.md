## ADDED Requirements

### Requirement: Jira commands authenticate via JIRA_EMAIL and JIRA_API_TOKEN
The system SHALL read `JIRA_EMAIL` and `JIRA_API_TOKEN` from environment variables for all Jira REST API calls. Both variables MUST be set; if either is missing the command SHALL abort with a clear error message without making any network request.

#### Scenario: Valid credentials present
- **WHEN** both `JIRA_EMAIL` and `JIRA_API_TOKEN` are set in the environment
- **THEN** they are passed as HTTP Basic auth (`email:token` base64-encoded) in the `Authorization` header

#### Scenario: Missing credentials
- **WHEN** either `JIRA_EMAIL` or `JIRA_API_TOKEN` is unset and a Jira command is run
- **THEN** an error notification `"JIRA_EMAIL and JIRA_API_TOKEN must be set"` is shown and no network request is made

### Requirement: Credentials are never written to any file
The system SHALL use credentials only in memory (passed as curl arguments) and SHALL NOT write them to any file, log, or buffer.

#### Scenario: Credentials not persisted
- **WHEN** a Jira command executes
- **THEN** no file in the repository or on disk contains the credential values
