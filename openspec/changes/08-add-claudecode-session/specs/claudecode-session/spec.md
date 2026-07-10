## ADDED Requirements

### Requirement: Editor-aware Claude Code session via MCP
A persistent, editor-aware Claude session SHALL be provided by `coder/claudecode.nvim` over the WebSocket MCP protocol, exposing session toggle/focus, context add, selection send, and diff accept/reject, with maps under the `<leader>gc` "Claude" group.

#### Scenario: Start and connect a session
- **WHEN** the user presses `<leader>gcc`
- **THEN** a Claude Code session SHALL start in a terminal and the `claude` CLI SHALL connect to the plugin's MCP server

#### Scenario: Send a selection as context
- **WHEN** the user visually selects lines and presses `<leader>gcv`
- **THEN** the selection SHALL be sent to the running Claude session as context

#### Scenario: Accept or reject a proposed diff
- **WHEN** Claude proposes a diff and the user presses `<leader>gca` or `<leader>gcr`
- **THEN** the diff SHALL be accepted (applied) or rejected (discarded) respectively

### Requirement: Snacks-free, no avante-namespace collision
claudecode.nvim SHALL be configured to use Neovim's native terminal provider and SHALL NOT introduce a snacks.nvim dependency, and its keymaps SHALL NOT use the `<leader>a` (avante) prefix.

#### Scenario: No snacks dependency
- **WHEN** plugins are synced after this change
- **THEN** `:Lazy` SHALL NOT list snacks.nvim as a newly installed dependency

#### Scenario: Avante maps preserved
- **WHEN** the user presses `<leader>aa`, `<leader>ao`, or `<leader>ac`
- **THEN** avante SHALL respond exactly as before (claudecode does not occupy `<leader>a`)

### Requirement: One-shot claude_cli commands preserved
The existing `claude_cli` one-shot integration SHALL continue to work alongside the session integration.

#### Scenario: Suggest/Explain still work
- **WHEN** the user presses `<leader>gcs` or `<leader>gce`
- **THEN** `:ClaudeSuggest` / `:ClaudeExplain` SHALL run `claude -p` and show the result in a floating window, exactly as before this change
