## ADDED Requirements

### Requirement: copilot.vim inline completion on Copilot machines
`github/copilot.vim` SHALL be installed and SHALL load on `InsertEnter` only when Copilot is selected. Its default `<Tab>` map SHALL be disabled.

#### Scenario: Ghost text appears
- **WHEN** Copilot is selected, `:Copilot setup` has been completed, and the user types in insert mode
- **THEN** Copilot suggestions SHALL appear as ghost text

#### Scenario: Not loaded on Claude machines
- **WHEN** Claude is selected
- **THEN** `:Lazy` SHALL show `copilot.vim` as not loaded, and `:Copilot` SHALL NOT exist

#### Scenario: Tab is not taken
- **WHEN** a Copilot suggestion is showing and the user presses `<Tab>`
- **THEN** `<Tab>` SHALL behave as it does without copilot.vim

### Requirement: Accept maps
In insert mode, `<C-J>` SHALL accept the whole suggestion and `<M-f>` SHALL accept the next word of it.

#### Scenario: Accept word
- **WHEN** a suggestion is showing and the user presses `<M-f>`
- **THEN** only the next word of the suggestion SHALL be inserted
