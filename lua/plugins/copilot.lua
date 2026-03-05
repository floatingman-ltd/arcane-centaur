return {
  {
    "github/copilot.vim",
    config = function()
      -- Inline-completion model. Uncomment one line to activate it.
      -- vim.g.copilot_model = "gpt-4o"
      -- vim.g.copilot_model = "gpt-4.1"
      vim.g.copilot_model = "claude-sonnet-4-5"
      -- vim.g.copilot_model = "claude-opus-4-5"
    end,
  },
}
