## 1. Verify upstream behavior (do first)

- [x] 1.1 Read the easy-dotnet README: `lsp = { enabled = false }` disables Roslyn/LSP management; `picker = "fzf"` selects fzf-lua; API: `dotnet.run()`, `dotnet.test()`, `dotnet.build()`, `dotnet.debug()`.
- [x] 1.2 netcoredbg install: `dotnet tool install -g netcoredbg`; `auto_register_dap = true` (default) registers the adapter automatically once nvim-dap is present — no manual adapter config needed.
- [x] 1.3 haskell-tools DAP auto-discovery: nvim-dap presence alone is sufficient; haskell-tools.nvim auto-discovers configs with no extra option.

## 2. Debug substrate

- [x] 2.1 Created `lua/plugins/dap.lua` with `mfussenegger/nvim-dap`, `rcarriga/nvim-dap-ui` (+ `nvim-neotest/nvim-nio`).
- [x] 2.2 Set up dap-ui, launch/attach/exit listeners to auto-open/close UI. netcoredbg adapter auto-registered by easy-dotnet (auto_register_dap=true).
- [x] 2.3 Defined debug keymaps: `<F5>`/`<S-F5>`/`<F9>`/`<F10>`/`<F11>`/`<F12>` and `<leader>bb`/`<leader>bc`/`<leader>bu`/`<leader>br`. No collision with `<leader>d` (cut-to-clipboard) or iron's `<localleader>s*`.

## 3. easy-dotnet

- [x] 3.1 Added `GustavEikaas/easy-dotnet.nvim` to `lua/plugins/dotnet.lua` (`ft = { "cs", "fsharp" }`, deps `plenary` + `fzf-lua`), `picker = "fzf"`, `lsp = { enabled = false }`.
- [x] 3.2 Added `<localleader>tt`/`tr`/`tb` to `after/ftplugin/cs.lua` and `after/ftplugin/fsharp.lua`.
- [x] 3.3 iron.nvim and roslyn.nvim specs unchanged.

## 4. which-key

- [x] 4.1 Appended `{ "<leader>b", group = "Debug" }` to `lua/plugins/which-key.lua`'s `wk.add` list (alongside existing `<leader>x` Trouble group from change 06).

## 5. Validation

- [ ] 5.1 `:Lazy sync` — nvim-dap, nvim-dap-ui, nvim-nio, easy-dotnet install cleanly.
- [ ] 5.2 Open a `.cs` file: `:lua =vim.lsp.get_clients({ name = "roslyn" })` shows exactly one client.
- [ ] 5.3 In a runnable .NET project: `<F9>` set breakpoint, `<F5>` start; confirm dap-ui opens and breakpoint is hit; `<F10>`/`<F11>`/`<F12>` step.
- [ ] 5.4 `<localleader>tt` runs tests; `<localleader>tr` runs the project — both in `.cs` and `.fsharp`.
- [ ] 5.5 Open a Haskell project: confirm haskell-tools DAP config is discoverable.
- [ ] 5.6 Confirm iron REPL maps and LSP maps (`gd`, `K`, `gr`) still work.
- [x] 5.7 `find . -name '*.lua' -print0 | xargs -0 luac -p` — passes clean.

## 6. Documentation

- [x] 6.1 Updated `docs/modules/ROOT/pages/languages/dotnet.adoc` with Debugging section (netcoredbg prereq, F-key + `<leader>b` maps) and Testing section (easy-dotnet, `<localleader>t*`).
- [x] 6.2 Updated `docs/modules/ROOT/pages/languages/dotnet-cheatsheet.adoc` with debug function keys, `<leader>b*`, and `<localleader>t*` maps.
- [x] 6.3 Added Debugging note to `docs/modules/ROOT/pages/languages/haskell.adoc`.
- [x] 6.4 Updated `docs/modules/ROOT/pages/other/architecture.adoc` (Debugging section + easy-dotnet in .NET table) and `CLAUDE.md` (nvim-dap + easy-dotnet noted).
