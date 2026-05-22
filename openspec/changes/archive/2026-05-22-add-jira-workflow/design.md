## Context

The config already has a mature Confluence integration (`lua/config/confluence.lua`) using the same Atlassian REST API, the same `curl`-based approach, and the same environment-variable auth pattern (`CONFLUENCE_EMAIL` / `CONFLUENCE_API_TOKEN`). Jira and Confluence are both Atlassian products sharing the same auth model (`JIRA_EMAIL` / `JIRA_API_TOKEN`). The new `lua/config/jira.lua` module mirrors the confluence module's architecture: pure Lua, async `vim.system()` calls, localleader keymaps in the markdown ftplugin, and a project-map file for resolving the target project key.

## Goals / Non-Goals

**Goals:**
- Add `:JiraCreateIssue` and `:JiraCreateStory` commands backed by `lua/config/jira.lua`
- Add `,ji` and `,js` localleader keymaps in `after/ftplugin/markdown.lua`
- Add `docs/jira-project-map.md` for mapping files/directories to Jira project keys
- Add `docs/guides/jira.md` with prerequisites and usage instructions

**Non-Goals:**
- Viewing, searching, or transitioning existing Jira issues
- A full Jira browser TUI (a separate change)
- Jira Server (on-premise) support — Jira Cloud REST API v3 only
- Attachments or custom fields beyond summary, description, and issue type

## Decisions

### Mirror confluence module architecture
`lua/config/jira.lua` follows the same pattern as `lua/config/confluence.lua`: `M.setup()` registers commands, public functions run async `vim.system()` curl calls, credentials come from env vars. This minimises cognitive overhead and keeps the codebase consistent.

### Use Jira Cloud REST API v3 directly via curl
No Lua library for Jira exists in this ecosystem. `curl` is already required for Confluence and is available. Using it directly avoids adding new dependencies.

### Separate project-map file (docs/jira-project-map.md)
A separate map file (analogous to `confluence-page-map.md`) maps local directory paths to Jira project keys. This keeps Jira config decoupled from Confluence config and lets different directories target different Jira projects.

### Issue type distinguished by command, not a prompt
`:JiraCreateIssue` uses issue type `"Bug"` or `"Task"` and `:JiraCreateStory` uses `"Story"`. Keeping them as separate commands avoids an extra prompt and matches how users think about the difference.

### Summary from a prompt; description from buffer selection or prompt
When invoked with a visual selection, the selected text becomes the description. Otherwise, a short `vim.ui.input()` prompt collects summary; a second prompt collects description. This keeps the workflow fast for common cases.

## Risks / Trade-offs

- [Risk] `JIRA_EMAIL` / `JIRA_API_TOKEN` not set → command aborts with clear error; no crash. Mitigation: document in `docs/guides/jira.md`.
- [Risk] Jira project key not in project map → command aborts with error. Mitigation: same pattern as page-map error in Confluence.
- [Trade-off] Issue type for `:JiraCreateIssue` defaults to `"Task"` — some teams use `"Bug"`. Mitigation: can be extended in a follow-up change.

## Open Questions

- Should the issue summary default to the first line of a visual selection or always be prompted? (Current decision: always prompt for summary; use selection for description only.)
