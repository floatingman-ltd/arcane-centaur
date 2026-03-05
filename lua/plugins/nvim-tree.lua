return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
  },
  config = function()
    require("nvim-tree").setup {
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
            default  = "·",
            symlink  = "→",
            folder   = {
              arrow_closed = "▸",
              arrow_open   = "▾",
              default      = "▸",
              open         = "▾",
              empty        = "▹",
              empty_open   = "▿",
              symlink      = "→",
              symlink_open = "→",
            },
            git = {
              unstaged  = "✗",
              staged    = "✓",
              unmerged  = "⌥",
              renamed   = "➜",
              untracked = "★",
              deleted   = "⊖",
              ignored   = "◌",
            },
          },
        },
      },
      filters = {
        dotfiles = true,
      },
    }
  end,
}
