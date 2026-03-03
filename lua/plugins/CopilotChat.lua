return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    lazy = false,
    dependencies = {
      { "nvim-lua/plenary.nvim", branch = "master" },
    },
    build = "make tiktoken",
    opts = {
      model = 'gpt-4.1',
      temperature = 0.1,
      window = {
        layout = 'horizontal',
        height = 0.25;
      },
    },
  },
}
