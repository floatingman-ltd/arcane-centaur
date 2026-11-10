return {
  {
    "habamax/vim-asciidoctor",
    ft = { "asciidoctor" },
    init = function()
      vim.filetype.add({
        extension = {
          adoc = "asciidoctor",
          asciidoc = "asciidoctor",
          asciidoctor = "asciidoctor",
        },
      })
      -- No asciidoctor extensions (-r) passed to the plugin's compile commands. The commands
      -- still exist but need asciidoctor on PATH; preview goes through the Docker ftplugin.
      vim.g.asciidoctor_extensions = {}
      vim.g.asciidoctor_folding = 1
      vim.g.asciidoctor_fold_options = 1
      -- Only languages that ship a Vim `syntax/<lang>.vim` — otherwise vim-asciidoctor
      -- errors with E484 on every .adoc open. `fsharp` has no vim syntax file (excluded).
      vim.g.asciidoctor_fenced_languages = { "lua", "bash", "python", "clojure", "haskell" }
      -- Keep markup visible while editing (no in-buffer render; markview is deferred below).
      vim.g.asciidoctor_syntax_conceal = 0
    end,
  },
  -- markview.nvim AsciiDoc rendering deferred: requires cathaysia/tree-sitter-asciidoc,
  -- which is not in nvim-treesitter master. Re-enable when the grammar is available.
}
