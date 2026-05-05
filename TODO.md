# TODO / Cleanup Backlog

Running list of known loose ends, deferred work, and housekeeping tasks.
Add new items here as they are discovered; remove or move them to the relevant
openspec change when work begins.

---

## Git Housekeeping

### Step 0 — Sync and prune

- [ ] Fetch all remotes and prune dead tracking refs before doing anything else:
  ```sh
  git fetch --all --prune
  ```

---

### Step 1 — Delete merged remote branches from origin

The following branches are fully merged into `main` on origin and are safe to
delete. Deleting them on origin also removes them from everyone's `git fetch`.

- [ ] **`origin/copilot/refactor-gh-copilot-support`** — merged (PR #78 on main)
  ```sh
  git push origin --delete copilot/refactor-gh-copilot-support
  git branch -d copilot/refactor-gh-copilot-support 2>/dev/null || true
  ```

- [ ] **`origin/copilot/confluence-publish`** — merged to main
  ```sh
  git push origin --delete copilot/confluence-publish
  ```

- [ ] **`origin/copilot/script-confluence-changes`** — merged to main
  ```sh
  git push origin --delete copilot/script-confluence-changes
  ```

- [ ] **`origin/feature/dotnet-csharp`** — merged to main; remove local branch too
  ```sh
  git push origin --delete feature/dotnet-csharp
  git branch -d feature/dotnet-csharp
  ```

- [ ] **`origin/copilot-openspec-serena`** — merged to main (openspec scaffolding
  commit); open OpenSpec changes are in `openspec/changes/` on main and are
  tracked via the Incomplete OpenSpec Changes section below
  ```sh
  git push origin --delete copilot-openspec-serena
  git branch -d copilot-openspec-serena
  ```

- [ ] **`origin/add-jira-workflow`** — merged to main; the Jira implementation
  tasks are incomplete (see OpenSpec section below). Delete the tracking branch
  now and do the remaining implementation work on a fresh branch.
  ```sh
  git push origin --delete add-jira-workflow
  git branch -d add-jira-workflow
  ```

---

### Step 2 — Decide fate of unmerged remote branches

Each entry below is **not** merged into `main` and needs a PR, rebase, or a
decision to abandon/supersede.

- [ ] **`origin/cli-console-mode`** ← current work branch
  - Open a PR against `main` once final review is done.
  - Local branch is ahead of remote by 1 commit — push before opening PR:
    ```sh
    git push origin cli-console-mode
    # then open PR on GitHub
    gh pr create --base main --head cli-console-mode --title "feat: cli-console-mode features and docs"
    ```

- [ ] **`origin/confluence-scripts`** — Overhauled Confluence publisher scripts and config
  - Review commit history, then either open a PR or rebase onto `main`:
    ```sh
    git log --oneline main..confluence-scripts
    gh pr create --base main --head confluence-scripts --title "feat: overhaul Confluence publisher scripts"
    ```

- [ ] **`origin/copilot/add-support-janet-language`** — Janet language support
  - Review then open PR or abandon:
    ```sh
    git log --oneline main..copilot/add-support-janet-language
    gh pr create --base main --head copilot/add-support-janet-language
    ```

- [ ] **`origin/copilot/fix-kulala-nvim-leader-e-selection`** — Kulala LSP migration
  (Neovim 0.11 API); check if superseded by any changes in `main` first:
    ```sh
    git log --oneline main..copilot/fix-kulala-nvim-leader-e-selection
    git diff main...copilot/fix-kulala-nvim-leader-e-selection -- lua/
    gh pr create --base main --head copilot/fix-kulala-nvim-leader-e-selection
    ```

- [ ] **`origin/install-rest.nvim`** — REST client documented install plan
  - Review then open PR; consider whether it should merge before or after
    `cli-console-mode`:
    ```sh
    git log --oneline main..install-rest.nvim
    gh pr create --base main --head install-rest.nvim
    ```

- [ ] **`origin/copilot/add-cli-markdown-preview-support`** — single commit adding
  glow preview with `,gp` keymap. **Likely superseded** by the glow work in
  `cli-console-mode`. Compare before raising a PR:
    ```sh
    git diff main...copilot/add-cli-markdown-preview-support
    # If superseded:
    git push origin --delete copilot/add-cli-markdown-preview-support
    ```

- [ ] **`origin/copilot/modify-plantuml-workflow-svg`** — SVG PlantUML workflow
  (3 commits). **Likely superseded** by the ASCII-preview approach in
  `cli-console-mode`. Compare, decide, and delete if obsolete:
    ```sh
    git log --oneline main..copilot/modify-plantuml-workflow-svg
    git diff main...copilot/modify-plantuml-workflow-svg -- lua/plugins/plantuml.lua
    # If superseded:
    git push origin --delete copilot/modify-plantuml-workflow-svg
    ```

---

### Step 3 — Local-only cleanup

- [ ] **Delete `wofers` local branch** — superseded; one commit carried into `cli-console-mode`
  ```sh
  git branch -d wofers
  ```

- [ ] **Remove `woofers` worktree** — scratch worktree at `/home/walt/.config/nvim-exp`
  ```sh
  git worktree list          # confirm nothing in use
  git worktree remove /home/walt/.config/nvim-exp
  git branch -d woofers
  ```

---

## End-to-End Testing

- [ ] **Run the full validation guide** — work through every section of
  `docs/guides/validation.md` on the current machine and mark all items `[x]`.

- [ ] **Test on a fresh machine / clean install** — clone the repo to a new
  machine (or a fresh WSL instance), follow `readme.md` from scratch, and verify
  all Docker services start and all features work without prior state.

- [ ] **Console-mode E2E** — run the validation guide sections 3–9 explicitly
  under `env -u DISPLAY -u WAYLAND_DISPLAY nvim` to confirm all console-mode
  paths work end-to-end.

---

## Deferred Features / Known Limitations

- [ ] **PlantUML Unicode art (`/utxt/`)** — the current `plantuml/plantuml-server:jetty`
  image returns 404 for the `/utxt/` endpoint. Upgrade the image and switch
  `lua/plugins/plantuml.lua` back to `/utxt/` once confirmed.
  See `docs/guides/cli-console-mode.md` "Known limitation" callout.

- [ ] **avante.nvim version pin** — pinned to `v0.0.27` (latest release with
  prebuilt Linux binaries). Monitor [releases](https://github.com/yetone/avante.nvim/releases)
  and unpin `version = "v0.0.27"` in `lua/plugins/avante.lua` when a newer
  release publishes Linux `.so` files.

- [ ] **`lazy-lock.json` is gitignored** — currently excluded from version control.
  Consider whether to track it (guarantees reproducible installs across machines)
  or keep it ignored (allows each machine to use latest compatible versions).

---

## Incomplete OpenSpec Changes

These changes were created on the `copilot-openspec-serena` branch (now merged
to main) and live in `openspec/changes/`. Implementation work should be done
on a new feature branch for each change.

### `add-jira-workflow`

Full spec: `openspec/changes/add-jira-workflow/`

**Start work:**
```sh
git checkout main && git pull
git checkout -b add-jira-workflow
```

**1. Core Module** (`lua/config/jira.lua`)

- [ ] 1.1 Create `lua/config/jira.lua` with `M.setup()` registering `:JiraCreateIssue`
  and `:JiraCreateStory` user commands
- [ ] 1.2 Implement `find_git_root()` helper (reuse pattern from `confluence.lua`)
- [ ] 1.3 Implement `find_project_key()` — read `docs/jira-project-map.md` and
  resolve the Jira project key for the current file via longest-prefix matching
- [ ] 1.4 Implement `M.create_issue(issue_type)` — validate credentials, resolve
  project key, prompt for summary, use visual selection or prompt for description,
  POST to Jira Cloud REST API v3 `/rest/api/3/issue`
- [ ] 1.5 Implement async `vim.system()` curl call:
  ```lua
  vim.system({ "curl", "-s", "-u", email..":"..token,
    "-H", "Content-Type: application/json",
    "-d", json_body,
    jira_base_url.."/rest/api/3/issue" }, { text = true }, callback)
  ```
- [ ] 1.6 Parse JSON response — success notification with issue key + URL, or
  error notification on failure

**2. Keymaps** (`after/ftplugin/markdown.lua`)

- [ ] 2.1 Add `require("config.jira").setup()` call
- [ ] 2.2 Add normal-mode `,ji` → `:JiraCreateIssue`
- [ ] 2.3 Add normal-mode `,js` → `:JiraCreateStory`
- [ ] 2.4 Add visual-mode variants so selected text becomes the description

**3. Project Map** (`docs/jira-project-map.md`)

- [ ] 3.1 Create `docs/jira-project-map.md` with sample table (directory prefix →
  project key)

**4. Documentation**

- [ ] 4.1 Create `docs/guides/jira.md` — prerequisites (`JIRA_EMAIL`,
  `JIRA_API_TOKEN`, `curl`), project map format, keymap reference
- [ ] 4.2 Update `readme.md` — add `,ji` / `,js` to keybindings table
- [ ] 4.3 Update `docs/cheatsheets/index.md` if a Jira cheatsheet row is warranted

**5. Validate**

- [ ] 5.1 Syntax-check changed Lua files:
  ```sh
  luac -p lua/config/jira.lua after/ftplugin/markdown.lua
  ```
- [ ] 5.2 Open a markdown file in Neovim; run `:JiraCreateIssue` — confirm prompts
- [ ] 5.3 Confirm a Task issue is created and the success notification shows key + URL
- [ ] 5.4 Repeat with `:JiraCreateStory` and confirm issue type is `"Story"`
- [ ] 5.5 Confirm missing `JIRA_EMAIL` or `JIRA_API_TOKEN` aborts with correct error

**Commit and push:**
```sh
git add lua/config/jira.lua after/ftplugin/markdown.lua \
        docs/jira-project-map.md docs/guides/jira.md \
        readme.md docs/cheatsheets/index.md
git commit -m "feat: implement Jira issue creation integration"
git push origin add-jira-workflow
gh pr create --base main --head add-jira-workflow
```

---

### `add-lua-support`

Full spec: `openspec/changes/add-lua-support/`

**Start work:**
```sh
git checkout main && git pull
git checkout -b add-lua-support
```

**1. LSP Setup** (`lua/config/lsp.lua`)

- [ ] 1.1 Add after the last `lspconfig` block:
  ```lua
  lspconfig.lua_ls.setup{ on_attach = on_attach }
  ```
- [ ] 1.2 Verify `lua-language-server` is available (or document install):
  ```sh
  which lua-language-server || sudo apt install lua-language-server
  ```

**2. Formatting** (`lua/plugins/conform.lua`)

- [ ] 2.1 Add `"lua"` to the `ft` list in the conform plugin spec
- [ ] 2.2 Add `lua = { "stylua" }` to `formatters_by_ft`
- [ ] 2.3 Verify stylua is installed:
  ```sh
  which stylua || cargo install stylua
  ```

**3. Filetype Plugin** (`after/ftplugin/lua.lua`)

- [ ] 3.1 Create `after/ftplugin/lua.lua`:
  ```lua
  vim.opt_local.shiftwidth  = 2
  vim.opt_local.tabstop     = 2
  vim.opt_local.softtabstop = 2
  vim.opt_local.expandtab   = true
  ```

**4. Documentation**

- [ ] 4.1 Create `docs/guides/lua.md` — prerequisites, LSP keymaps, format-on-save,
  indent settings
- [ ] 4.2 Update `readme.md` Language Support table — mark Lua with LSP + formatting
- [ ] 4.3 Update `docs/cheatsheets/index.md` if a Lua cheatsheet row is added

**5. Validate**

- [ ] 5.1 Syntax-check all changed files:
  ```sh
  luac -p lua/config/lsp.lua lua/plugins/conform.lua after/ftplugin/lua.lua
  ```
- [ ] 5.2 Open a `.lua` file in Neovim; confirm `lua_ls` attaches:
  ```
  :LspInfo
  ```
- [ ] 5.3 Save a Lua file; confirm stylua runs (file content changes)
- [ ] 5.4 Confirm indent width in a Lua buffer:
  ```
  :set shiftwidth?   " expect shiftwidth=2
  ```

**Commit and push:**
```sh
git add lua/config/lsp.lua lua/plugins/conform.lua \
        after/ftplugin/lua.lua \
        docs/guides/lua.md readme.md docs/cheatsheets/index.md
git commit -m "feat: add Lua LSP (lua_ls) and stylua formatting"
git push origin add-lua-support
gh pr create --base main --head add-lua-support
```

---

### `document-confluence-workflow`

Full spec: `openspec/changes/document-confluence-workflow/`

**Start work:**
```sh
git checkout main && git pull
git checkout -b document-confluence-workflow
```

**1. Verify Spec Files**

- [ ] 1.1 `specs/confluence-publish/spec.md` — covers publish pipeline, script
  resolution, non-blocking behaviour
- [ ] 1.2 `specs/confluence-pull/spec.md` — covers pull, backup creation,
  credential check
- [ ] 1.3 `specs/confluence-comments/spec.md` — covers fetch, sidecar overwrite,
  credential check
- [ ] 1.4 `specs/confluence-conflict-detection/spec.md` — covers state persistence,
  stale-version dialog, no-conflict fast path
- [ ] 1.5 `specs/confluence-page-map/spec.md` — covers map format, path
  normalisation, git-root resolution, not-found error
- [ ] 1.6 `specs/confluence-filter-pipeline/spec.md` — covers filter resolution,
  link substitution, code macros, PlantUML rendering

**2. Cross-check Implementation**

For each item, open the relevant file and compare against the spec:
```sh
nvim lua/config/confluence.lua openspec/changes/document-confluence-workflow/specs/confluence-publish/spec.md
```

- [ ] 2.1 `M.publish()` matches `confluence-publish` spec
- [ ] 2.2 `M.pull()` matches `confluence-pull` spec
- [ ] 2.3 `M.fetch_comments()` matches `confluence-comments` spec
- [ ] 2.4 `state_read()` / `state_write()` match `confluence-conflict-detection` spec
- [ ] 2.5 `find_page_entry()` matches `confluence-page-map` spec including path
  normalisation
- [ ] 2.6 `scripts/confluence_filter.lua` matches `confluence-filter-pipeline` spec

**3. Documentation Consistency**

- [ ] 3.1 Compare `docs/guides/confluence.md` against all six specs for contradictions:
  ```sh
  nvim docs/guides/confluence.md
  ```
- [ ] 3.2 Update `docs/guides/confluence.md` wherever discrepancies are found

**Commit and push:**
```sh
git add openspec/changes/document-confluence-workflow/ docs/guides/confluence.md
git commit -m "docs: align Confluence workflow specs with implementation"
git push origin document-confluence-workflow
gh pr create --base main --head document-confluence-workflow
```

---

## Documentation Gaps

- [ ] **`docs/guides/validation.md`** — complete a full run-through and mark all
  sections; note any steps that need correction.

- [ ] **REST client guide** — `docs/guides/rest.md` may need updating now that
  the plugin is Kulala (not rest.nvim). Verify accuracy.

- [ ] **`docs/jira-project-map.md`** — currently a stub; needs real project key
  entries once the Jira integration is complete.

- [ ] **Architecture doc** — `docs/guides/architecture.md` was written from
  static analysis; review after a live session to catch anything missed.

---

## Code Quality

- [ ] **Keymaps audit** — some entries in `lua/keymaps.lua` have malformed
  string literals with stray spaces (e.g. `"< S-Down> "`). Review and fix.

- [ ] **`.gitignore`** — currently only ignores `lazy-lock.json`. Consider
  whether `testdocs/` and `.serena/cache/` (already in `.serena/.gitignore`)
  should also be excluded at repo level.
