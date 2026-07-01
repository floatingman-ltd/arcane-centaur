return {
  {
    "folke/trouble.nvim",
    version = "*",
    cmd = "Trouble",
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",                        desc = "Trouble: project diagnostics" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",           desc = "Trouble: buffer diagnostics" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>",                desc = "Trouble: symbols" },
      { "<leader>xr", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "Trouble: LSP references/defs" },
      { "<leader>xl", "<cmd>Trouble loclist toggle<cr>",                            desc = "Trouble: location list" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>",                             desc = "Trouble: quickfix list" },
    },
  },
}
