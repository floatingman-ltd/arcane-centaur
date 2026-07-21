-- .NET REPL (F# and C#) via iron.nvim.
-- C# LSP is provided by roslyn.nvim (official Microsoft Roslyn language server).
--
-- Prerequisites:
--   dotnet tool install -g csharpier    (C# formatter)
--   dotnet tool install -g csharprepl   (C# REPL)
--   Roslyn server binary on $PATH       (see docs/guides/dotnet.md)
return {
  -- iron.nvim: REPL interaction for F# Interactive (dotnet fsi) and C# (csharprepl)
  -- Usage: <localleader>sl  send line   <localleader>sc  send motion/selection
  --        <localleader>sp  send paragraph  <localleader>sf  send file
  --        <localleader>si  interrupt       <localleader>sq  quit REPL
  {
    "Vigemus/iron.nvim",
    ft = { "fsharp", "cs" },
    config = function()
      local iron = require("iron.core")
      iron.setup({
        config = {
          scratch_repl = true,
          repl_definition = {
            fsharp = {
              command = { "dotnet", "fsi", "--stdin" },
            },
            cs = {
              command = { "csharprepl" },
            },
          },
          repl_open_cmd = require("iron.view").bottom(40),
        },
        keymaps = {
          send_motion    = "<localleader>sc",
          visual_send    = "<localleader>sc",
          send_file      = "<localleader>sf",
          send_line      = "<localleader>sl",
          send_paragraph = "<localleader>sp",
          cr             = "<localleader>s<cr>",
          interrupt      = "<localleader>si",
          exit           = "<localleader>sq",
          clear          = "<localleader>cl",
        },
        highlight = { italic = true },
        ignore_blank_lines = true,
      })
    end,
  },

  -- roslyn.nvim: official Microsoft Roslyn C# language server.
  -- The server binary must be installed separately — see docs/guides/dotnet.md.
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
