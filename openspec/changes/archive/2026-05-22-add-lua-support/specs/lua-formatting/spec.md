## ADDED Requirements

### Requirement: Lua files are formatted with stylua on save
The config SHALL add `lua` to `conform.nvim`'s `formatters_by_ft` table using `{ "stylua" }` and to the `ft` lazy-load guard, so that Lua buffers are formatted with `stylua` on every save.

#### Scenario: Format on save triggers stylua
- **WHEN** the user saves a Lua file and `stylua` is on `$PATH`
- **THEN** `stylua` formats the buffer before write, within the 2000 ms timeout

#### Scenario: Manual format keybinding works for Lua
- **WHEN** the user presses `<leader>f` in a Lua buffer
- **THEN** `conform.format({ async = true })` runs `stylua` on the current buffer or visual selection

#### Scenario: Missing stylua does not block save
- **WHEN** `stylua` is not installed or not on `$PATH`
- **THEN** the file is saved without formatting and conform logs a warning
