# dotnet-test-runner Specification

## Purpose
TBD - created by archiving change 07-add-dotnet-debug-test. Update Purpose after archive.
## Requirements
### Requirement: Run and inspect .NET tests from the editor
C# and F# test projects SHALL be runnable from the editor via easy-dotnet's built-in test runner, exposed through `<localleader>` maps in the C#/F# ftplugins (consistent with the iron.nvim REPL-map convention). The fuzzy picker used SHALL be fzf-lua.

#### Scenario: Run the solution's tests
- **WHEN** the user invokes the .NET test map (`<localleader>tt`) in a C# or F# buffer belonging to a project with tests
- **THEN** easy-dotnet SHALL run the tests and report pass/fail results in the editor

#### Scenario: Run the current project
- **WHEN** the user invokes the .NET run map (`<localleader>tr`)
- **THEN** easy-dotnet SHALL run the current project and surface its output

#### Scenario: Picker uses fzf-lua
- **WHEN** easy-dotnet presents a selection (project, test, or launch target)
- **THEN** the selection SHALL be presented through fzf-lua, not telescope or snacks

#### Scenario: REPL workflow preserved
- **WHEN** the user uses the iron.nvim REPL maps (`<localleader>sl`, `<localleader>sc`, etc.) in a C#/F# buffer
- **THEN** they SHALL behave exactly as before this change (the test maps use a distinct `<localleader>t*` namespace)
