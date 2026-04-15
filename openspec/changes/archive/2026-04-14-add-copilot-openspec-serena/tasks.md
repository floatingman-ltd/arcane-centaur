## 1. Copilot CLI Integration

- [x] 1.1 Create `lua/config/copilot_cli.lua` with `CopilotSuggest` and `CopilotExplain` commands using `vim.system()` and a floating scratch window
- [x] 1.2 Guard both commands with `vim.fn.executable("gh")` check; emit `vim.notify` error on failure
- [x] 1.3 Implement visual-selection extraction (yanking to a temp register) so both commands work in normal and visual mode
- [x] 1.4 Add `require("config.copilot_cli")` call in `init.lua` or via the loader
- [x] 1.5 Add `<leader>gcs` (suggest) and `<leader>gce` (explain) keymaps in `lua/keymaps.lua`

## 2. OpenSpec Integration

- [x] 2.1 Create `lua/config/openspec.lua` with `OpenspecNew`, `OpenspecStatus`, and `OpenspecList` commands using synchronous `vim.fn.system()` and a bottom split scratch buffer
- [x] 2.2 Implement `vim.fn.input()` prompt in `OpenspecNew` and guard against empty/cancelled input
- [x] 2.3 Support optional `<name>` argument in `OpenspecStatus` for change-scoped output
- [x] 2.4 Add `require("config.openspec")` call in `init.lua` or via the loader
- [x] 2.5 Add `<leader>osn` (new), `<leader>oss` (status), `<leader>osl` (list) keymaps in `lua/keymaps.lua`

## 3. Serena MCP Server

- [x] 3.1 Add `vim.g.copilot_mcp_servers` declaration in `lua/plugins/copilot.lua` with Serena entry (`stdio`, `npx -y @oramasearch/serena`)
- [x] 3.2 Add logic to prefer global `serena` binary over `npx` when `vim.fn.executable("serena")` returns true

## 4. Documentation

- [x] 4.1 Update `readme.md` — add Copilot CLI and OpenSpec keymaps to General Keybindings table; add Serena prerequisites callout; update Plugin Overview table
- [x] 4.2 Update `docs/cheatsheets/index.md` — add rows for new keymaps
- [x] 4.3 Create `docs/cheatsheets/ai-tools.md` — full cheatsheet for Copilot CLI and OpenSpec keymaps
- [x] 4.4 Create `docs/guides/ai-tools.md` — guide covering installation prerequisites (`gh copilot`, `openspec`, Serena via npm) and usage walkthrough

## 5. Validation

- [x] 5.1 Syntax-check all new Lua files with `find . -name '*.lua' -print0 | xargs -0 luac -p`
- [x] 5.2 Smoke-test `:CopilotSuggest`, `:CopilotExplain`, `:OpenspecStatus`, `:OpenspecList` in a running Neovim session
- [x] 5.3 Verify `vim.g.copilot_mcp_servers` is set at startup with `:lua print(vim.inspect(vim.g.copilot_mcp_servers))`
