## Context

The config already has `github/copilot.vim` for inline completions. The surrounding tooling — `gh copilot` CLI, the in-repo `openspec` workflow tool, and the Serena MCP server — has no Neovim integration. Each tool lives in the terminal and is completely disconnected from the editor. This change adds lightweight Lua modules and keymaps so developers can drive all three from inside Neovim without switching context.

The config follows the pattern: config logic in `lua/config/`, global keymaps in `lua/keymaps.lua`, filetype keymaps in `after/ftplugin/`, and plugin declarations in `lua/plugins/`.

## Goals / Non-Goals

**Goals:**
- Add `lua/config/copilot_cli.lua` with `:CopilotSuggest` and `:CopilotExplain` commands that pass the current buffer or visual selection to `gh copilot suggest` / `gh copilot explain` and display the result.
- Add `lua/config/openspec.lua` with `:OpenspecNew`, `:OpenspecStatus`, and `:OpenspecList` commands, wired to `<leader>os*` keymaps and loaded at startup.
- Add Serena MCP server configuration inside `lua/plugins/copilot.lua` so `copilot.vim` can discover and route requests to it.
- Document all new keybindings in `readme.md`, `docs/cheatsheets/index.md`, and a new `docs/cheatsheets/ai-tools.md`.

**Non-Goals:**
- Building a full TUI for OpenSpec or Copilot CLI.
- Replacing the existing `copilot.vim` inline completion setup.
- Auto-starting or managing the Serena process — the user is responsible for running it.

## Decisions

### 1. Copilot CLI: `vim.system()` with floating window output

`vim.system()` (Neovim 0.10+) is already used elsewhere in this config (`lua/config/confluence.lua`). Shell output is collected async and rendered in a scratch buffer inside a floating window using `nvim_open_win`. This keeps it non-blocking and consistent with the rest of the config.

**Alternative considered**: ToggleTerm / vim-floaterm. Rejected — adds another plugin dependency for a simple one-shot command.

### 2. OpenSpec: synchronous `vim.fn.system()` with split output

OpenSpec commands (`new`, `status`, `list`) are fast and non-interactive. Using synchronous `vim.fn.system()` and opening a read-only scratch buffer in a bottom split is simpler than async and is sufficient for sub-second commands.

**Alternative considered**: Async with `vim.system()`. Acceptable but overkill for sub-second CLI calls.

### 3. Serena MCP: `vim.g.copilot_mcp_servers` table in `copilot.lua`

`copilot.vim` reads `vim.g.copilot_mcp_servers` (a Vimscript global) to discover MCP servers. We add Serena there using the `stdio` transport pointing at its `npx` launch command. Config lives in `lua/plugins/copilot.lua` alongside the existing Copilot setup.

**Alternative considered**: A separate `lua/plugins/serena.lua`. Rejected — Serena has no lazy.nvim plugin; it's a pure runtime config entry.

### 4. Keymap namespace

- Copilot CLI: `<leader>gc` prefix (`g`=GitHub, `c`=Copilot): `<leader>gcs` suggest, `<leader>gce` explain.
- OpenSpec: `<leader>os` prefix: `<leader>osn` new, `<leader>oss` status, `<leader>osl` list.

These do not conflict with any existing keymaps in `lua/keymaps.lua`.

## Risks / Trade-offs

- **`gh copilot` not installed** → Commands fail with a clear error message via `vim.notify`. Mitigation: guard with `vim.fn.executable("gh")` check.
- **Serena not running** → Copilot silently skips the MCP server; no editor crash. Low risk.
- **`npx` startup latency for Serena** → First MCP call may be slow if Serena package isn't cached. Mitigation: document `npm install -g @oramasearch/serena` as the preferred setup.
- **OpenSpec CWD mismatch** → Commands must run from the repo root. Mitigation: always call with `cwd = vim.fn.getcwd()` and surface the path in the output header.
