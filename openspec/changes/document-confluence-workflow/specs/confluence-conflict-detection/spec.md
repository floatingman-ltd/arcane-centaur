## ADDED Requirements

### Requirement: Last-published version is persisted in .confluence-state.json
The system SHALL record the Confluence page version number in `docs/.confluence-state.json` (relative to the git root) after every successful publish, keyed by the file's relative path. This file SHALL be committed to version control so all team members share the same conflict baseline.

#### Scenario: State written after publish
- **WHEN** a publish completes successfully
- **THEN** `docs/.confluence-state.json` is updated with the new page version for the published file

#### Scenario: State file shared across team
- **WHEN** `.confluence-state.json` is committed and another team member pulls
- **THEN** their Neovim uses the stored version for conflict detection on the same files

### Requirement: Stale version triggers a confirmation dialog before publish
The system SHALL compare the live Confluence page version against the stored version before uploading. If the live version is higher than the stored value, it SHALL present a confirmation dialog asking the user whether to overwrite the remote changes.

#### Scenario: Conflict detected — user confirms overwrite
- **WHEN** the live Confluence version exceeds the stored version and the user confirms the dialog
- **THEN** the publish proceeds and the state file is updated to the new version

#### Scenario: Conflict detected — user cancels
- **WHEN** the live Confluence version exceeds the stored version and the user cancels the dialog
- **THEN** the publish is aborted and the local file and state file are unchanged

#### Scenario: No conflict — publish proceeds silently
- **WHEN** the live Confluence version matches the stored version
- **THEN** the confirmation dialog is not shown and publish proceeds immediately
