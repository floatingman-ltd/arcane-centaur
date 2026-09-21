return {
  "stevearc/conform.nvim",
  ft = { "lisp", "clojure", "scheme", "fennel", "fsharp", "janet", "lua", "terraform", "terraform-vars", "hcl" },
  opts = {
    formatters_by_ft = {
      lisp = { lsp_format = "prefer" },
      clojure = { lsp_format = "prefer" },
      scheme = { lsp_format = "prefer" },
      fennel = { lsp_format = "prefer" },
      fsharp = { lsp_format = "prefer" },
      janet = { lsp_format = "prefer" },
      lua = { "stylua" },
      -- terraform_fmt rather than lsp_format = "prefer", which is what the
      -- Lisp family and F# use. `terraform fmt` is defined by the project that
      -- defines the language, so deferring to terraform-ls would pick the less
      -- authoritative of two answers. (F# defers because Fantomas is reached
      -- *through* fsautocomplete -- there is no separate binary to call.)
      --
      -- hcl is a distinct filetype from terraform and takes conform's `hcl`
      -- formatter, not terraform_fmt: Neovim maps .tf to terraform and .hcl to
      -- hcl, and `terraform fmt` does not understand the latter.
      terraform = { "terraform_fmt" },
      ["terraform-vars"] = { "terraform_fmt" },
      hcl = { "hcl" },
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
