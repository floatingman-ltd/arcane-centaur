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
    },
  },
}
