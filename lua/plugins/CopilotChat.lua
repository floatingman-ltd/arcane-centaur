return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    lazy = false,
    dependencies = {
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    build = "make tiktoken",
    opts = {
      -- Chat model. Uncomment one line to activate it.
      model = 'claude-opus-4-5',
      -- model = 'claude-sonnet-4-5',
      -- model = 'gpt-4o',
      -- model = 'gpt-4.1',
      temperature = 0.1,
      window = {
        layout = 'vertical',
        height = 0.33;
      },
    },
  },
}
