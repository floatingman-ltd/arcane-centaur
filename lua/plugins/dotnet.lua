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
              -- Plain `dotnet fsi` — interactive F# Interactive. (`--stdin` is NOT a valid
              -- fsi option; it errored FS0243 and the REPL exited immediately on open.)
              -- Reminder: F# Interactive evaluates a submission only after `;;`.
              command = { "dotnet", "fsi" },
            },
            cs = {
              -- `--useTerminalPaletteTheme`: csharprepl defaults to the truecolor
              -- VisualStudio_Dark syntax theme, which renders low-contrast/invisible in
              -- terminals that don't match it (the "blank REPL" symptom). This flag makes
              -- it use the terminal's own 16-colour palette, so output is visible.
              command = { "csharprepl", "--useTerminalPaletteTheme" },
            },
          },
          -- Bottom *split* (not a float). `iron.view.bottom()` opens a floating window,
          -- which overlays the code, isn't reached by window motions (needs :IronFocus),
          -- and generally confuses REPL interaction. A split behaves like a normal window
          -- (reach it with <C-j>/<C-w>j, no overlay).
          repl_open_cmd = require("iron.view").split.botright(15),
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
