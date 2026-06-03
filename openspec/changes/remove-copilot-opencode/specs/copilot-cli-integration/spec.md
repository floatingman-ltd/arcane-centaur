## REMOVED Requirements

### Requirement: Suggest command
**Reason**: The `copilot` CLI integration (`lua/config/copilot_cli.lua`) has been deleted; replaced by `:ClaudeSuggest` in the new `claude-cli-integration` capability.

### Requirement: Explain command
**Reason**: Replaced by `:ClaudeExplain` in the new `claude-cli-integration` capability.

### Requirement: Keymap bindings
**Reason**: `<leader>gcs` / `<leader>gce` now trigger the Claude CLI commands; the bindings are re-specified under `claude-cli-integration`.
