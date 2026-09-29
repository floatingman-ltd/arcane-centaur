return {
  {
    -- github.com/mistweaverco/kulala.nvim returns 404 (checked 2026-09-29) and
    -- every fetch fails. Load a copy of the last clone (commit dcad056) from
    -- outside lazy's root, so lazy treats it as local and runs no git on it.
    -- Restore "mistweaverco/kulala.nvim" once the repo is back or a trusted
    -- mirror carries that commit.
    dir = vim.fn.stdpath("data") .. "/vendor/kulala.nvim",
    name = "kulala.nvim",
    ft = { "http" },
    -- Keymaps are buffer-local <localleader> maps in after/ftplugin/http.lua.
    opts = {},
  },
}
