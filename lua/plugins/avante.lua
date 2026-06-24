-- AI research assistant with Claude (API), ollama (offline), and local Claude backends.
--
-- Keymaps:
--   <leader>aa  open avante with the current provider (Claude API)
--   <leader>ao  switch to ollama provider and open avante
--   <leader>ac  switch to local Claude (via claude CLI) and open avante
--
-- Prerequisites:
--   - ANTHROPIC_API_KEY: set in environment (uses claude.haiku for cost-effectiveness)
--   - ollama: optional, start with `docker compose -f docker/ollama/docker-compose.yml up -d`
--   - claude CLI: npm install -g @anthropic-ai/sdk (for local provider)
--
-- Version pinned to v0.0.27 — the latest release with prebuilt binaries.
-- The build step (make) downloads prebuilt .so files from the GitHub release.
-- Do NOT update beyond v0.0.27 until a newer release publishes Linux binaries,
-- otherwise `make` will fail with "release not found" and avante will not load.

return {
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = "v0.0.27",
    build = "make",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "stevearc/dressing.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {
      -- Default to Ollama (offline, no API key required).
      -- To use Claude API instead: set ANTHROPIC_API_KEY and change provider to "claude"
      provider = "ollama",
      providers = {
        ollama = {
          endpoint = "http://127.0.0.1:11434",
          model = "llama3.1:8b",
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
        desc = "Avante: open with Claude API",
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
