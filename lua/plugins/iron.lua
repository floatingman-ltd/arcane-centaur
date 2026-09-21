-- iron.nvim: REPL interaction for the languages whose REPL is a plain
-- subprocess rather than a network connection (Conjure owns the Lisp family,
-- which speaks to a running image over a socket).
--
-- Lived in lua/plugins/dotnet.lua until Terraform joined it. Extracted rather
-- than extended in place: iron takes a single `iron.setup()` and lazy.nvim does
-- not merge two `config` functions for one plugin, so a second spec elsewhere
-- would silently discard one language's repl_definition.
--
-- Usage: <localleader>sl  send line   <localleader>sc  send motion/selection
--        <localleader>sp  send paragraph  <localleader>sf  send file
--        <localleader>si  interrupt       <localleader>sq  quit REPL
--
-- Prerequisites:
--   dotnet tool install -g csharprepl   (C# REPL)
--   terraform on $PATH                  (docker/terraform/terraform wrapper)
return {
  {
    "Vigemus/iron.nvim",
    ft = { "fsharp", "cs", "terraform" },
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
            terraform = {
              -- `terraform console` is a genuine REPL, which is why Terraform fits
              -- this convention rather than needing a new one. It is not a scratch
              -- buffer though: expressions evaluate against real state, and in an
              -- uninitialised directory it answers very little. Documented in the
              -- guide so the difference is not met by surprise.
              --
              -- Runs through the Docker wrapper like every other terraform
              -- invocation here, so the REPL starts a container that lives as long
              -- as the session.
              command = { "terraform", "console" },
            },
          },
          -- Bottom *split* (not a float). `iron.view.bottom()` opens a floating window,
          -- which overlays the code, isn't reached by window motions (needs :IronFocus),
          -- and generally confuses REPL interaction. A split behaves like a normal window
          -- (reach it with <C-j>/<C-w>j, no overlay).
          repl_open_cmd = require("iron.view").split.botright(15),
        },
        keymaps = {
          send_motion = "<localleader>sc",
          visual_send = "<localleader>sc",
          send_file = "<localleader>sf",
          send_line = "<localleader>sl",
          send_paragraph = "<localleader>sp",
          cr = "<localleader>s<cr>",
          interrupt = "<localleader>si",
          exit = "<localleader>sq",
          clear = "<localleader>cl",
        },
        highlight = { italic = true },
        ignore_blank_lines = true,
      })
    end,
  },
}
