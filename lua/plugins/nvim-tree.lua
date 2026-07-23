return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
  },
  config = function()
    require("nvim-tree").setup({
      sort = {
        sorter = "case_sensitive",
      },
      view = {
        width = 30,
      },
      renderer = {
        group_empty = true,
        icons = {
          glyphs = vim.g.have_nerd_font and {} or {
            default = "·",
            symlink = "→",
            folder = {
              arrow_closed = "▸",
              arrow_open = "▾",
              default = "▸",
              open = "▾",
              empty = "▹",
              empty_open = "▿",
              symlink = "→",
              symlink_open = "→",
            },
            git = {
              unstaged = "✗",
              staged = "✓",
              unmerged = "⌥",
              renamed = "➜",
              untracked = "★",
              deleted = "⊖",
              ignored = "◌",
            },
          },
        },
      },
      filters = {
        dotfiles = true,
      },
    })

    -- Close tree/terminal when quitting would leave them as the only windows.
    -- Prevents nvim-tree expanding to full-width after the last editor window closes.
    vim.api.nvim_create_autocmd("QuitPre", {
      group = vim.api.nvim_create_augroup("ide_layout", { clear = true }),
      callback = function()
        local cur_win = vim.api.nvim_get_current_win()
        -- Collect non-float windows that will remain after this quit
        local remaining = {}
        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_get_config(win).relative == "" and win ~= cur_win then
            table.insert(remaining, win)
          end
        end
        -- If every remaining window is tree or terminal chrome, close them all
        if #remaining == 0 then
          return
        end
        for _, win in ipairs(remaining) do
          local buf = vim.api.nvim_win_get_buf(win)
          if vim.bo[buf].filetype ~= "NvimTree" and vim.bo[buf].buftype ~= "terminal" then
            return -- a real editor window will survive; do nothing
          end
        end
        for _, win in ipairs(remaining) do
          pcall(vim.api.nvim_win_close, win, false)
        end
      end,
    })
  end,
}
