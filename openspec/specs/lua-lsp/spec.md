## Purpose

Defines Lua LSP support via `lua_ls` (lua-language-server), registered through the native `vim.lsp.config`/`vim.lsp.enable` API with the shared `on_attach`, supplying diagnostics, hover, go-to-definition, references, rename and code actions in Lua buffers.

It also carries the settings that make those diagnostics worth reading, which is the part a reader would not guess. A Neovim configuration is not an ordinary Lua project: `vim` is injected by the host program and the API definitions live in `$VIMRUNTIME`, so without a `workspace.library` pointing there `lua_ls` reports every `vim` reference as an undefined global — measured at 659 of 661 diagnostics across the tree before it was configured. `pandoc` is silenced on the same grounds, for the filters under `docker/md2pdf/` and `scripts/` that run inside Pandoc rather than Neovim.

The distinction worth preserving: `diagnostics.globals` alone would silence the reports while teaching the server nothing. The library is what supplies real definitions, and therefore what makes hover, deprecation warnings and type errors possible at all. Narrowing it to `$VIMRUNTIME` rather than the whole runtime path is deliberate — the wider form indexes every installed plugin for no benefit this configuration needs.

## Requirements
### Requirement: lua_ls is configured as the Lua LSP server
The config SHALL register `lua_ls` via the native `vim.lsp.config`/`vim.lsp.enable` API
using the shared `on_attach` function defined in `lua/config/lsp.lua`, providing
diagnostics, hover documentation, go-to-definition, references, rename, and code actions
in Lua buffers.

#### Scenario: LSP attaches on Lua buffer open
- **WHEN** the user opens a `.lua` file and `lua-language-server` is on `$PATH`
- **THEN** `lua_ls` attaches to the buffer and LSP keymaps (`gd`, `K`, `gr`, `<leader>rn`, `<leader>ca`, `<leader>e`, `[d`, `]d`) are active

#### Scenario: LSP keymaps match other languages
- **WHEN** `lua_ls` attaches to a Lua buffer
- **THEN** all keymaps are identical to those registered by the shared `on_attach` function used for `fsautocomplete`, `marksman`, and other configured servers

#### Scenario: Missing binary does not crash
- **WHEN** `lua-language-server` is not installed or not on `$PATH`
- **THEN** Neovim starts without error and no LSP attaches to Lua buffers

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

