local LISP_FILETYPES = { "lisp", "clojure", "scheme", "fennel", "janet" }

-- Filetypes with an installed parser that get treesitter highlight + indent.
-- markdown is handled in after/ftplugin/markdown.lua instead of here (the
-- master-branch nil-range crash on its injection parser does not reproduce
-- on main, but it stays separate so preview tooling can override it easily).
local HIGHLIGHT_FILETYPES = {
  "lisp",
  "clojure",
  "scheme",
  "fennel",
  "janet",
  "lua",
  "fsharp",
  "vim",
  "http",
  "cs",
  "haskell",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false, -- main branch explicitly does not support lazy-loading
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")
      ts.setup()
      -- Common Lisp's parser is "commonlisp" (not "lisp"); Janet's is
      -- "janet_simple" (there is no "janet" parser — it maps to the janet
      -- filetype); plantuml has no tree-sitter parser. nvim-treesitter
      -- registers the filetype<->language mapping for these automatically.
      ts.install({
        "commonlisp",
        "clojure",
        "scheme",
        "fennel",
        "janet_simple",
        "lua",
        "fsharp",
        "vim",
        "markdown",
        "markdown_inline",
        "http",
        "c_sharp",
        "haskell",
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = HIGHLIGHT_FILETYPES,
        callback = function()
          vim.treesitter.start()
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    lazy = false,
    init = function()
      -- Disable Neovim's built-in ftplugin text-object mappings to avoid
      -- conflicts with the ones set up below.
      vim.g.no_plugin_maps = true
    end,
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = { lookahead = true },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")

      local function select_textobject(query)
        return function()
          select.select_textobject(query, "textobjects")
        end
      end

      local function goto_next_start(query)
        return function()
          move.goto_next_start(query, "textobjects")
        end
      end

      local function goto_previous_start(query)
        return function()
          move.goto_previous_start(query, "textobjects")
        end
      end

      local function goto_next_end(query)
        return function()
          move.goto_next_end(query, "textobjects")
        end
      end

      local function goto_previous_end(query)
        return function()
          move.goto_previous_end(query, "textobjects")
        end
      end

      -- vim-sexp remains authoritative for structural text objects in Lisp
      -- buffers (see lua/plugins/lisp.lua) — skip attaching treesitter's
      -- af/if/ac/ic/aa/ia and ]f/[f/]F/[F there entirely.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "*",
        callback = function(args)
          if vim.tbl_contains(LISP_FILETYPES, vim.bo[args.buf].filetype) then
            return
          end
          local opts = { buffer = args.buf }
          vim.keymap.set({ "x", "o" }, "af", select_textobject("@function.outer"), opts)
          vim.keymap.set({ "x", "o" }, "if", select_textobject("@function.inner"), opts)
          vim.keymap.set({ "x", "o" }, "ac", select_textobject("@class.outer"), opts)
          vim.keymap.set({ "x", "o" }, "ic", select_textobject("@class.inner"), opts)
          vim.keymap.set({ "x", "o" }, "aa", select_textobject("@parameter.outer"), opts)
          vim.keymap.set({ "x", "o" }, "ia", select_textobject("@parameter.inner"), opts)

          -- ]c/[c intentionally NOT mapped — that's diff-mode change navigation.
          vim.keymap.set({ "n", "x", "o" }, "]f", goto_next_start("@function.outer"), opts)
          vim.keymap.set({ "n", "x", "o" }, "[f", goto_previous_start("@function.outer"), opts)
          vim.keymap.set({ "n", "x", "o" }, "]F", goto_next_end("@function.outer"), opts)
          vim.keymap.set({ "n", "x", "o" }, "[F", goto_previous_end("@function.outer"), opts)
        end,
      })
    end,
  },
}
