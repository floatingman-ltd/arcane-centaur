return {
  "stevearc/conform.nvim",
  ft = { "lisp", "clojure", "scheme", "fennel", "fsharp" },
  opts = {
    formatters_by_ft = {
      lisp    = { lsp_format = "prefer" },
      clojure = { lsp_format = "prefer" },
      scheme  = { lsp_format = "prefer" },
      fennel  = { lsp_format = "prefer" },
      fsharp  = { lsp_format = "prefer" },
    },
    format_on_save = {
      timeout_ms = 2000,
    },
  },
  keys = {
    {
      "<leader>f",
      function()
        require("conform").format({ async = true })
      end,
      mode = { "n", "v" },
      desc = "Format buffer (or selection)",
    },
  },
}
