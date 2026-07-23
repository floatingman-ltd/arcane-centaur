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
      {
        "<F5>",
        function()
          require("dap").continue()
        end,
        desc = "Debug: continue / start",
      },
      {
        "<S-F5>",
        function()
          require("dap").terminate()
        end,
        desc = "Debug: terminate",
      },
      {
        "<F9>",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Debug: toggle breakpoint",
      },
      {
        "<F10>",
        function()
          require("dap").step_over()
        end,
        desc = "Debug: step over",
      },
      {
        "<F11>",
        function()
          require("dap").step_into()
        end,
        desc = "Debug: step into",
      },
      {
        "<F12>",
        function()
          require("dap").step_out()
        end,
        desc = "Debug: step out",
      },
      -- <leader>b "Debug" mirrors: terminal-independent, so stepping never depends on the
      -- F-keys (which some terminals swallow). The F-keys above remain fully active.
      {
        "<leader>bb",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Debug: toggle breakpoint",
      },
      {
        "<leader>bc",
        function()
          require("dap").continue()
        end,
        desc = "Debug: continue / start",
      },
      {
        "<leader>bi",
        function()
          require("dap").step_into()
        end,
        desc = "Debug: step into",
      },
      {
        "<leader>bv",
        function()
          require("dap").step_over()
        end,
        desc = "Debug: step over",
      },
      {
        "<leader>bo",
        function()
          require("dap").step_out()
        end,
        desc = "Debug: step out",
      },
      {
        "<leader>bt",
        function()
          require("dap").terminate()
        end,
        desc = "Debug: terminate",
      },
      {
        "<leader>bu",
        function()
          require("dapui").toggle()
        end,
        desc = "Debug: toggle UI",
      },
      {
        "<leader>br",
        function()
          require("dap").repl.open()
        end,
        desc = "Debug: open REPL",
      },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- Put the dap-ui sidebar on the RIGHT. The default sidebar position is "left",
      -- which collides with nvim-tree (also left) — dap-ui then swallows the tree window
      -- into its frame. On the right it coexists: nvim-tree (left) | editor | dap-ui (right),
      -- console/repl along the bottom.
      dapui.setup({
        layouts = {
          {
            position = "right",
            size = 40,
            elements = {
              { id = "scopes", size = 0.25 },
              { id = "breakpoints", size = 0.25 },
              { id = "stacks", size = 0.25 },
              { id = "watches", size = 0.25 },
            },
          },
          {
            position = "bottom",
            size = 10,
            elements = {
              { id = "repl", size = 0.5 },
              { id = "console", size = 0.5 },
            },
          },
        },
      })

      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end
    end,
  },
}
