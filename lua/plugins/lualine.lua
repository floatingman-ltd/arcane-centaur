local term = require("config.terminal")

-- Repaint cadence. Every timer-driven repaint is terminal output that has to
-- cross the link, so over a remote session the 1000 ms default produces steady
-- background traffic and visible flicker while the buffer sits idle. Note this
-- governs *idle* repaints only -- the event list below already refreshes on
-- cursor movement and mode changes, which is what drives repaints while you are
-- actually editing.
local interval = term.is_remote and 5000 or 1000

return {
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "tokyonight",
        globalstatus = true,
        icons_enabled = true,
        refresh = {
          statusline = interval,
          tabline = interval,
          winbar = interval,
        },
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = {
          "branch",
          {
            "diff",
            symbols = { added = " ", modified = " ", removed = " " },
            -- Pull counts from gitsigns so they reflect unsaved buffer changes live;
            -- lualine's built-in git diff only sees saved/committed changes.
            source = function()
              local gs = vim.b.gitsigns_status_dict
              if gs then
                return { added = gs.added, modified = gs.changed, removed = gs.removed }
              end
            end,
          },
          -- nvim_diagnostic reads the unified vim.diagnostic API (all producers). The older
          -- nvim_lsp source filters by a 'vim.lsp' namespace prefix that no longer matches on
          -- Neovim 0.12, so LSP diagnostics never appeared in the status line.
          { "diagnostics", sources = { "nvim_diagnostic" } },
        },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    },
    config = function(_, opts)
      require("lualine").setup(opts)

      -- Refresh on state that arrives asynchronously, i.e. after the last
      -- CursorMoved. The diff component above sources hunk counts from
      -- gitsigns and diagnostics reads vim.diagnostic; neither event is in
      -- lualine's default `refresh.events`, so without these the counts wait
      -- for the repaint timer and can sit stale for its full duration -- five
      -- seconds on a remote session, which is exactly when someone is reading
      -- the statusline rather than typing.
      --
      -- These are separate autocommands rather than `refresh.events` entries,
      -- and that is not a style choice. lualine builds that list with
      -- string.format("autocmd %s %s %s %s", group, events, pattern, cmd), so
      -- an entry containing a space -- "User GitSignsUpdate" -- splits the
      -- event list and turns everything after it into the pattern. The result
      -- registers every real event against the pattern "GitSignsUpdate"
      -- instead of "*", which silently stops the statusline refreshing on
      -- cursor movement at all. Confirmed by inspecting the registered
      -- autocommands, not inferred.
      local group = vim.api.nvim_create_augroup("LualineAsyncRefresh", { clear = true })
      vim.api.nvim_create_autocmd("User", {
        group = group,
        pattern = "GitSignsUpdate",
        desc = "Refresh lualine when gitsigns publishes new hunk counts",
        callback = function()
          require("lualine").refresh()
        end,
      })
      vim.api.nvim_create_autocmd("DiagnosticChanged", {
        group = group,
        desc = "Refresh lualine when diagnostics change",
        callback = function()
          require("lualine").refresh()
        end,
      })
    end,
  },
}
