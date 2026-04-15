## Why

Engineers frequently need to create Jira issues and stories while working in Neovim — writing specs, design docs, or markdown notes. Switching to a browser to file tickets interrupts flow. Adding a Jira workflow following the same pattern as the Confluence integration (pure-Lua, REST API, `curl`, localleader keymaps in the markdown ftplugin) allows issues and stories to be created without leaving the editor.

## What Changes

- Add `lua/config/jira.lua` — pure-Lua module for creating Jira issues and stories via the Jira Cloud REST API v3
- Add `docs/jira-project-map.md` — maps local directories/files to Jira project keys (analogous to `confluence-page-map.md`)
- Add `docs/guides/jira.md` — setup and usage guide
- Register localleader keymaps in `after/ftplugin/markdown.lua`:
  - `,ji` — create a Jira issue from the current buffer or visual selection
  - `,js` — create a Jira story from the current buffer or visual selection
- No changes to the Confluence workflow

## Capabilities

### New Capabilities

- `jira-create-issue`: Create a Jira Bug or Task issue from Neovim, with summary and description populated from the buffer or a prompt
- `jira-create-story`: Create a Jira Story issue type from Neovim, following the same flow as issue creation
- `jira-project-map`: Resolution of Jira project key from the current file path via `docs/jira-project-map.md`
- `jira-auth`: Authentication via `JIRA_EMAIL` and `JIRA_API_TOKEN` environment variables, mirroring the Confluence auth pattern

### Modified Capabilities

<!-- No existing specs require changes -->

## Impact

- New files: `lua/config/jira.lua`, `docs/guides/jira.md`
- Modified: `after/ftplugin/markdown.lua` (add jira keymaps), `readme.md` (document new commands)
- External prerequisites: `JIRA_EMAIL`, `JIRA_API_TOKEN` env vars; `curl` (already required for Confluence)
- No breaking changes; additive only
