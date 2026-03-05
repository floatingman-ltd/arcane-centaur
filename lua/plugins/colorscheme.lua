return {
  "maxmx03/solarized.nvim",
  priority = 1000,
  config = function()
    vim.o.background = "light"
    require("solarized").setup()
    vim.cmd("colorscheme solarized")
  end,
}
