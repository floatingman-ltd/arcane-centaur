return {
  {
    "mistweaverco/kulala.nvim",
    ft = { "http" },
    opts = {
      -- vim.ui.select avoids requiring a standalone fzf binary on PATH
      -- (fzf-lua is a Neovim plugin, not the system fzf executable).
      display_mode = "vim_ui_select",
    },
  },
}
