## Why

The config has 81 keymaps spread across multiple files, but fewer than half have descriptions. Without which-key, there is no way to discover available keybindings at runtime — users must read source files. Adding which-key makes the entire keymap surface self-documenting and discoverable directly from the editor.

## What Changes

- Add `folke/which-key.nvim` plugin with group label registrations for all `<leader>` prefixes
- Add `desc` fields to all ~48 keymaps currently missing them across `lua/keymaps.lua`, `lua/config/lsp.lua`, `after/ftplugin/`, and plugin files
- Register keymap group names (`+Copilot`, `+OpenSpec`, `+LSP`, etc.) so the which-key popup shows meaningful prefixes

## Capabilities

### New Capabilities

- `which-key-popup`: Context-sensitive popup showing available keymaps when the user pauses after a prefix key, with group labels and descriptions

### Modified Capabilities

<!-- No existing specs require changes -->

## Impact

- `lua/plugins/which-key.lua`: new file — plugin spec with group registrations
- `lua/keymaps.lua`: add `desc` to ~20 keymaps missing descriptions
- `lua/config/lsp.lua`: add `desc` to LSP `on_attach` keymaps
- `after/ftplugin/*.lua`: add `desc` to filetype-local keymaps
- Plugin files (dotnet, fzf-lua, etc.): add `desc` where keymap opts are defined
- No breaking changes; additive only
- External prerequisite: none (installed via lazy.nvim)
