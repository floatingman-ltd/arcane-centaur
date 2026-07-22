## ADDED Requirements

### Requirement: Breakpoint debugging for .NET via nvim-dap
C# and F# SHALL support breakpoint debugging through `nvim-dap` + `nvim-dap-ui`, using the netcoredbg adapter, with launch configurations auto-discovered by easy-dotnet (no hand-authored `launch.json`).

#### Scenario: Hit a breakpoint in a .NET program
- **WHEN** the user sets a breakpoint with `<F9>` in a C# or F# file in a runnable project and starts debugging with `<F5>`
- **THEN** the program SHALL launch under netcoredbg and pause at the breakpoint, with the dap-ui showing variables, call stack, and breakpoints

#### Scenario: Stepping controls
- **WHEN** execution is paused at a breakpoint and the user presses `<F10>`, `<F11>`, or `<F12>`
- **THEN** the debugger SHALL step over, step into, and step out respectively

#### Scenario: Debug keymaps avoid existing bindings
- **WHEN** the debug keymaps are registered
- **THEN** they SHALL use function keys and the `<leader>b` group, and SHALL NOT remap `<leader>d` (system-clipboard cut) or any existing `<localleader>s*` REPL map

### Requirement: Debugging does not introduce a second C# language server
Enabling easy-dotnet SHALL NOT start a second C# language server; roslyn.nvim (configured in `lua/config/lsp.lua`) SHALL remain the sole C# LSP.

#### Scenario: Exactly one Roslyn client
- **WHEN** the user opens a `.cs` file after this change
- **THEN** exactly one `roslyn` LSP client SHALL be attached to the buffer

### Requirement: Haskell debugging available via auto-discovery
With nvim-dap present, Haskell breakpoint debugging SHALL be available through haskell-tools' DAP auto-discovery, without additional per-project configuration.

#### Scenario: Haskell DAP config is discovered
- **WHEN** the user opens a Haskell file in a cabal/stack project with nvim-dap installed
- **THEN** a Haskell DAP configuration SHALL be discoverable by nvim-dap (or its absence documented for a follow-up change)
