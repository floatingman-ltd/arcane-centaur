return {
  {
    "habamax/vim-asciidoctor",
    ft = { "asciidoctor" },
    init = function()
      vim.filetype.add({
        extension = {
          adoc       = "asciidoctor",
          asciidoc   = "asciidoctor",
          asciidoctor = "asciidoctor",
        },
      })
      -- Docker ftplugin owns conversion — disable plugin's compile commands.
      vim.g.asciidoctor_extensions = {}
      vim.g.asciidoctor_folding = 1
      vim.g.asciidoctor_fold_options = 1
      vim.g.asciidoctor_fenced_languages = { "lua", "bash", "python", "clojure", "fsharp", "haskell" }
      -- Keep markup visible while editing; markview handles rendered view when toggled.
      vim.g.asciidoctor_syntax_conceal = 0
    end,
  },
  {
    "OXY2DEV/markview.nvim",
    ft = { "asciidoctor" },
    opts = {
      preview = {
        enable = false,
        filetypes = { "asciidoctor" },
        ignore_buftypes = { "nofile" },
      },
    },
  },
}
