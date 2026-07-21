return {
  {
    "folke/trouble.nvim",
    -- Track `main`, not the latest release: the Neovim 0.12 decoration-provider
    -- fixes (upstream #656/#661 — `on_line` → `on_range`) are on `main` only;
    -- the newest tag (v3.7.1) still calls the removed `TSHighlighter._on_line`
    -- and crashes when the panel renders. Revert to `version = "*"` once a
    -- release ≥ 3.7.2 ships the fix. lazy-lock.json pins the exact commit.
    branch = "main",
    cmd = "Trouble",
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",                        desc = "Trouble: project diagnostics" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",           desc = "Trouble: buffer diagnostics" },
      { "<leader>xs", "<cmd>Trouble symbols toggle focus=false<cr>",                desc = "Trouble: symbols" },
      { "<leader>xr", "<cmd>Trouble lsp toggle focus=false win.position=right<cr>", desc = "Trouble: LSP references/defs" },
      { "<leader>xl", "<cmd>Trouble loclist toggle<cr>",                            desc = "Trouble: location list" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>",                             desc = "Trouble: quickfix list" },
    },
  },
}
