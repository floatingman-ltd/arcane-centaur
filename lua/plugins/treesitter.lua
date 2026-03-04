return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = {"lisp", "clojure", "scheme", "lua", "fsharp", "vim"},
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
    },
  },
}
