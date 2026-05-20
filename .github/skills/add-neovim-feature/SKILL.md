---
name: add-neovim-feature
description: Add a new feature to the arcane-centaur Neovim configuration. Guides implementation, architecture compliance, documentation (guide + cheatsheet), keybinding registration, and validation test authoring in one complete workflow.
license: MIT
metadata:
  author: arcane-centaur
  version: "1.0"
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
| is there an existing extension that does this already? | Install extension or compare options |
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

All three documentation targets are **required**. Do not skip any.

### 3a. Feature guide — `docs/modules/ROOT/pages/guides/<name>.adoc`

Structure:
```asciidoc
= <Feature Name> Guide

One-sentence description.

*Jump to:* <<quick-start>> · <<keybindings>> · <<configuration>> · <<troubleshooting>> · <<setup>> · <<prerequisites>>

== Quick Start

Numbered steps to get the feature working from zero.

== Keybindings

[width="100%",cols="25%,15%,60%",options="header"]
|===
|Keys |Mode |Action
|`<key>` |Normal |What it does
|===

== How It Works

Brief technical explanation (architecture-level, not code-level).

== Configuration

How to customise the feature (options, override locations).

'''

== Troubleshooting

[width="100%",cols="30%,30%,40%",options="header"]
|===
|Symptom |Cause |Fix
|... |... |...
|===

== Setup

Step-by-step install procedures (only if non-trivial).

== Prerequisites

[width="100%",cols="30%,30%,40%",options="header"]
|===
|Dependency |Purpose |Install hint
|... |... |...
|===
```

### 3b. Cheatsheet — `docs/modules/ROOT/pages/cheatsheets/<name>.adoc`

Structure:
```asciidoc
= <Feature Name> Cheatsheet

*Leader* = `Space` · *LocalLeader* = `,`

→ Back to xref:cheatsheets/index.adoc[main cheatsheet] · Guide: xref:guides/<name>.adoc[<Feature Name> guide]

== <Section>

[width="100%",cols="25%,15%,60%",options="header"]
|===
|Keys |Mode |Action
|`<key>` |Normal |What it does
|===

== User Commands

[width="100%",cols="40%,60%",options="header"]
|===
|Command |Description
|`:CommandName` |What it does
|===

'''

_Defined in `<source file>`._
```

### 3c. Update `docs/modules/ROOT/pages/cheatsheets/index.adoc`

1. Add a row to the **Plugin Cheatsheets** table:
   ```asciidoc
   |<Feature name> |xref:cheatsheets/<name>.adoc[<name>.adoc]
   ```
2. Add a **Quick Reference** section (or rows to an existing section):
   ```asciidoc
   === <Feature Name>

   [width="100%",cols="25%,15%,60%",options="header"]
   |===
   |Keys |Mode |Action
   |`<key>` |Normal |What it does
   |===

   → xref:cheatsheets/<name>.adoc[Full reference]
   ```

### 3d. Update `docs/modules/ROOT/nav.adoc`

Add the new guide and cheatsheet entries under the appropriate topic group. The nav is hand-authored — do not leave orphaned entries for deleted files.

```asciidoc
** xref:guides/<name>.adoc[<Feature Name>]
** xref:cheatsheets/<name>.adoc[<Feature Name> Cheatsheet]
```

---

## Step 4 — Final verification

Run all checks in sequence:

```bash
# 1. Lua syntax
find . -name '*.lua' -not -path '*/lazy/*' -not -path '*/.serena/*' \
  -print0 | xargs -0 luac -p && echo "Lua OK"
```

Then manually confirm in Neovim:
- `:Lazy` — plugin loaded (or not loaded if lazy by filetype, then open that filetype and check again)
- `:checkhealth` — no new errors introduced
- Open the target filetype (if applicable) and press the new keybinding
- Run `:verbose map <leader>X` (or the new key) to confirm it is registered with the expected `desc`

---

## Output on completion

```
## Feature Added: <name>

### Implementation
- <file 1> — <what was done>
- <file 2> — <what was done>

### Documentation
- docs/guides/<name>.md — feature guide
- docs/cheatsheets/<name>.md — keybinding reference
- docs/cheatsheets/index.md — updated plugin table + quick reference
- readme.md — updated <section(s)>

### Validation
- docs/guides/validation.md — section <N> added (<M> test steps)

### Lua syntax
All .lua files pass luac -p ✓
```

---

## Guardrails

- **Never skip documentation** — guide, cheatsheet, index, readme, and validation are all required for every feature.
- **Never hardcode terminal behaviour** — always branch on `require("config.terminal")` flags.
- **Use `buffer = true`** for every keymap defined inside `after/ftplugin/`.
- **Always include `desc`** in every `vim.keymap.set` call.
- **Run `luac -p`** after every Lua file write, not just at the end.
- **Pause after Step 1** and again after Step 2 if the implementation differs significantly from the plan — don't accumulate surprises.
- If a prerequisite (external binary, Docker image, env var) is needed, document it in **both** the guide and the validation precondition.
- If the feature is terminal-conditional (console vs GUI), add validation steps for **both** code paths.
