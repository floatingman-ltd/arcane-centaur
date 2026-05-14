# Jira Integration Guide

Create Jira issues and stories without leaving Neovim. The Jira integration follows
the same pattern as the [Confluence integration](confluence.md): pure Lua, async
`curl` calls, and localleader keymaps in Markdown buffers.

## Prerequisites

| Requirement | Notes |
|---|---|
| `JIRA_EMAIL` | Your Atlassian account email |
| `JIRA_API_TOKEN` | An Atlassian API token — generate one at [id.atlassian.com/manage-profile/security/api-tokens](https://id.atlassian.com/manage-profile/security/api-tokens) |
| `JIRA_BASE_URL` | Your Jira Cloud instance URL, e.g. `https://yourcompany.atlassian.net` |
| `curl` | Already required by the Confluence integration |

### Setting environment variables

Add to your shell profile (`~/.bashrc`, `~/.zshrc`, etc.):

```bash
export JIRA_EMAIL="you@example.com"
export JIRA_API_TOKEN="your-api-token-here"
export JIRA_BASE_URL="https://yourcompany.atlassian.net"
```

Then reload your shell or open a new terminal before launching Neovim.

## Project Map

`docs/jira-project-map.md` (at the git root of your project) maps local path prefixes
to Jira project keys.  The integration reads this file each time a command runs.

### Format

```markdown
| Path Prefix       | Project Key | Notes                       |
|---|---|---|
| `docs/`           | PROJ        | Default project for docs    |
| `docs/backend/`   | BACK        | Backend team project        |
| `specs/`          | ARCH        | Architecture RFC tickets    |
```

- Paths are **relative to the git root** (no leading `/`).
- **Longest prefix wins** when multiple rows match.
- Both directory prefixes (`docs/`) and exact file paths (`docs/design/foo.md`) work.
- The `docs/jira-project-map.md` file must exist; copy from this repo's template and
  update the rows for your projects.

## Keymaps

Keymaps are active in **Markdown buffers** only (`LocalLeader` = `,`).

| Keys | Mode | Action |
|---|---|---|
| `,ji` | Normal | Prompt for summary + description → create Jira Task |
| `,js` | Normal | Prompt for summary + description → create Jira Story |
| `,ji` | Visual | Use selection as description → prompt for summary → create Task |
| `,js` | Visual | Use selection as description → prompt for summary → create Story |

## Workflow

### Normal mode (no pre-filled description)

1. Open any markdown file whose path matches a row in `docs/jira-project-map.md`.
2. Press `,ji` (Task) or `,js` (Story).
3. Enter the issue **summary** at the prompt and press `<Enter>`.
4. Enter an optional **description** and press `<Enter>` (leave blank to skip).
5. A success notification shows the new issue key (e.g. `PROJ-42`) and its URL.

### Visual mode (use selection as description)

1. Select the relevant text in visual mode.
2. Press `,ji` or `,js`.
3. Enter the issue **summary** at the prompt (description is pre-filled from selection).
4. Success notification appears as above.

## Commands

Both commands are also available directly:

| Command | Issue Type |
|---|---|
| `:JiraCreateIssue` | Task |
| `:JiraCreateStory` | Story |
| `:JiraCreateIssueFromSelection` | Task (uses last visual selection as description) |
| `:JiraCreateStoryFromSelection` | Story (uses last visual selection as description) |

## Troubleshooting

| Symptom | Solution |
|---|---|
| `JIRA_EMAIL and JIRA_API_TOKEN must be set` | Export both env vars and restart Neovim |
| `JIRA_BASE_URL must be set` | Export `JIRA_BASE_URL` (e.g. `https://co.atlassian.net`) |
| `file not in project map` | Add a matching row to `docs/jira-project-map.md` |
| `cannot open project map` | Ensure `docs/jira-project-map.md` exists at the git root |
| `API returned HTTP 401` | Check that `JIRA_API_TOKEN` is correct and not expired |
| `API returned HTTP 400` | The project key may be wrong, or the issue type doesn't exist in your project |
| Creation succeeds but wrong project | Check for overlapping prefixes; the longest prefix wins |
