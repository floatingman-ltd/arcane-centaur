# Validation Test Plan

Checklist for validating each change before merging to main.
Test cases are captured in `openspec/MANUAL_VALIDATION.md`.
Work through this list top to bottom — each section must pass before moving to the next.

**Workflow per change:**
1. Switch to the feature branch on the test machine
2. Run `:Lazy sync` and any required setup
3. Validate (run the cases in `MANUAL_VALIDATION.md`)
4. Raise the PR and merge to main only after validation passes
5. Pull main on the test machine to confirm clean post-merge state

---

## One-Time Test Machine Setup

Complete once before any testing begins.

- [X] Confirm Neovim ≥ 0.12 is installed: `nvim --version`
- [X] Confirm Git is installed: `git --version`
- [X] Confirm Node.js + npm are installed (required by markdown-preview.nvim build): `node --version && npm --version`
- [ ] Confirm C compiler and make are installed (required to compile tree-sitter parsers): `gcc --version && make --version`
  - If missing on Debian/Ubuntu/WSL2: `sudo apt install build-essential`
- [X] Confirm `dotnet` SDK is installed (required for Change 07 testing): `dotnet --version`
- [ ] Install netcoredbg (required for Change 07 debugging tests) — **not** a NuGet tool; install from GitHub releases:
  ```bash
  # 1. Download the latest linux-amd64 release
  #    Check https://github.com/Samsung/netcoredbg/releases for current version
  NCDBG_VER=$(curl -s https://api.github.com/repos/Samsung/netcoredbg/releases/latest \
    | grep '"tag_name"' | cut -d'"' -f4)
  curl -L "https://github.com/Samsung/netcoredbg/releases/download/${NCDBG_VER}/netcoredbg-linux-amd64.tar.gz" \
    -o /tmp/netcoredbg.tar.gz

  # 2. Extract to ~/.local/share/netcoredbg/
  mkdir -p ~/.local/share/netcoredbg
  tar -xzf /tmp/netcoredbg.tar.gz -C ~/.local/share/netcoredbg/

  # 3. Add to PATH (add this line to ~/.zshrc or ~/.bashrc, then source it)
  export PATH=$PATH:$HOME/.local/share/netcoredbg
  ```
- [ ] Verify netcoredbg is on PATH: `netcoredbg --version`
- [ ] Confirm `claude` CLI is installed and authenticated (required for Change 08): `claude --version`
- [ ] Clone the repo: `git clone git@github.com:floatingman-ltd/arcane-centaur.git ~/.config/nvim`
- [ ] Confirm initial main state loads: `nvim` → `:Lazy sync` → no errors in `:messages`

---

## Hotfix: treesitter-markdown-highlight-disable

### Prepare test machine

- [ ] Switch to the hotfix branch: `git fetch origin && git checkout fix/treesitter-markdown-highlight-disable`
- [ ] Launch Neovim: `:Lazy sync` — wait for completion
- [ ] Run `:TSUpdate` — wait for completion

### Validate

- [ ] Open `samples/hello.lua` (or any `.md` file)
- [ ] Run `:messages` — confirm no `nil range` / `languagetree` error appears
- [ ] Open `readme.md` — confirm no crash on markdown open
- [ ] Close Neovim

### Merge

- [ ] Raise PR: `fix/treesitter-markdown-highlight-disable` → `main`
- [ ] Review and approve PR
- [ ] Merge PR

### Post-merge

- [ ] `git checkout main && git pull origin main`
- [ ] Launch Neovim: `:Lazy sync` — confirm clean

### Sign off

- [ ] Hotfix validated and merged — proceed to Change 03

---

## Change 03: migrate-completion-blink

### Prepare test machine

- [ ] Switch to the feature branch: `git fetch origin && git checkout feat/03-migrate-completion-blink`
- [ ] Launch Neovim: `:Lazy sync` — wait for completion, confirm blink.cmp installs
- [ ] Confirm nvim-cmp and its sources are no longer listed in `:Lazy`

### Validate

- [ ] Run validation cases for Change 03 (see `openspec/MANUAL_VALIDATION.md` § Change 03)

### Merge

- [ ] Raise PR: `feat/03-migrate-completion-blink` → `main`
- [ ] Review and approve PR
- [ ] Merge PR

### Post-merge

- [ ] `git checkout main && git pull origin main`
- [ ] Launch Neovim: `:Lazy sync` — confirm clean

### Sign off

- [ ] Pass — proceed to Change 04
- [ ] Fail — raise issue, fix on branch, re-validate before merging

---

## Change 04: modernize-editing-plugins

### Prepare test machine

- [ ] Switch to the feature branch: `git fetch origin && git checkout feat/04-modernize-editing-plugins`
- [ ] Launch Neovim: `:Lazy sync` — wait for completion
- [ ] Confirm lualine.nvim and nvim-surround install; vim-airline, vim-surround, vim-sensible, vim-commentary absent from `:Lazy`

### Validate

- [ ] Run validation cases for Change 04 (see `openspec/MANUAL_VALIDATION.md` § Change 04)

### Merge

- [ ] Raise PR: `feat/04-modernize-editing-plugins` → `main`
- [ ] Review and approve PR
- [ ] Merge PR

### Post-merge

- [ ] `git checkout main && git pull origin main`
- [ ] Launch Neovim: `:Lazy sync` — confirm clean

### Sign off

- [ ] Pass — proceed to Change 05
- [ ] Fail — raise issue, fix, re-validate before merging

---

## Change 05: upgrade-avante-drop-dressing

### Prepare test machine

- [ ] Switch to the feature branch: `git fetch origin && git checkout feat/05-upgrade-avante-drop-dressing`
- [ ] Launch Neovim: `:Lazy update avante.nvim` — wait for update and build step
- [ ] If build did not run automatically: `:AvanteBuild` — wait for completion
- [ ] Confirm avante version in `:Lazy` starts with `v0.1.` and dressing.nvim is absent

### Validate

- [ ] Run validation cases for Change 05 (see `openspec/MANUAL_VALIDATION.md` § Change 05)

### Merge

- [ ] Raise PR: `feat/05-upgrade-avante-drop-dressing` → `main`
- [ ] Review and approve PR
- [ ] Merge PR

### Post-merge

- [ ] `git checkout main && git pull origin main`
- [ ] Launch Neovim: `:Lazy sync` — confirm clean

### Sign off

- [ ] Pass — proceed to Change 06
- [ ] Fail — raise issue, fix, re-validate before merging

---

## Change 06: add-diagnostics-todo-panel

### Prepare test machine

- [ ] Switch to the feature branch: `git fetch origin && git checkout feat/06-add-diagnostics-todo-panel`
- [ ] Launch Neovim: `:Lazy sync` — wait for completion
- [ ] Confirm trouble.nvim and todo-comments.nvim are listed in `:Lazy`

### Validate

- [ ] Run validation cases for Change 06 (see `openspec/MANUAL_VALIDATION.md` § Change 06)

### Merge

- [ ] Raise PR: `feat/06-add-diagnostics-todo-panel` → `main`
- [ ] Review and approve PR
- [ ] Merge PR

### Post-merge

- [ ] `git checkout main && git pull origin main`
- [ ] Launch Neovim: `:Lazy sync` — confirm clean

### Sign off

- [ ] Pass — proceed to Change 07
- [ ] Fail — raise issue, fix, re-validate before merging

---

## Change 07: add-dotnet-debug-test

### Prerequisites (confirm before switching branch)

- [ ] `netcoredbg --version` responds on test machine (installed in one-time setup)
- [ ] A runnable .NET solution is available on the test machine for debug/test validation
- [ ] A Haskell project is available (for DAP discovery check — optional)

### Prepare test machine

- [ ] Switch to the feature branch: `git fetch origin && git checkout feat/07-add-dotnet-debug-test`
- [ ] Launch Neovim: `:Lazy sync` — wait for completion
- [ ] Confirm nvim-dap, nvim-dap-ui, nvim-nio, easy-dotnet listed in `:Lazy`

### Validate

- [ ] Run validation cases for Change 07 (see `openspec/MANUAL_VALIDATION.md` § Change 07)

### Merge

- [ ] Raise PR: `feat/07-add-dotnet-debug-test` → `main` (pay attention to `lsp.enabled = false` in easy-dotnet opts)
- [ ] Review and approve PR
- [ ] Merge PR

### Post-merge

- [ ] `git checkout main && git pull origin main`
- [ ] Launch Neovim: `:Lazy sync` — confirm clean

### Sign off

- [ ] Pass — proceed to Change 08
- [ ] Fail — raise issue, fix, re-validate before merging

---

## Change 08: add-claudecode-session

### Prerequisites (confirm before switching branch)

- [ ] `claude` CLI is installed and authenticated on the test machine: `claude --version`
- [ ] MCP server can start: run `claude` in a terminal and confirm it launches

### Prepare test machine

- [ ] Switch to the feature branch: `git fetch origin && git checkout feat/08-add-claudecode-session`
- [ ] Launch Neovim: `:Lazy sync` — wait for completion
- [ ] Confirm claudecode.nvim is listed in `:Lazy` and snacks.nvim is absent

### Validate

- [ ] Run validation cases for Change 08 (see `openspec/MANUAL_VALIDATION.md` § Change 08)

### Merge

- [ ] Raise PR: `feat/08-add-claudecode-session` → `main` (confirm snacks.nvim is NOT in the dependency list)
- [ ] Review and approve PR
- [ ] Merge PR

### Post-merge

- [ ] `git checkout main && git pull origin main`
- [ ] Launch Neovim: `:Lazy sync` — confirm clean

### Sign off

- [ ] Pass — all changes validated ✓
- [ ] Fail — raise issue, fix, re-validate before merging

---

## All Changes Complete

- [ ] All changes (hotfix + 03–08) validated on branch and merged to main
- [ ] No open issues from validation runs
- [ ] `openspec/MANUAL_VALIDATION.md` updated with any notes from testing
