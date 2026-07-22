## Context

`lua/plugins/dotnet.lua` declares two specs:

- `Vigemus/iron.nvim` (`ft = { "fsharp", "cs" }`) — REPL: `<localleader>sl/sc/sp/sf/si/sq/cl` and `<localleader>s<cr>`.
- `seblyng/roslyn.nvim` (`ft = { "cs" }`, `opts = {}`) — official Microsoft Roslyn C# LSP. Keymaps (`gd`, `K`, `gr`, …) attach via the shared `on_attach` in `lua/config/lsp.lua`, which also defines the `roslyn` server config + capabilities.

`after/ftplugin/cs.lua` and `after/ftplugin/fsharp.lua` set 4-space indent, `spell=false`, and `maplocalleader = ","`. No debugger, no test runner, no `nvim-dap` anywhere in `lazy-lock.json`.

`mrcjkb/haskell-tools.nvim` (`^6`) is installed and, per its docs, auto-registers DAP configurations when `nvim-dap` is available.

The in-progress `migrate-completion-blink` change rewrites `capabilities` in `lua/config/lsp.lua` to `require("blink.cmp").get_lsp_capabilities(...)` and applies it to the `roslyn` server config. This change must not touch `lsp.lua`, so the two compose cleanly.

## Goals / Non-Goals

**Goals**
- Breakpoint debugging for C# and F# with a proper UI (variables, call stack, breakpoints, REPL).
- Launch configs auto-discovered from the project, no manual `launch.json`.
- Run/inspect .NET tests from the editor.
- Unlock Haskell debugging at zero extra cost.
- Keymaps that do not collide with existing maps and stay on-convention.

**Non-Goals**
- Replacing iron.nvim, roslyn.nvim, or fsautocomplete.
- A second C# language server (easy-dotnet must not manage Roslyn).
- neotest adapters.
- A full Haskell debug-adapter installation (verify-only).

## Decisions

### `nvim-dap` + `nvim-dap-ui` as the debug substrate (`lua/plugins/dap.lua`)
A dedicated file per the one-plugin-per-group convention:

```lua
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
    },
    keys = {  -- function keys: no <leader> conflicts
      { "<F5>",   function() require("dap").continue() end,          desc = "Debug: continue / start" },
      { "<S-F5>", function() require("dap").terminate() end,         desc = "Debug: terminate" },
      { "<F9>",   function() require("dap").toggle_breakpoint() end, desc = "Debug: toggle breakpoint" },
      { "<F10>",  function() require("dap").step_over() end,         desc = "Debug: step over" },
      { "<F11>",  function() require("dap").step_into() end,         desc = "Debug: step into" },
      { "<F12>",  function() require("dap").step_out() end,          desc = "Debug: step out" },
      -- <leader>b "Debug" group (b is free; <leader>d is taken by clipboard-cut)
      { "<leader>bb", function() require("dap").toggle_breakpoint() end, desc = "Debug: toggle breakpoint" },
      { "<leader>bc", function() require("dap").continue() end,          desc = "Debug: continue" },
      { "<leader>bu", function() require("dapui").toggle() end,          desc = "Debug: toggle UI" },
      { "<leader>br", function() require("dap").repl.toggle() end,       desc = "Debug: toggle REPL" },
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup()
      dap.listeners.before.attach.dapui_config = dapui.open
      dap.listeners.before.launch.dapui_config = dapui.open
      -- netcoredbg adapter (verify the binary path / install method at implementation time)
      dap.adapters.netcoredbg = {
        type = "executable",
        command = "netcoredbg",
        args = { "--interpreter=vscode" },
      }
    end,
  },
}
```

*Why function keys + `<leader>b`*: `<leader>d` (the conventional debug prefix) is already `"+d` (cut to system clipboard) in `lua/keymaps.lua`; creating a `<leader>d*` prefix would make which-key wait on the single-key cut map. `<leader>b` is unused. Function keys are the universal debugger idiom and collide with nothing here.

### easy-dotnet owns .NET launch discovery + tests; NOT the LSP
Added to `lua/plugins/dotnet.lua`:

```lua
{
  "GustavEikaas/easy-dotnet.nvim",
  ft = { "cs", "fsharp" },
  dependencies = { "nvim-lua/plenary.nvim", "ibhagwan/fzf-lua" },
  opts = {
    picker = "fzf",
    -- Do NOT let easy-dotnet configure a Roslyn/LSP server — roslyn.nvim owns it.
    -- (verify the exact opt name that disables LSP/roslyn management at impl time)
  },
}
```

easy-dotnet integrates with nvim-dap for debugging (auto-discovered launch profiles) and ships its own test runner state. The critical config is disabling its LSP/Roslyn management so there is exactly one C# language server. The exact option name SHALL be confirmed against the easy-dotnet docs at implementation time (the README documents how to skip its bundled Roslyn setup).

*Alternative considered*: manual `nvim-dap-cs` + hand-authored launch configs. Rejected — easy-dotnet's auto-discovery is lower-friction and bundles the test runner the evaluation also wants.

### .NET test/run maps are `<localleader>`, in the ftplugins
To match the iron.nvim `<localleader>s*` REPL convention (all .NET actions filetype-local), add to both `after/ftplugin/cs.lua` and `after/ftplugin/fsharp.lua`:

```lua
local map = function(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { buffer = true, desc = desc })
end
map("<localleader>tt", function() require("easy-dotnet").test_solution() end, ".NET: test solution")
map("<localleader>tr", function() require("easy-dotnet").run() end,            ".NET: run project")
map("<localleader>tb", function() require("easy-dotnet").build() end,          ".NET: build")
```

The exact easy-dotnet API names (`test_solution`/`run`/`build` vs. `:Dotnet test`/`run`/`build` Ex commands) SHALL be confirmed at implementation; prefer the documented public API. `<localleader>t*` does not collide with iron's `<localleader>s*`/`<localleader>cl`.

### Haskell debugging — verify, don't build
With nvim-dap present, haskell-tools auto-discovers a DAP config from cabal/stack. No code change beyond nvim-dap. A verification task checks whether `require("dap").configurations.haskell` (or haskell-tools' discovery) is populated in a Haskell project; a full adapter install (`haskell-debug-adapter`) is deferred to a future change if needed.

### which-key group
Register `{ "<leader>b", group = "Debug" }` in `lua/plugins/which-key.lua`'s `wk.add` call, alongside the existing Claude/OpenSpec groups.

## Risks / Trade-offs

- **easy-dotnet LSP collision (highest risk).** If easy-dotnet's Roslyn management is not disabled, two C# servers attach. Mitigation: confirm the disable-LSP option from the README; verify only one `roslyn` client is attached (`:lua =vim.lsp.get_clients({ name = "roslyn" })`) after opening a `.cs` file.
- **netcoredbg install/path.** The adapter needs the `netcoredbg` binary. Mitigation: document the install (`dotnet tool install -g netcoredbg` or release download) as a prerequisite; the adapter command path is verified at implementation.
- **easy-dotnet API drift.** Public function names may differ from the sketch. Mitigation: confirm against the docs; fall back to the `:Dotnet ...` Ex commands if the Lua API is unstable.
- **dap-ui auto-open noise.** The `before.launch`/`before.attach` listeners open the UI automatically; if intrusive, gate to manual `<leader>bu`. Low risk.
- **Independence.** Does not touch `lsp.lua`, `init.lua`, or any file the other four best-of-breed changes edit.

## Validation outline
1. Add `lua/plugins/dap.lua`; add easy-dotnet to `dotnet.lua`; add ftplugin maps; register the which-key group. `:Lazy sync`.
2. Open a `.cs` file: confirm exactly one `roslyn` LSP client is attached (easy-dotnet did not add a second).
3. In a runnable .NET project: set a breakpoint (`<F9>`), start (`<F5>`), confirm dap-ui opens with variables/call-stack and the breakpoint is hit.
4. Run `<localleader>tt` (test) and `<localleader>tr` (run) in `.cs` and `.fsharp`; confirm output.
5. Open a Haskell project with nvim-dap present: confirm a Haskell DAP configuration is discovered (or note its absence for a future change).
6. Confirm iron REPL maps (`<localleader>sl` etc.) and LSP maps (`gd`, `K`) still work.
7. `find . -name '*.lua' -print0 | xargs -0 luac -p`.
