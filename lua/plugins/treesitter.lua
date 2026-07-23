return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    -- nvim-treesitter (master) is configured via `nvim-treesitter.configs`.
    -- lazy's default `opts` path calls `require("nvim-treesitter").setup(opts)`,
    -- but that entry point takes NO arguments and silently discards opts — so
    -- highlight/indent/ensure_installed never apply. Route the opts to the real
    -- setup explicitly.
    --
    -- NOTE: text objects (nvim-treesitter-textobjects) were removed — the master
    -- branch's query path crashes on Neovim 0.12 (tsrange.lua calls a removed
    -- API), so `vaf`/`]f`/etc. silently no-op. Highlight is unaffected because it
    -- runs through Neovim's core treesitter, not that path.
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
    opts = {
      ensure_installed = {
        -- Common Lisp's parser is "commonlisp" (not "lisp"); Janet's is
        -- "janet_simple" (there is no "janet" parser — it maps to the janet
        -- filetype); plantuml has no tree-sitter parser.
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
    },
  },
}
