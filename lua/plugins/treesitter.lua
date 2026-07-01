local lisp_fts = { "lisp", "clojure", "scheme", "fennel", "janet" }
local function is_lisp(lang)
  for _, ft in ipairs(lisp_fts) do
    if lang == ft then return true end
  end
  return false
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects", branch = "master" },
    },
    opts = {
      ensure_installed = {
        "lisp", "clojure", "scheme", "lua", "fsharp", "vim",
        "markdown", "markdown_inline", "plantuml", "http", "c_sharp",
        "haskell",
      },
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          disable = is_lisp,
          keymaps = {
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",
            ["ac"] = "@class.outer",
            ["ic"] = "@class.inner",
            ["aa"] = "@parameter.outer",
            ["ia"] = "@parameter.inner",
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          disable = is_lisp,
          goto_next_start = {
            ["]f"] = "@function.outer",
          },
          goto_next_end = {
            ["]F"] = "@function.outer",
          },
          goto_previous_start = {
            ["[f"] = "@function.outer",
          },
          goto_previous_end = {
            ["[F"] = "@function.outer",
          },
        },
      },
    },
  },
}
