# Validation Test Plan

Checklist for validating each change on the test machine.
Test cases are captured separately in `openspec/MANUAL_VALIDATION.md`.
Work through this list top to bottom — each section must pass before moving to the next.

---

## One-Time Test Machine Setup

Complete once before any testing begins.

- [ ] Confirm Neovim ≥ 0.12 is installed: `nvim --version`
- [ ] Confirm Git is installed: `git --version`
- [ ] Confirm Node.js + npm are installed (required by markdown-preview.nvim build): `node --version && npm --version`
- [ ] Confirm `dotnet` SDK is installed (required for Change 07 testing): `dotnet --version`
- [ ] Install netcoredbg (required for Change 07 debugging tests): `dotnet tool install -g netcoredbg` then `netcoredbg --version`
- [ ] Confirm `claude` CLI is installed and authenticated (required for Change 08): `claude --version`
- [ ] Clone the repo: `git clone git@github.com:floatingman-ltd/arcane-centaur.git ~/.config/nvim`
- [ ] Confirm initial main state loads: `nvim` → `:Lazy sync` → no errors in `:messages`

---

## Hotfix: treesitter-markdown-highlight-disable

### Merge

- [ ] Raise PR: `fix/treesitter-markdown-highlight-disable` → `main`
- [ ] Review and approve PR
- [ ] Merge PR

### Prepare test machine

- [ ] On test machine: `git pull origin main`
- [ ] Launch Neovim: `:Lazy sync` — wait for completion
- [ ] Run `:TSUpdate` — wait for completion

### Validate

- [ ] Open a `.md` file
- [ ] Run `:messages` — confirm no `nil range` / `languagetree` error appears
- [ ] Close Neovim

### Sign off

- [ ] Hotfix validated — proceed to Change 03

---

## Change 03: migrate-completion-blink

### Merge

- [ ] Raise PR: `feat/03-migrate-completion-blink` → `main`
- [ ] Review and approve PR
- [ ] Merge PR

### Prepare test machine

- [ ] On test machine: `git pull origin main`
- [ ] Launch Neovim: `:Lazy sync` — wait for completion, confirm blink.cmp installs
- [ ] Confirm nvim-cmp and its sources are no longer listed in `:Lazy`

### Validate

- [ ] Run validation cases for Change 03 (see `openspec/MANUAL_VALIDATION.md` § Change 03)

### Sign off

- [ ] Pass — proceed to Change 04
- [ ] Fail — raise issue, fix on branch, re-merge, re-test before continuing

---

## Change 04: modernize-editing-plugins

### Merge

- [ ] Raise PR: `feat/04-modernize-editing-plugins` → `main`
- [ ] Review and approve PR
- [ ] Merge PR

### Prepare test machine

- [ ] On test machine: `git pull origin main`
- [ ] Launch Neovim: `:Lazy sync` — wait for completion
- [ ] Confirm lualine.nvim and nvim-surround install; vim-airline, vim-surround, vim-sensible, vim-commentary absent from `:Lazy`

### Validate

- [ ] Run validation cases for Change 04 (see `openspec/MANUAL_VALIDATION.md` § Change 04)

### Sign off

- [ ] Pass — proceed to Change 05
- [ ] Fail — raise issue, fix, re-merge, re-test before continuing

---

## Change 05: upgrade-avante-drop-dressing

### Merge

- [ ] Raise PR: `feat/05-upgrade-avante-drop-dressing` → `main`
- [ ] Review and approve PR
- [ ] Merge PR

### Prepare test machine

- [ ] On test machine: `git pull origin main`
- [ ] Launch Neovim: `:Lazy update avante.nvim` — wait for update and build step
- [ ] If build did not run automatically: `:AvanteBuild` — wait for completion
- [ ] Confirm avante version in `:Lazy` starts with `v0.1.` and dressing.nvim is absent

### Validate

- [ ] Run validation cases for Change 05 (see `openspec/MANUAL_VALIDATION.md` § Change 05)

### Sign off

- [ ] Pass — proceed to Change 06
- [ ] Fail — raise issue, fix, re-merge, re-test before continuing

---

## Change 06: add-diagnostics-todo-panel

### Merge

- [ ] Raise PR: `feat/06-add-diagnostics-todo-panel` → `main`
- [ ] Review and approve PR
- [ ] Merge PR

### Prepare test machine

- [ ] On test machine: `git pull origin main`
- [ ] Launch Neovim: `:Lazy sync` — wait for completion
- [ ] Confirm trouble.nvim and todo-comments.nvim are listed in `:Lazy`

### Validate

- [ ] Run validation cases for Change 06 (see `openspec/MANUAL_VALIDATION.md` § Change 06)

### Sign off

- [ ] Pass — proceed to Change 07
- [ ] Fail — raise issue, fix, re-merge, re-test before continuing

---

## Change 07: add-dotnet-debug-test

### Prerequisites (confirm before merging)

- [ ] `netcoredbg --version` responds on test machine (installed in one-time setup)
- [ ] A runnable .NET solution is available on the test machine for debug/test validation
- [ ] A Haskell project is available (for DAP discovery check)

### Merge

- [ ] Raise PR: `feat/07-add-dotnet-debug-test` → `main`
- [ ] Review and approve PR (pay attention to `lsp.enabled = false` in easy-dotnet opts)
- [ ] Merge PR

### Prepare test machine

- [ ] On test machine: `git pull origin main`
- [ ] Launch Neovim: `:Lazy sync` — wait for completion
- [ ] Confirm nvim-dap, nvim-dap-ui, nvim-nio, easy-dotnet listed in `:Lazy`

### Validate

- [ ] Run validation cases for Change 07 (see `openspec/MANUAL_VALIDATION.md` § Change 07)

### Sign off

- [ ] Pass — proceed to Change 08
- [ ] Fail — raise issue, fix, re-merge, re-test before continuing

---

## Change 08: add-claudecode-session

### Prerequisites (confirm before merging)

- [ ] `claude` CLI is installed and authenticated on the test machine: `claude --version`
- [ ] MCP server can start: run `claude` in a terminal and confirm it launches

### Merge

- [ ] Raise PR: `feat/08-add-claudecode-session` → `main`
- [ ] Review and approve PR (confirm snacks.nvim is NOT in the dependency list)
- [ ] Merge PR

### Prepare test machine

- [ ] On test machine: `git pull origin main`
- [ ] Launch Neovim: `:Lazy sync` — wait for completion
- [ ] Confirm claudecode.nvim is listed in `:Lazy` and snacks.nvim is absent

### Validate

- [ ] Run validation cases for Change 08 (see `openspec/MANUAL_VALIDATION.md` § Change 08)

### Sign off

- [ ] Pass — all changes validated ✓
- [ ] Fail — raise issue, fix, re-merge, re-test

---

## All Changes Complete

- [ ] All 8 changes (hotfix + 03–08) merged to main and validated
- [ ] No open issues from validation runs
- [ ] `openspec/MANUAL_VALIDATION.md` updated with any notes from testing
