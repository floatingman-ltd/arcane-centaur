## ADDED Requirements

### Requirement: lua_ls is configured for the Neovim runtime
A Neovim configuration is not an ordinary Lua project: the `vim` global is injected by the host program and the API definitions live in `$VIMRUNTIME`. `lua_ls` SHALL therefore be registered with a `settings` table supplying `runtime.version` of `LuaJIT`, `workspace.library` containing `$VIMRUNTIME` with `checkThirdParty` disabled, and `diagnostics.globals` listing the globals injected by host programs. Without it the server analyses the tree as plain Lua and reports every `vim` reference as an undefined global, which makes the diagnostics list unreadable rather than merely untidy.

#### Scenario: The vim global is not reported as undefined
- **WHEN** a Lua file in this configuration references `vim`
- **THEN** `lua_ls` SHALL NOT report `Undefined global \`vim\``

#### Scenario: Neovim API definitions are available
- **WHEN** the cursor rests on a `vim.*` API call and hover is requested
- **THEN** `lua_ls` SHALL supply the signature and documentation from `$VIMRUNTIME`
- **AND** deprecated API usage SHALL be reported as a diagnostic

#### Scenario: Pandoc filter globals are not reported as undefined
- **WHEN** a Pandoc Lua filter under `docker/md2pdf/` or `scripts/` references `pandoc`
- **THEN** `lua_ls` SHALL NOT report `Undefined global \`pandoc\``
- **AND** the reason SHALL be the same as for `vim` — a global injected by the host program, here Pandoc rather than Neovim

#### Scenario: Diagnostics remain readable
- **WHEN** every tracked Lua file in the repository is opened in turn
- **THEN** the total diagnostic count SHALL be small enough to read in full
- **AND** `Undefined global` SHALL NOT be the dominant category

### Requirement: Server registration is otherwise unchanged
Adding the settings table SHALL NOT alter which servers attach, the shared `on_attach`, the advertised capabilities, or any keymap.

#### Scenario: Keymaps and attachment unaffected
- **WHEN** a `.lua` file is opened with `lua-language-server` on `$PATH`
- **THEN** `lua_ls` SHALL attach as before
- **AND** the keymaps registered by the shared `on_attach` SHALL be identical to those in other language buffers

#### Scenario: Missing binary still does not crash
- **WHEN** `lua-language-server` is not installed or not on `$PATH`
- **THEN** Neovim SHALL start without error and no LSP SHALL attach to Lua buffers
