return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
    },
    keys = {
      -- Function keys: the universal debugger idiom; keep them — they work on server
      -- terminals / SSH and anywhere the emulator doesn't grab them. (Some GUI terminals
      -- intercept <F11> for fullscreen, <F10> for a menu; use the <leader>b mirrors there.)
      { "<F5>",       function() require("dap").continue() end,          desc = "Debug: continue / start" },
      { "<S-F5>",     function() require("dap").terminate() end,         desc = "Debug: terminate" },
      { "<F9>",       function() require("dap").toggle_breakpoint() end, desc = "Debug: toggle breakpoint" },
      { "<F10>",      function() require("dap").step_over() end,         desc = "Debug: step over" },
      { "<F11>",      function() require("dap").step_into() end,         desc = "Debug: step into" },
      { "<F12>",      function() require("dap").step_out() end,          desc = "Debug: step out" },
      -- <leader>b "Debug" mirrors: terminal-independent, so stepping never depends on the
      -- F-keys (which some terminals swallow). The F-keys above remain fully active.
      { "<leader>bb", function() require("dap").toggle_breakpoint() end, desc = "Debug: toggle breakpoint" },
      { "<leader>bc", function() require("dap").continue() end,          desc = "Debug: continue / start" },
      { "<leader>bi", function() require("dap").step_into() end,         desc = "Debug: step into" },
      { "<leader>bv", function() require("dap").step_over() end,         desc = "Debug: step over" },
      { "<leader>bo", function() require("dap").step_out() end,          desc = "Debug: step out" },
      { "<leader>bt", function() require("dap").terminate() end,         desc = "Debug: terminate" },
      { "<leader>bu", function() require("dapui").toggle() end,          desc = "Debug: toggle UI" },
      { "<leader>br", function() require("dap").repl.open() end,         desc = "Debug: open REPL" },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      dapui.setup()

      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"]     = function() dapui.close() end
    end,
  },
}
