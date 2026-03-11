return {
  -- Git integration: status, blame, diff, log, push/pull
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G" },
    keys = {
      { "<leader>gs", "<cmd>Git<CR>",       desc = "Git status" },
      { "<leader>gb", "<cmd>Git blame<CR>", desc = "Git blame" },
      { "<leader>gl", "<cmd>Git log<CR>",   desc = "Git log" },
      { "<leader>gd", "<cmd>Git diff<CR>",  desc = "Git diff (unstaged)" },
      { "<leader>gp", "<cmd>Git push<CR>",  desc = "Git push" },
    },
  },

  -- Git signs in the gutter: added / changed / removed lines
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add          = { text = "▎" },
        change       = { text = "▎" },
        delete       = { text = "▁" },
        topdelete    = { text = "▔" },
        changedelete = { text = "▎" },
        untracked    = { text = "▎" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, noremap = true, silent = true, desc = desc })
        end

        -- Hunk navigation (expr = true so return values are interpreted as key sequences)
        vim.keymap.set("n", "]h", function()
          if vim.wo.diff then return "]h" end
          vim.schedule(gs.next_hunk)
          return "<Ignore>"
        end, { buffer = bufnr, noremap = true, silent = true, expr = true, desc = "Next hunk" })

        vim.keymap.set("n", "[h", function()
          if vim.wo.diff then return "[h" end
          vim.schedule(gs.prev_hunk)
          return "<Ignore>"
        end, { buffer = bufnr, noremap = true, silent = true, expr = true, desc = "Previous hunk" })

        -- Hunk actions
        map({ "n", "v" }, "<leader>hs", gs.stage_hunk,        "Stage hunk")
        map({ "n", "v" }, "<leader>hr", gs.reset_hunk,        "Reset hunk")
        map("n",          "<leader>hS", gs.stage_buffer,      "Stage buffer")
        map("n",          "<leader>hR", gs.reset_buffer,      "Reset buffer")
        map("n",          "<leader>hu", gs.undo_stage_hunk,   "Undo stage hunk")
        map("n",          "<leader>hp", gs.preview_hunk,      "Preview hunk")
        map("n",          "<leader>hb", function() gs.blame_line({ full = true }) end, "Blame line")
        map("n",          "<leader>hd", gs.diffthis,          "Diff this (unstaged)")
        map("n",          "<leader>hD", function() gs.diffthis("~") end, "Diff this (staged)")

        -- Text object: select hunk with <leader>ih in visual / operator mode
        map({ "o", "x" }, "<leader>ih", ":<C-U>Gitsigns select_hunk<CR>", "Select hunk (text object)")
      end,
    },
  },
}
