## ADDED Requirements

### Requirement: Lua filetype plugin sets 2-space indentation
The config SHALL provide `after/ftplugin/lua.lua` that sets `shiftwidth=2`, `tabstop=2`, `softtabstop=2`, and `expandtab` for all Lua buffers, matching Neovim's own Lua coding style.

#### Scenario: Indent settings applied on Lua buffer open
- **WHEN** the user opens any `.lua` file
- **THEN** `shiftwidth`, `tabstop`, and `softtabstop` are all 2, and `expandtab` is enabled for that buffer

#### Scenario: Settings are buffer-local
- **WHEN** a Lua buffer is open alongside a buffer of another filetype
- **THEN** the Lua indent settings do not affect the other buffer's settings
