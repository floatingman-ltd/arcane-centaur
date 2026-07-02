return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      { "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
    },
    keys = {
      { "<F5>",       function() require("dap").continue() end,          desc = "Debug: continue / start" },
      { "<S-F5>",     function() require("dap").terminate() end,         desc = "Debug: terminate" },
      { "<F9>",       function() require("dap").toggle_breakpoint() end, desc = "Debug: toggle breakpoint" },
      { "<F10>",      function() require("dap").step_over() end,         desc = "Debug: step over" },
      { "<F11>",      function() require("dap").step_into() end,         desc = "Debug: step into" },
      { "<F12>",      function() require("dap").step_out() end,          desc = "Debug: step out" },
      { "<leader>bb", function() require("dap").toggle_breakpoint() end, desc = "Debug: toggle breakpoint" },
      { "<leader>bc", function() require("dap").continue() end,          desc = "Debug: continue" },
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
