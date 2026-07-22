## Why

This config has **no debugging capability at all**, and no inline test runner. The .NET side has a REPL (iron.nvim → `dotnet fsi` / `csharprepl`) and an LSP (roslyn.nvim for C#, fsautocomplete for F#), but evaluation — not breakpoint debugging or run-nearest-test — is all it offers. The best-of-breed evaluation rates breakpoint debugging for .NET as HIGH.

`GustavEikaas/easy-dotnet.nvim` bundles .NET solution management, a test runner, and netcoredbg-based debugging, auto-discovering launch configurations from the project structure (no hand-authored `launch.json`). It explicitly supports both C# and F#. The debug substrate is `nvim-dap` + `nvim-dap-ui`.

Cross-validation of the *actual* config shaped three decisions:

1. **roslyn.nvim already owns the C# LSP**, and the in-progress `migrate-completion-blink` change will feed it blink's completion capabilities via `lua/config/lsp.lua`. easy-dotnet can also set up a Roslyn server — so it MUST be configured to **not** manage the LSP, to avoid a duplicate C# language server.
2. **fzf-lua is the picker.** easy-dotnet supports a `fzf` picker backend, so it integrates with the existing fuzzy-picker model rather than pulling in telescope or snacks.
3. **Haskell debugging comes for free.** `haskell-tools.nvim` (installed, `^6`) auto-discovers DAP configurations once `nvim-dap` is present. Adding nvim-dap for .NET unlocks Haskell breakpoint debugging at zero incremental cost.

## What Changes

- **Add** `nvim-dap` + `rcarriga/nvim-dap-ui` (+ its `nvim-nio` dep) in a new `lua/plugins/dap.lua`, with the netcoredbg adapter registered and a debug keymap set on **function keys** (`<F5>`/`<F9>`/`<F10>`/`<F11>`/`<F12>`/`<S-F5>`) plus a `<leader>b` "Debug" group for the rest.
- **Add** `GustavEikaas/easy-dotnet.nvim` to `lua/plugins/dotnet.lua`, scoped to `ft = { "cs", "fsharp" }`, with `picker = "fzf"`, LSP/Roslyn management **disabled** (roslyn.nvim keeps that role), and its test runner + debug discovery enabled.
- **Add** `<localleader>` .NET test/run maps in `after/ftplugin/cs.lua` and `after/ftplugin/fsharp.lua` (mirroring the iron.nvim `<localleader>s*` REPL-map convention so all .NET actions are filetype-local).
- **Register** a `<leader>b` "Debug" which-key group.
- **Keep** iron.nvim (REPL), roslyn.nvim (C# LSP), and fsautocomplete (F# LSP) exactly as they are — this change is additive.
- **Haskell**: no code change beyond nvim-dap existing; verify haskell-tools auto-discovers a DAP config.

## Capabilities

### New Capabilities

- `dotnet-debugging`: breakpoint debugging for C# and F# via nvim-dap + nvim-dap-ui + netcoredbg, with launch configurations auto-discovered by easy-dotnet; Haskell breakpoint debugging available via haskell-tools' DAP auto-discovery.
- `dotnet-test-runner`: run and inspect .NET tests (xUnit/NUnit/MSTest) from the editor via easy-dotnet's built-in test runner, with `<localleader>` maps in the C#/F# ftplugins.

### Modified Capabilities

<!-- none — there is no existing OpenSpec requirement for .NET debugging or testing; the REPL (iron) and LSP (roslyn/fsautocomplete) capabilities are untouched -->

## Impact

- **`lua/plugins/dap.lua`** → new (nvim-dap, nvim-dap-ui, nvim-nio, netcoredbg adapter, debug keymaps).
- **`lua/plugins/dotnet.lua`** → add the easy-dotnet spec alongside the existing iron.nvim and roslyn.nvim specs (both unchanged).
- **`after/ftplugin/cs.lua`** / **`after/ftplugin/fsharp.lua`** → add `<localleader>` test/run maps.
- **`lua/plugins/which-key.lua`** → register the `<leader>b` "Debug" group.
- **`lua/config/lsp.lua`** → **untouched**. easy-dotnet does not manage the LSP, so it does not collide with the `migrate-completion-blink` change's capabilities rewrite there.
- **External prerequisites**: `netcoredbg` on `$PATH` (or installed via the adapter's documented path); existing `dotnet`, `csharprepl`, Roslyn server unchanged.
- **plenary.nvim**: required by easy-dotnet; already present (declared by avante, retained by `upgrade-avante-drop-dressing`). Declared in easy-dotnet's deps for robustness.
- **Independence**: decoupled from the AsciiDoc / textobjects / claudecode changes. Coordinates with `migrate-completion-blink` only by *not* touching `lsp.lua`.

## Prerequisites and sequencing

**Sequence position:** 07 of 08 — Wave B (appends `<leader>b` to which-key after 06; recommended after 03-migrate-completion-blink).

- **Hard prerequisites:** none — but two coordination points:
  1. **Shared file — `lua/plugins/which-key.lua`:** also edited by `add-diagnostics-todo-panel` (`<leader>x` group). This change adds a `<leader>b` "Debug" group to the same `wk.add({ ... })` call. **Rule:** if `add-diagnostics-todo-panel` is implemented first (recommended), append `<leader>b` to its existing list; do not replace the call.
  2. **Recommended after `migrate-completion-blink`** so the "exactly one Roslyn client" verification runs against the final blink-fed capabilities in `lua/config/lsp.lua`. This change does **not** edit `lsp.lua`, so the ordering is a *soft* recommendation, not a hard requirement.
- **Must NOT edit `lua/config/lsp.lua`:** easy-dotnet's LSP/Roslyn management stays disabled so roslyn.nvim remains the sole C# server — this is the mechanism that keeps it compatible with `migrate-completion-blink` regardless of order.
- **Implementation wave: B** (after Wave A).

## Out of scope

- `neotest` + `neotest-dotnet`/`neotest-vstest` — easy-dotnet's built-in runner covers the run-nearest/inspect workflow; a separate neotest adapter is a future optional change.
- A Haskell-specific debug adapter install (`haskell-debug-adapter` / `haskell-debugger`) — verification only; full Haskell debug setup is deferred.
- Hand-authored `launch.json` workflows — easy-dotnet's auto-discovery is the intended path.
- `<F5>`-family remaps for non-.NET languages beyond what nvim-dap provides generically.
