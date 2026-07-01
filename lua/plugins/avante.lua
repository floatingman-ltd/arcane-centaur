-- AI research assistant with Claude (API), ollama (offline), and local Claude backends.
--
-- Keymaps:
--   <leader>aa  open avante with the current provider
--   <leader>ao  switch to ollama provider and open avante
--   <leader>ac  switch to Claude API provider and open avante
--
-- Prerequisites:
--   - ANTHROPIC_API_KEY: set in environment (claude provider)
--   - ollama: optional, start with `docker compose -f docker/ollama/docker-compose.yml up -d`
--
-- Pinned to v0.1.* for stability (prebuilt Linux x86_64 binaries ship from v0.0.29+).
-- dressing.nvim removed — it was archived by its author and unused elsewhere in this config;
-- vim.ui falls back to Neovim's native UI (acceptable on 0.12).

return {
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = "v0.1.*",
    build = "make",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      -- Default to Ollama (offline, no API key required).
      provider = "ollama",
      providers = {
        ollama = {
          endpoint = "http://127.0.0.1:11434",
          model = "llama3.2:3b",
        },
        claude = {
          endpoint = "https://api.anthropic.com",
          model = "claude-3-5-haiku-20241022",
          api_key_name = "ANTHROPIC_API_KEY",
        },
      },
    },
    keys = {
      {
        "<leader>aa",
        function() require("avante.api").ask() end,
        desc = "Avante: open with current provider",
      },
      {
        "<leader>ao",
        function()
          require("avante.api").switch_provider("ollama")
          require("avante.api").ask()
        end,
        desc = "Avante: switch to ollama and open",
      },
      {
        "<leader>ac",
        function()
          require("avante.api").switch_provider("claude")
          require("avante.api").ask()
        end,
        desc = "Avante: switch to Claude API and open",
      },
    },
  },
}
