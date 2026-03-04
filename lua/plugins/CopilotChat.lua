return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    lazy = false,
    dependencies = {
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    build = "make tiktoken",
    opts = {
      -- Change `model` to switch the CopilotChat model,
      -- e.g. "gpt-4o", "gpt-4.1", "claude-opus-4-5", or "claude-sonnet-4-5".
      model = 'claude-opus-4-5',
      temperature = 0.1,
      window = {
        layout = 'vertical',
        height = 0.33;
      },
    },
  },
}
