return {
  -- Iron.nvim: REPL interaction for F# Interactive (dotnet fsi)
  -- Usage: <localleader>sl  send line   <localleader>sc  send motion/selection
  --        <localleader>sp  send paragraph  <localleader>sf  send file
  --        <localleader>si  interrupt       <localleader>sq  quit REPL
  {
    "Vigemus/iron.nvim",
    ft = { "fsharp" },
    config = function()
      local iron = require("iron.core")
      iron.setup({
        config = {
          scratch_repl = true,
          repl_definition = {
            fsharp = {
              command = { "dotnet", "fsi", "--stdin" },
            },
          },
          -- Open REPL in a horizontal split at the bottom, 40% height
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
}
