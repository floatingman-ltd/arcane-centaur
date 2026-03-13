return {
  -- Conjure: interactive REPL-driven development for Lisp, Clojure, Scheme
  {
    "Olical/conjure",
    ft = { "lisp", "clojure", "scheme", "fennel" },
    dependencies = {
      "PaterJason/cmp-conjure",
    },
    init = function()
      -- These globals must be set before Conjure loads so it reads the correct
      -- values at initialisation time.

      -- Prefix for all Conjure mappings
      vim.g["conjure#mapping#prefix"] = "<localleader>"

      -- Common Lisp Swank connection (default port used by swank:create-server)
      vim.g["conjure#client#common_lisp#swank#connection#default_host"] = "127.0.0.1"
      vim.g["conjure#client#common_lisp#swank#connection#default_port"] = 4005

      -- Enable the HUD floating popup so evaluation results are visible even
      -- when the log buffer is not open.  Must be set here (init) rather than
      -- config so the flag is in place before Conjure's own startup code runs.
      vim.g["conjure#log#hud#enabled"] = true
      -- Keep the HUD visible long enough for async output to arrive (ms).
      vim.g["conjure#log#hud#passive_close_delay"] = 5000

      -- When the log buffer is already open, scroll it to the latest result
      -- automatically so evaluation output is never off-screen.
      vim.g["conjure#log#jump_to_latest#enabled"] = true
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
