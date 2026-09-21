-- .NET tooling: C# LSP via roslyn.nvim, solution/test tooling via easy-dotnet.
-- The F# and C# REPLs live in lua/plugins/iron.lua, which iron.nvim shares with
-- Terraform.
--
-- Prerequisites:
--   dotnet tool install -g csharpier    (C# formatter)
--   Roslyn server binary on $PATH       (see docs/modules/ROOT/pages/languages/dotnet.adoc)
return {
  -- roslyn.nvim: official Microsoft Roslyn C# language server.
  -- The server binary must be installed separately — see docs/modules/ROOT/pages/languages/dotnet.adoc.
  -- LSP keymaps (gd, K, gr, etc.) are attached via vim.lsp.config in lua/config/lsp.lua.
  {
    "seblyng/roslyn.nvim",
    ft = { "cs" },
    opts = {},
  },

  -- easy-dotnet: solution management, test runner, and DAP auto-registration.
  -- lsp.enabled=false: roslyn.nvim is the sole C# LSP; easy-dotnet must not add a second server.
  -- auto_register_dap=true (default): registers netcoredbg once nvim-dap is present.
  {
    "GustavEikaas/easy-dotnet.nvim",
    ft = { "cs", "fsharp" },
    dependencies = { "nvim-lua/plenary.nvim", "ibhagwan/fzf-lua" },
    opts = {
      picker = "fzf",
      lsp = {
        enabled = false,
      },
      -- Keep the run/test output terminal open after the process exits (default
      -- auto_hide=true closes it the instant a run finishes with exit code 0, so
      -- you never see the output). Dismiss it manually with `q`.
      managed_terminal = {
        auto_hide = false,
      },
    },
  },
}
