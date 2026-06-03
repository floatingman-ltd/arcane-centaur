## REMOVED Requirements

### Requirement: Avante copilot provider configured
**Reason**: The `github/copilot.vim` plugin has been removed, so Avante's `copilot` provider no longer exists. Replaced by the `claude` provider in the new `ai-research-claude` capability.

### Requirement: Keymap to open avante with copilot provider
**Reason**: `<leader>ac` now switches Avante to the `claude` provider; re-specified under `ai-research-claude`.

### Requirement: Keymap to open avante with current provider
**Reason**: `<leader>aa` is re-specified under `ai-research-claude`.
