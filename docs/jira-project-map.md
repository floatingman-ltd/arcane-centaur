# Jira Project Map

Maps local directory/file path prefixes (relative to the git root) to Jira project keys.
Used by `:JiraCreateIssue` and `:JiraCreateStory` to determine which Jira project to file
tickets in.

**Rules:**
- Paths are relative to the git root (no leading `/`).
- The **longest matching prefix** wins when multiple entries match.
- A directory prefix (e.g. `docs/`) matches any file under it.
- An exact file path also works (e.g. `docs/design/payment.md`).

## Project Map

| Path Prefix | Project Key | Notes |
|---|---|---|
| `docs/` | PROJ | Default project for all docs |

<!--
Add rows as needed.  Example:

| Path Prefix          | Project Key | Notes                          |
|---|---|---|
| `docs/backend/`      | BACK        | Backend team Jira project      |
| `docs/frontend/`     | FRONT       | Frontend team Jira project     |
| `docs/design/`       | DESIGN      | Design / UX stories            |
| `specs/`             | ARCH        | Architecture / RFC tickets     |
| `docs/ops/deploy.md` | OPS         | Single-file override example   |
-->
