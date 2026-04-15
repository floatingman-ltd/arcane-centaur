## 1. Core Module

- [ ] 1.1 Create `lua/config/jira.lua` with `M.setup()` registering `:JiraCreateIssue` and `:JiraCreateStory` user commands
- [ ] 1.2 Implement `find_git_root()` helper (or reuse pattern from `confluence.lua`)
- [ ] 1.3 Implement `find_project_key()` to read `docs/jira-project-map.md` and resolve the Jira project key for the current file using longest-prefix matching
- [ ] 1.4 Implement `M.create_issue(issue_type)` — validates credentials, resolves project key, prompts for summary, uses visual selection or prompts for description, and POSTs to Jira Cloud REST API v3 `/rest/api/3/issue`
- [ ] 1.5 Implement async `vim.system()` curl call with Basic auth (`JIRA_EMAIL:JIRA_API_TOKEN`), JSON body, and `Content-Type: application/json` header
- [ ] 1.6 Parse the JSON response and show a success notification with the new issue key and Jira URL, or an error notification on failure

## 2. Keymaps and Commands

- [ ] 2.1 Add `require("config.jira").setup()` call in `after/ftplugin/markdown.lua`
- [ ] 2.2 Add `,ji` keymap → `:JiraCreateIssue` in `after/ftplugin/markdown.lua`
- [ ] 2.3 Add `,js` keymap → `:JiraCreateStory` in `after/ftplugin/markdown.lua`
- [ ] 2.4 Add visual-mode variants of `,ji` and `,js` so the selection is passed as the description

## 3. Project Map

- [ ] 3.1 Create `docs/jira-project-map.md` with a sample table documenting the format (directory prefix → project key)

## 4. Documentation

- [ ] 4.1 Create `docs/guides/jira.md` covering prerequisites (`JIRA_EMAIL`, `JIRA_API_TOKEN`, `curl`), project map format, and keymap reference
- [ ] 4.2 Update `readme.md` to list `,ji` and `,js` in the keybindings table and add Jira to the integrations section
- [ ] 4.3 Update `docs/cheatsheets/index.md` if a Jira cheatsheet entry is warranted

## 5. Validation

- [ ] 5.1 Syntax-check `lua/config/jira.lua` and `after/ftplugin/markdown.lua` with `luac -p`
- [ ] 5.2 Open a markdown file and confirm `:JiraCreateIssue` prompts for summary and description
- [ ] 5.3 Confirm a Task issue is created in the correct Jira project and the success notification shows the issue key
- [ ] 5.4 Repeat with `:JiraCreateStory` and confirm issue type is `"Story"`
- [ ] 5.5 Confirm that missing `JIRA_EMAIL` or `JIRA_API_TOKEN` aborts with the correct error message
