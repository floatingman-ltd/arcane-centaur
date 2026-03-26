# Confluence Publishing Guide

Publish a local markdown file directly to its Confluence page with `,cc` (or `:MdToConfluence`).

The publisher converts the markdown to Confluence storage format via pandoc, renders PlantUML diagrams to inline PNG images via the local PlantUML server, and updates the Confluence page via the REST API.

---

## Prerequisites

> **Required:** `pandoc` must be installed before `,cc` will work. Install with `sudo apt install pandoc` (Debian/Ubuntu) or `brew install pandoc` (macOS). The command will fail with a Python traceback if pandoc is missing.

| Dependency | Purpose | Install hint |
|---|---|---|
| **pandoc** *(required)* | Markdown → Confluence storage format | `sudo apt install pandoc` |
| **python3** *(required)* | Runs the publish script | Pre-installed on most systems |
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

## Diagram rendering

PlantUML fenced blocks are rendered to PNG via the local PlantUML server (`http://localhost:8080` by default) and embedded as inline base64 images in the Confluence page.

If the PlantUML server is not running, the block falls back to a Confluence code macro — the diagram source is preserved but not rendered.

To override the server URL:

```sh
export PLANTUML_SERVER="http://localhost:8080"
```

---

## Publish script location

The Lua module looks for the publish script in two places, in order:

1. The path in the `CONFLUENCE_PUBLISH_SCRIPT` environment variable (use this for repos that do not contain the script themselves, such as this nvim config repo)
2. `scripts/confluence_publish.py` at the git root of the open file

Add this to your shell profile if you work across multiple repos:

```sh
export CONFLUENCE_PUBLISH_SCRIPT="/home/walt/src/rmv/drive-api/scripts/confluence_publish.py"
```

---

## Publish script (command-line use)

```sh
CONFLUENCE_EMAIL="..." CONFLUENCE_API_TOKEN="..." \
  python3 scripts/confluence_publish.py docs/lld/0015/0015a_licence-data-persistence-and-synchronisation.md
```

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `CONFLUENCE_EMAIL and CONFLUENCE_API_TOKEN must be set` | Env vars missing | Add to shell profile; relaunch Neovim |
| `publish script not found` | Script not in repo and `CONFLUENCE_PUBLISH_SCRIPT` not set | Set `CONFLUENCE_PUBLISH_SCRIPT` to the full path of `confluence_publish.py` |
| `not found in confluence-page-map.md` | File not in page map | Add an entry to `docs/confluence-page-map.md` |
| `GET .../content/... → 401` | Invalid credentials | Regenerate API token at id.atlassian.com |
| `GET .../content/... → 403` | Token lacks page edit permission | Check Confluence space permissions |
| `pandoc failed` or `FileNotFoundError: pandoc` | pandoc not installed | `sudo apt install pandoc` |
| Diagrams appear as code blocks | PlantUML server not running | Start the PlantUML Docker container |
