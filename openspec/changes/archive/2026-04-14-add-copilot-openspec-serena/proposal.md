## Why

The Neovim config has strong AI assistance via `copilot.vim` but lacks deep integration with the surrounding developer workflow tools — GitHub Copilot CLI (`gh copilot`), the in-repo OpenSpec workflow, and the Serena MCP code-intelligence server. Adding these three integrations closes the gap between the editor and the tools used to build and manage the config itself.

## What Changes

- **Copilot CLI integration**: Add Neovim commands and keymaps to invoke `gh copilot suggest` and `gh copilot explain` from within the editor, feeding the current buffer or visual selection as context.
- **OpenSpec integration**: Add Neovim commands and keymaps to run common `openspec` CLI operations (new change, status, list) without leaving the editor; show output in a floating window or split.
- **Serena MCP server**: Configure Serena as an MCP server in `copilot.vim` to provide symbol-aware code intelligence (go-to-definition, references, workspace search) to GitHub Copilot chat and inline completions.

## Capabilities

### New Capabilities

- `copilot-cli-integration`: In-editor keymaps and commands for `gh copilot suggest` and `gh copilot explain`, operating on the current buffer or visual selection.
- `openspec-integration`: In-editor commands and keymaps for driving the OpenSpec workflow (create change, view status, list artifacts) from Neovim.
- `serena-mcp-server`: Configuration of the Serena MCP server so GitHub Copilot can leverage symbol-aware code intelligence across the workspace.

### Modified Capabilities

## Impact

- **New files**: `lua/config/copilot_cli.lua`, `lua/config/openspec.lua`, `lua/config/serena.lua` (MCP config), potentially `after/ftplugin/` entries for filetype-scoped keymaps.
- **Modified files**: `lua/plugins/copilot.lua` (add MCP server declaration for Serena), `lua/keymaps.lua` (global keymaps for Copilot CLI and OpenSpec), `readme.md`, and relevant docs.
- **External dependencies**: `gh` CLI with `copilot` extension installed, `openspec` CLI already present, Serena MCP server installed (e.g., via `npx` or global npm).
- No breaking changes to existing plugin configuration.
