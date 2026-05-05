# TODO / Cleanup Backlog

Running list of known loose ends, deferred work, and housekeeping tasks.
Add new items here as they are discovered; remove or move them to the relevant
openspec change when work begins.

---

## Git Housekeeping

- [ ] **Delete `wofers` local branch** — superseded by `cli-console-mode`; only
  contained one commit that was carried forward.
  ```sh
  git branch -d wofers
  ```

- [ ] **Remove `woofers` worktree** — scratch worktree at `/home/walt/.config/nvim-exp`;
  confirm nothing uncommitted then remove.
  ```sh
  git worktree remove /home/walt/.config/nvim-exp
  git branch -d woofers
  ```

- [ ] **Raise PRs or merge the following branches** — all have upstream tracking
  branches but have not been merged into `main`:

  | Branch | What it contains |
  |---|---|
  | `cli-console-mode` | Console detection, glow, PlantUML ASCII, avante/ollama, docs |
  | `confluence-scripts` | Overhauled Confluence publisher scripts and config |
  | `copilot/add-support-janet-language` | Janet language support |
  | `copilot/fix-kulala-nvim-leader-e-selection` | Kulala LSP migration (Neovim 0.11 API) |
  | `install-rest.nvim` | REST client (Kulala) documented install plan |

- [ ] **Decide fate of `add-jira-workflow` and `copilot-openspec-serena`** — both
  have open OpenSpec changes with incomplete tasks. Either continue work on the
  branch or close and re-open as new changes.

- [ ] **Review `feature/dotnet-csharp`** — merged look at whether there is still
  work required or whether the branch can be deleted locally and remotely.

- [ ] **Prune stale remote-tracking refs**:
  ```sh
  git fetch --prune
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

These changes have open task lists. Resume each from its `tasks.md`.

### `add-jira-workflow`

Key outstanding tasks (see `openspec/changes/add-jira-workflow/tasks.md`):
- [ ] Implement `lua/config/jira.lua` `M.create_issue()` with Jira REST API v3
- [ ] Implement `find_project_key()` with longest-prefix matching against `docs/jira-project-map.md`
- [ ] Wire keymaps (`,ji`, `,js`) in `after/ftplugin/markdown.lua`
- [ ] Add visual-mode variants for selection-as-description
- [ ] End-to-end test against a real Jira instance

### `add-lua-support`

Key outstanding tasks (see `openspec/changes/add-lua-support/tasks.md`):
- [ ] Add `lua_ls` to `lua/config/lsp.lua`
- [ ] Add `stylua` formatter to `lua/plugins/conform.lua`
- [ ] Create `after/ftplugin/lua.lua` with indent settings (`shiftwidth=2`)
- [ ] Create `docs/guides/lua.md`

### `document-confluence-workflow`

Key outstanding tasks (see `openspec/changes/document-confluence-workflow/tasks.md`):
- [ ] Verify all six Confluence specs match current implementation
- [ ] Cross-check `lua/config/confluence.lua` against each spec
- [ ] Complete any documentation gaps found during spec review

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
