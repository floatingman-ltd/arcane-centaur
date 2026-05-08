---
description: Add a new feature to the arcane-centaur Neovim configuration — implementation, architecture compliance, documentation (guide + cheatsheet), keybinding registration, and validation tests.
---

Add a new feature to this Neovim configuration end-to-end:
code → architecture → keybindings → docs → validation tests.

---

## Preflight

Read the project conventions before touching anything:

```bash
cat .github/copilot-instructions.md
```

Key rules to internalise:
- `init.lua` loads `options` → `loader` → `keymaps` in that order
- Plugins live in `lua/plugins/<name>.lua`, each returning a lazy.nvim spec table
- Non-plugin config lives in `lua/config/`
- Filetype keymaps live in `after/ftplugin/<ft>.lua` using `<localleader>` (`,`)
- Global keymaps live in `lua/keymaps.lua` using `<leader>` (Space)
- Terminal flags come from `require("config.terminal")` — never hardcode terminal behaviour
- All Lua changes must pass: `find . -name '*.lua' -not -path '*/lazy/*' -print0 | xargs -0 luac -p`

---

## Step 1 — Understand the feature

If the user has not described what they want, ask:

> "What feature do you want to add? Describe what it should do, which filetypes it applies to (if any), and how the user will invoke it."

From their description, determine:

| Question | Answer drives |
|---|---|
| Is it a new plugin or pure Lua? | New `lua/plugins/` file vs `lua/config/` module |
| Filetype-specific or global? | `after/ftplugin/<ft>.lua` vs `lua/keymaps.lua` |
| Does it need a Docker service? | `docker/` compose file + readme section |
| Does it branch on terminal type? | Use `require("config.terminal")` flags |
| Does it add an LSP server? | Register in `lua/config/lsp.lua` |
| Does it add a formatter? | Register in `lua/plugins/conform.lua` |

Announce your answers before proceeding:

```
## Feature Plan

**What:** <one-sentence description>
**Type:** plugin | pure-Lua module | ftplugin setting
**Scope:** global | filetype (<ft>)
**Keybindings:** <leader>X (normal), <localleader>Y (in <ft> buffers), ...
**New files:** <list>
**Modified files:** <list>
**Docs needed:** guide | cheatsheet | readme section | validation section
```

**PAUSE** — wait for user confirmation before writing any code.

---

## Step 2 — Implement

Work through the following in order. Mark each item complete as you go.

### 2a. Core Lua

**New plugin:**
- Create `lua/plugins/<name>.lua` returning a lazy.nvim spec table.
- Use `ft = { "<ft>", ... }` for filetype-scoped plugins.
- Use `cond = function() return ... end` for environment-conditional loading
  (e.g. `term.is_console`, `term.is_wsl`).
- Add `opts = { ... }` and a `config` function only when setup is needed.

**New config module (no plugin):**
- Create `lua/config/<name>.lua` exporting `M.setup()`.
- Call `require("config.<name>").setup()` from the appropriate ftplugin or
  from `lua/loader/init.lua` if global.

**LSP server:**
- Add `lspconfig.<server>.setup{ on_attach = on_attach }` in `lua/config/lsp.lua`.
- Do not duplicate the `on_attach` function.

**Formatter:**
- Add the filetype entry to `formatters_by_ft` in `lua/plugins/conform.lua`.

### 2b. Keybindings

**Global keymaps** (`lua/keymaps.lua`):
```lua
vim.keymap.set({ "n", "v" }, "<leader>X", "<cmd>Command<CR>",
  { noremap = true, silent = true, desc = "Brief description" })
```

**Filetype keymaps** (`after/ftplugin/<ft>.lua`):
```lua
vim.keymap.set("n", "<localleader>X", "<cmd>Command<CR>",
  { noremap = true, silent = true, buffer = true, desc = "Brief description" })
```

Rules:
- Always include a `desc` string — it appears in `:map` and which-key.
- Use `buffer = true` for all ftplugin keymaps.
- Do not shadow existing global mappings; check with `:verbose map <key>`.

### 2c. Lua syntax check

After every file write:

```bash
find . -name '*.lua' -not -path '*/lazy/*' -not -path '*/.serena/*' \
  -print0 | xargs -0 luac -p && echo "Lua OK"
```

Stop and fix any errors before continuing.

---

## Step 3 — Documentation

All four documentation targets are **required**. Do not skip any.

### 3a. Feature guide — `docs/guides/<name>.md`

Structure:
```markdown
# <Feature Name> Guide

One-sentence description.

## Prerequisites

Dependencies the user must install before this feature works.
Include install commands for Debian/Ubuntu, Fedora, macOS, WSL.

## Quick Start

Numbered steps to get the feature working from zero.

## How It Works

Brief technical explanation (architecture-level, not code-level).

## Keybindings

| Keys | Mode | Action |
|---|---|---|
| ... | ... | ... |

## Configuration

How to customise the feature (options, override locations).

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| ... | ... | ... |
```

### 3b. Cheatsheet — `docs/cheatsheets/<name>.md`

Structure:
```markdown
# <Feature Name> Cheatsheet

**Leader** = `Space` · **LocalLeader** = `,`

→ Back to [main cheatsheet](index.md) · Guide: [../guides/<name>.md](../guides/<name>.md)

## <Section>

| Keys | Mode | Action |
|---|---|---|
| ... | ... | ... |

## User Commands

| Command | Description |
|---|---|
| `:CommandName` | What it does |

---

*Defined in `<source file>`.*
```

### 3c. Update `docs/cheatsheets/index.md`

1. Add a row to the **Plugin Cheatsheets** table at the top.
2. Add a **Quick Reference** section (or rows to an existing section).

### 3d. Update `readme.md`

Update the section(s) appropriate to the feature type:

| Feature type | Section(s) to update |
|---|---|
| New plugin | Prerequisites table, Plugin Overview, Project Structure |
| New keybinding | General Keybindings table |
| New language support | Supported Languages table; add a "Working with <Lang>" section |
| New LSP server | LSP Support table |
| New Docker service | Add a "Working with <Feature>" section with start/stop commands |
| Terminal / font | Terminal Auto-Detection table |

Also add the new guide link to the prerequisites paragraph:
```markdown
... · [<Feature Name>](docs/guides/<name>.md)
```

---

## Step 4 — Validation tests

Add a new numbered section to `docs/guides/validation.md`.

### Finding the next section number

```bash
grep -c "^## [0-9]" docs/guides/validation.md
```

The new section number is that count + 1.

### Section structure

```markdown
## <N>. <Feature Name>

**Precondition:** <what must be true / installed before running these tests>

- [ ] <N>.1 Confirm the feature loaded (`:Lazy` / `:checkhealth` / command exists):
  ```
  <command>
  ```
  **Expected:** <what a passing result looks like>

- [ ] <N>.2 Test the primary happy path:
  <steps>
  **Expected:** <result>

- [ ] <N>.3 Test the primary keybinding:
  ```
  <key sequence>
  ```
  **Expected:** <result>

- [ ] <N>.4 Test graceful failure / error handling:
  <steps to trigger the error case>
  **Expected:** <meaningful error message or notification, no crash>
```

**Requirements for validation steps:**
- At least one step **verifies the feature loaded**.
- At least one step **tests the primary user-facing action**.
- At least one step **tests graceful failure**.
- One step per distinct keybinding.
- Steps must be **executable by the reader with exact commands**.

### Update the Summary Checklist

Add a row to the table at the bottom of `validation.md`:

```markdown
| <N> | <Feature name> | [ ] |
```

---

## Step 5 — Final verification

```bash
# Lua syntax
find . -name '*.lua' -not -path '*/lazy/*' -not -path '*/.serena/*' \
  -print0 | xargs -0 luac -p && echo "Lua OK"
```

Then in Neovim:
- `:Lazy` — plugin loaded (open target filetype first if lazy-loaded)
- `:checkhealth` — no new errors
- Exercise each new keybinding
- `:verbose map <key>` — confirm `desc` is registered

---

## Output on completion

```
## Feature Added: <name>

### Implementation
- <file> — <what was done>

### Documentation
- docs/guides/<name>.md — feature guide
- docs/cheatsheets/<name>.md — keybinding reference
- docs/cheatsheets/index.md — updated
- readme.md — updated <section(s)>

### Validation
- docs/guides/validation.md — section <N> added (<M> test steps)

### Lua syntax
All .lua files pass luac -p ✓
```

---

## Guardrails

- **Never skip documentation** — guide, cheatsheet, index, readme, and validation are all required.
- **Never hardcode terminal behaviour** — always branch on `require("config.terminal")` flags.
- **Use `buffer = true`** for every keymap defined inside `after/ftplugin/`.
- **Always include `desc`** in every `vim.keymap.set` call.
- **Run `luac -p`** after every Lua file write, not just at the end.
- **Pause after Step 1** to confirm the plan before writing code.
- If a prerequisite is needed, document it in **both** the guide and the validation precondition.
- If the feature is terminal-conditional, add validation steps for **both** code paths.
