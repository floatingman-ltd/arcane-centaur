local skip_textobjects = { "lisp", "clojure", "scheme", "fennel", "janet", "markdown", "markdown_inline" }
local function no_textobjects(lang)
  for _, ft in ipairs(skip_textobjects) do
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
    -- nvim-treesitter (master) is configured via `nvim-treesitter.configs`.
    -- lazy's default `opts` path calls `require("nvim-treesitter").setup(opts)`,
    -- but that entry point takes NO arguments and silently discards opts — so
    -- highlight/indent/textobjects/ensure_installed never apply. Route the opts
    -- to the real setup explicitly.
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
    opts = {
      ensure_installed = {
        -- Common Lisp's parser is named "commonlisp" (not "lisp"); plantuml
        -- has no tree-sitter parser (it uses the plantuml-syntax vim plugin).
        "commonlisp", "clojure", "scheme", "lua", "fsharp", "vim",
        "markdown", "markdown_inline", "http", "c_sharp",
        "haskell",
      },
      highlight = {
        enable = true,
        -- Markdown TS highlight triggers a "nil range"/languagetree error
        -- (hotfix: treesitter-markdown-highlight-disable). Keep it off here;
        -- after/ftplugin/markdown.lua also calls vim.treesitter.stop() as backup.
        disable = { "markdown", "markdown_inline" },
      },
      indent = {
        enable = true,
        disable = { "markdown", "markdown_inline" },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          disable = no_textobjects,
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
          disable = no_textobjects,
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
