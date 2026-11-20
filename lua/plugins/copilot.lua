-- GitHub Copilot inline completion (ghost text), loaded only when Copilot is the
-- selected agent (lua/config/ai_agent.lua). Sign in once with `:Copilot setup`.
--
-- Insert-mode maps:
--   <C-J>  accept the whole suggestion
--   <M-f>  accept the next word only
-- <Tab> is left alone (copilot_no_tab_map), so it keeps its usual behaviour.
--
-- Avante's `copilot` provider (lua/plugins/avante.lua) reuses the token this
-- plugin stores, so `:Copilot setup` also authenticates <leader>ac.
return {
  {
    "github/copilot.vim",
    cond = function()
      return require("config.ai_agent").is_copilot
    end,
    event = "InsertEnter",
    cmd = "Copilot",
    init = function()
      vim.g.copilot_no_tab_map = true
    end,
    config = function()
      vim.keymap.set("i", "<C-J>", 'copilot#Accept("\\<CR>")', {
        expr = true,
        replace_keycodes = false,
        silent = true,
        desc = "Copilot: accept suggestion",
      })
      vim.keymap.set("i", "<M-f>", "<Plug>(copilot-accept-word)", { desc = "Copilot: accept next word" })
    end,
  },
}
