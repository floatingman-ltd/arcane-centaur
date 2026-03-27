# Confluence Publishing Guide

Publish a local markdown file directly to its Confluence page with `,cc` (or `:MdToConfluence`).

The publisher converts the markdown to Confluence storage format via pandoc (with an optional Lua filter for link substitution, code macros, and PlantUML rendering) and updates the Confluence page via the REST API. The Neovim integration is implemented in pure Lua — no Python required.

---

## Prerequisites

> **Required:** `pandoc`, `curl`, and `jq` must be installed before `,cc` will work.

| Dependency | Purpose | Install hint |
|---|---|---|
| **pandoc** *(required)* | Markdown → Confluence storage format | `sudo apt install pandoc` · `brew install pandoc` |
| **curl** *(required)* | REST API calls | Pre-installed on most systems |
| **jq** *(required when using shell script)* | JSON parsing | `sudo apt install jq` |
| **PlantUML server** *(optional)* | Renders diagrams to PNG | See [diagrams.md](diagrams.md) |
| **CONFLUENCE_EMAIL** env var | Atlassian account email | See [Authentication](#authentication) |
| **CONFLUENCE_API_TOKEN** env var | Atlassian API token | See [Authentication](#authentication) |

---

## Authentication

The publisher reads credentials from environment variables. They are never stored in any file.

### Generating an API token

1. Go to <https://id.atlassian.com/manage-profile/security/api-tokens>
2. Click **Create API token**
3. Give it a label (e.g. `nvim-confluence-publish`) and copy the token

### Setting the environment variables

Add these lines to your shell profile (`~/.bashrc`, `~/.zshrc`, or `~/.profile`):

```sh
export CONFLUENCE_EMAIL="your.email@example.com"
export CONFLUENCE_API_TOKEN="your-api-token-here"
```

Reload your shell or open a new terminal. Neovim must be launched from a shell that has these variables set.

> **Never commit these values to any file.** Environment variables in your shell profile are not version controlled and are not visible to other processes.

---

## Page map

The publisher resolves which Confluence page to update by reading `docs/confluence-page-map.md` at the root of the git repository containing the open file.

Each entry maps a local file path (relative to `docs/`) to its Confluence page URL:

```markdown
| `lld/0015/0015a_licence-data-persistence-and-synchronisation.md` | DRIVER-LLD-0015: Licence Data Persistence | https://novascotia-rmvmt.atlassian.net/wiki/spaces/ROAD/pages/172065288/... | |
```

If the current file is not in the page map, the command reports an error and does nothing.

---

## Usage

Open any markdown file that is listed in the page map, then:

| Method | Action |
|---|---|
| `,cc` | Publish current file to Confluence |
| `:MdToConfluence` | Same, via command |

Progress messages appear in the notification area. The final message includes the published page URL.

---

## Link substitution and code macros

When `confluence_filter.lua` is found (either alongside the publish script or via `CONFLUENCE_FILTER_LUA`), `,cc` automatically:

- Replaces relative markdown links with their Confluence URLs from the page map
- Converts fenced code blocks to Confluence `ac:structured-macro` code blocks
- Renders `plantuml` fenced blocks to inline PNG images via the local PlantUML server

If the filter is not found, basic conversion runs without these enhancements.

Set `CONFLUENCE_FILTER_LUA` to the absolute path of `confluence_filter.lua` if the filter lives in a different repository to the page being published:

```sh
export CONFLUENCE_FILTER_LUA="/home/walt/src/rmv/drive-api/scripts/confluence_filter.lua"
```

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `CONFLUENCE_EMAIL and CONFLUENCE_API_TOKEN must be set` | Env vars missing | Add to shell profile; relaunch Neovim |
| `not found in confluence-page-map.md` | File not in page map | Add an entry to `docs/confluence-page-map.md` |
| `cannot open page map` | `docs/confluence-page-map.md` missing | Create the file in the project repository root |
| `pandoc failed` | pandoc not installed | `sudo apt install pandoc` |
| `jq: command not found` | jq not installed (shell script mode) | `sudo apt install jq` |
| Links not substituted | Filter not found | Set `CONFLUENCE_FILTER_LUA` to the filter path |
| `GET .../content/... → 401` | Invalid credentials | Regenerate API token at id.atlassian.com |
| `GET .../content/... → 403` | Token lacks page edit permission | Check Confluence space permissions |
| `cannot parse Confluence URL` | Malformed URL in page map | Ensure the URL contains `/pages/<numeric-id>/` |
| Diagrams appear as code blocks | PlantUML server not running | Start the PlantUML Docker container |
