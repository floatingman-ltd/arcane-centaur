return {
  {
    "mistweaverco/kulala.nvim",
    ft = { "http" },
    opts = {
      -- Use Neovim's built-in vim.ui.select instead of the standalone fzf binary.
      -- The fzf-lua plugin (ibhagwan/fzf-lua) provides the fuzzy-finder UI but
      -- does not place an `fzf` executable on PATH, so the default "fzf"
      -- display_mode would error with "'fzf' is not a valid executable".
      display_mode = "vim_ui_select",
    },
  },
}
