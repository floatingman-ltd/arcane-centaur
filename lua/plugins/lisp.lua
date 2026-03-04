return {
  -- Conjure: interactive REPL-driven development for Lisp, Clojure, Scheme
  {
    "Olical/conjure",
    ft = { "lisp", "clojure", "scheme", "fennel" },
    dependencies = {
      "PaterJason/cmp-conjure",
    },
    config = function()
      -- Prefix for all Conjure mappings
      vim.g["conjure#mapping#prefix"] = "<localleader>"
    end,
  },

  -- Ergonomic keybindings for vim-sexp
  {
    "tpope/vim-sexp-mappings-for-regular-people",
    ft = { "lisp", "clojure", "scheme" },
    dependencies = {
      "guns/vim-sexp",
    },
  },

  -- Automatic parenthesis balancing via indentation
  {
    "gpanders/nvim-parinfer",
    ft = { "lisp", "clojure", "scheme", "fennel" },
  },

  -- Rainbow-colored parentheses for visual nesting
  {
    "HiPhish/rainbow-delimiters.nvim",
    ft = { "lisp", "clojure", "scheme", "fennel" },
    config = function()
      local rainbow_delimiters = require("rainbow-delimiters")
      -- Empty string key "" sets the default for all filetypes
      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow_delimiters.strategy["global"],
        },
        query = {
          [""] = "rainbow-delimiters",
        },
      }
    end,
  },
}
