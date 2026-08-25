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
    -- Use the plugin's own installer (downloads a prebuilt binary) instead of
    -- `cd app && npm install`, which rewrites app/package-lock.json + yarn.lock and
    -- leaves the plugin's git tree dirty so `:Lazy sync` fails (same class as the
    -- bracey.vim issue).
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
    cond = function()
      return not require("config.terminal").is_console
    end,
  },
  -- In-editor markdown rendering. Replaced glow.nvim, whose word-wrap orphans
  -- single words onto their own lines at essentially any width with no
  -- configuration that avoids it (openspec/changes/archive/*-replace-glow-renderer).
  -- Rendering in a real buffer hands wrapping to Neovim, which does it correctly
  -- and reflows on resize -- something pre-rendered output can never do.
  -- The shared float lives in lua/config/cheatsheet.lua (open_float).
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      -- Render everywhere, including normal buffers, not just when a float is open.
      render_modes = { "n", "c", "i" },
      -- The float is a scratch buffer; allow rendering regardless of buftype/file.
      file_types = { "markdown" },
    },
  },
}
