return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "tokyonight",
        globalstatus = true,
        icons_enabled = true,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          "branch",
          {
            "diff",
            symbols = { added = " ", modified = " ", removed = " " },
            -- Pull counts from gitsigns so they reflect unsaved buffer changes live;
            -- lualine's built-in git diff only sees saved/committed changes.
            source = function()
              local gs = vim.b.gitsigns_status_dict
              if gs then
                return { added = gs.added, modified = gs.changed, removed = gs.removed }
              end
            end,
          },
          -- nvim_diagnostic reads the unified vim.diagnostic API (all producers). The older
          -- nvim_lsp source filters by a 'vim.lsp' namespace prefix that no longer matches on
          -- Neovim 0.12, so LSP diagnostics never appeared in the status line.
          { "diagnostics", sources = { "nvim_diagnostic" } },
        },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
  },
}
