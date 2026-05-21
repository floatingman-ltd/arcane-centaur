return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
      wk.add({
        { "<leader>gc", group = "Copilot" },
        { "<leader>os", group = "OpenSpec" },
      })
    end,
  },
}
