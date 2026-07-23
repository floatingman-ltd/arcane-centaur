return {
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
    keys = {
      { "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "Todo: list in Trouble" },
      { "<leader>xT", "<cmd>TodoFzfLua<cr>", desc = "Todo: list in fzf-lua" },
    },
  },
}
