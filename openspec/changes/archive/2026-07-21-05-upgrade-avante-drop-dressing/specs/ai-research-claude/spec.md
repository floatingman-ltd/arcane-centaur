## REMOVED Requirements

### Requirement: Avante claude provider configured
**Reason**: avante is now Ollama-only. Anthropic's Terms of Service scope subscription OAuth
tokens to Claude Code / claude.ai, so driving them from a third-party tool like avante risks a
violation, and this config also avoids an `ANTHROPIC_API_KEY` (external account/billing)
dependency. avante's in-panel `claude` provider is therefore removed.
**Migration**: Re-add a `claude` provider to `lua/plugins/avante.lua` (`auth_type = "api"` +
`api_key_name = "ANTHROPIC_API_KEY"`) and a `<leader>ac` mapping — documented in `avante.lua` and
`ai-tools.adoc`. For Anthropic-backed help without avante, use the CLI features
(`:ClaudeSuggest`/`:ClaudeExplain`, research popup) under the `claude-cli-integration` capability,
which use Claude Code's own CLI auth and are unaffected by this change.

### Requirement: Keymap to open avante with claude provider
**Reason**: `<leader>ac` is removed along with the claude provider (avante is Ollama-only).
**Migration**: Re-add the provider and the mapping (see above) if you want the API-key path.
