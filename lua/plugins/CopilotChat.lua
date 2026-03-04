return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    lazy = false,
    dependencies = {
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    build = "make tiktoken",
    opts = {
      model = 'Claude Opus 4.5',
      temperature = 0.1,
      window = {
        layout = 'vertical',
        height = 0.33;
      },
    },
  },
}
