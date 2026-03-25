return {
  {
    "rest-nvim/rest.nvim",
    ft = { "http" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-lua/nvim-nio",
      "j-hui/fidget.nvim",
    },
    rocks = { "mimetypes", "xml2lua" },
  },
}
