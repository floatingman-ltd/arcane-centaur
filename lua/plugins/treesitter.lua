return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = {"commonlisp", "clojure", "scheme", "lua", "fsharp", "vim", "markdown", "markdown_inline", "plantuml", "http"},
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
    },
  },
}
