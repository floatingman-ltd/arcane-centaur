return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add({
        { "<leader>gc", group = "Claude" },
        { "<leader>os", group = "OpenSpec" },
        { "<leader>x", group = "Trouble" },
        { "<leader>b", group = "Debug" },
      })
    end,
  },
}
