return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    dependencies = {
      "saghen/blink.compat",
      "f3fora/cmp-spell",
    },
    opts = {
      keymap = {
        preset = "none",
        ["<C-b>"]     = { "scroll_documentation_up",   "fallback" },
        ["<C-f>"]     = { "scroll_documentation_down", "fallback" },
        ["<M-Space>"] = { "show",         "fallback" },
        ["<C-e>"]     = { "hide",         "fallback" },
        ["<CR>"]      = { "accept",       "fallback" },
        ["<C-n>"]     = { "select_next",  "fallback" },
        ["<C-p>"]     = { "select_prev",  "fallback" },
      },
      completion = {
        list = {
          selection = { preselect = false, auto_insert = false },
        },
      },
      sources = {
        default = { "lsp", "buffer", "path", "snippets", "spell" },
        per_filetype = {
          lisp    = { "lsp", "buffer", "path", "snippets", "spell", "conjure" },
          clojure = { "lsp", "buffer", "path", "snippets", "spell", "conjure" },
          scheme  = { "lsp", "buffer", "path", "snippets", "spell", "conjure" },
          fennel  = { "lsp", "buffer", "path", "snippets", "spell", "conjure" },
          janet   = { "lsp", "buffer", "path", "snippets", "spell", "conjure" },
        },
        providers = {
          -- cmp-spell bridged via blink.compat; enabled only when spell is on,
          -- min_keyword_length=3 preserves the former keyword_length=3 guard.
          spell = {
            name = "spell",
            module = "blink.compat.source",
            score_offset = -3,
            enabled = function() return vim.opt.spell:get() end,
            min_keyword_length = 3,
            opts = { keep_all_entries = false },
          },
          -- cmp-conjure bridged via blink.compat; the plugin is declared in
          -- lua/plugins/lisp.lua so it loads alongside Conjure on lisp filetypes.
          conjure = {
            name = "conjure",
            module = "blink.compat.source",
          },
        },
      },
      cmdline = {
        enabled = true,
        sources = function()
          local t = vim.fn.getcmdtype()
          if t == "/" or t == "?" then return { "buffer" } end
          if t == ":" then return { "path", "cmdline" } end
          return {}
        end,
      },
    },
  },
}
