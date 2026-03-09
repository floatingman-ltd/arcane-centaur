return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "saadparwaiz1/cmp_luasnip",
      "f3fora/cmp-spell",
    },
    config = function()
      local cmp = require("cmp")

      cmp.setup({
        snippet = {
          expand = function(args)
            require("luasnip").lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]     = cmp.mapping.scroll_docs(4),
          ["<M-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          -- Confirm with Enter; select = false so a highlighted entry is
          -- required (avoids accidentally inserting the first suggestion).
          ["<CR>"]      = cmp.mapping.confirm({ select = false }),
          -- Navigate the completion menu with j/k, matching screen movement.
          -- Falls back to inserting the character when the menu is closed.
          ["j"]         = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            else
              fallback()
            end
          end, { "i" }),
          ["k"]         = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { "i" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
          {
            name = "spell",
            keyword_length = 3,
            option = {
              keep_all_entries = false,
              -- Only surface spell suggestions when spell-checking is active
              -- for the current buffer (disabled for code filetypes via
              -- after/ftplugin/).
              enable_in_context = function()
                return vim.opt.spell:get()
              end,
            },
          },
        }),
      })

      -- '/' search: complete from buffer words
      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
      })

      -- ':' command line: paths then Ex commands
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources(
          { { name = "path" } },
          { { name = "cmdline" } }
        ),
      })
    end,
  },
}
