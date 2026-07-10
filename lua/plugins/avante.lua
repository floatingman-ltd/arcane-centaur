-- AI research assistant with Claude (API), ollama (offline), and local Claude backends.
--
-- Keymaps:
--   <leader>aa  open avante with the current provider
--   <leader>ao  switch to ollama provider and open avante
--   <leader>ac  switch to the Claude provider (subscription OAuth) and open avante
--
-- Prerequisites:
--   - claude provider: uses a Claude Pro/Max subscription via OAuth (auth_type = "max"). First
--     use of <leader>ac runs a browser auth flow + a native vim.ui.input code prompt; the token
--     is stored/refreshed under ~/.local/share/nvim/avante/. No ANTHROPIC_API_KEY needed.
--     (ToS note: Anthropic scopes subscription OAuth tokens to Claude Code / claude.ai — using
--     them from third-party tools may violate the ToS. For the API-key path instead, set
--     auth_type = "api" and api_key_name = "ANTHROPIC_API_KEY".)
--   - ollama: optional (default provider). Start with
--     `docker compose -f docker/ollama/docker-compose.yml up -d`, then `ollama pull llama3.2:1b`.
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
          -- Small model for limited-RAM machines (~1.3 GB). Pull with `ollama pull llama3.2:1b`.
          -- Bump to llama3.2:3b (or drop to qwen2.5:0.5b) for a different capability/RAM trade-off
          -- — pull the matching tag first so it matches this value.
          model = "llama3.2:1b",
        },
        claude = {
          endpoint = "https://api.anthropic.com",
          model = "claude-3-5-haiku-20241022",
          -- Claude Pro/Max subscription via OAuth (no API key). See prerequisites above.
          auth_type = "max",
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
