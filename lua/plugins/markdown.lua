vim.g.mkdp_preview_options = {
  plantuml_server = "http://localhost:8080",
}

local term = require("config.terminal")

if term.is_wsl then
  if vim.fn.executable("wslview") == 1 then
    vim.g.mkdp_browser = "wslview"
  else
    -- WSL fallback: use the Windows explorer shim when wslview is unavailable.
    vim.g.mkdp_browser = "explorer.exe"
  end
end

return {
  {
    "iamcco/markdown-preview.nvim",
    ft = { "markdown" },
    build = "cd app && npm install",
    cond = function() return not require("config.terminal").is_console end,
  },
  {
    "ellisonleao/glow.nvim",
    ft = { "markdown" },
    cond = function() return require("config.terminal").is_console end,
    opts = {
      style = "dark",
      border = "rounded",
      width = 120,
      height = 80,
      pager = false,
    },
    config = function(_, opts)
      require("glow").setup(opts)
    end,
  },
}
