-- AI research assistant via avante.nvim, backed by a local Ollama model, plus a
-- GitHub Copilot provider on machines where Copilot is the selected agent
-- (lua/config/ai_agent.lua).
--
-- Keymaps:
--   <leader>aa  open avante with the current provider (ollama at startup)
--   <leader>ao  (re)select the ollama provider and open avante
--   <leader>ac  (Copilot machines only) select the copilot provider and open avante
--   (submit a prompt inside the avante input with <C-s>; <CR> inserts a newline)
--
-- Prerequisites:
--   - ollama: start with `docker compose -f docker/ollama/docker-compose.yml up -d`,
--     then `ollama pull qwen2.5:0.5b` (the model set below).
--
-- The Claude (Anthropic) provider is intentionally NOT configured. Subscription OAuth tokens
-- are scoped by Anthropic's ToS to Claude Code / claude.ai, so driving them from a third-party
-- tool risks a ToS violation — and we don't want to depend on an ANTHROPIC_API_KEY either.
-- avante is therefore Ollama-only (offline, no external account). To re-enable Claude, add a
-- `claude` provider under `providers` (`auth_type = "api"` + `api_key_name = "ANTHROPIC_API_KEY"`)
-- and a `<leader>ac` mapping that calls `switch_provider("claude")`.
--
-- The copilot provider reuses the OAuth token github/copilot.vim stores after
-- `:Copilot setup` (lua/plugins/copilot.lua). It is not configured on Claude machines,
-- so <leader>ac stays unmapped there.
--
-- Pinned to v0.1.* for stability (prebuilt Linux x86_64 binaries ship from v0.0.29+).
-- dressing.nvim removed — it was archived by its author and unused elsewhere in this config;
-- vim.ui falls back to Neovim's native UI (acceptable on 0.12).

local is_copilot = require("config.ai_agent").is_copilot

local keys = {
  {
    "<leader>aa",
    function()
      require("avante.api").ask()
    end,
    desc = "Avante: open with current provider",
  },
  {
    "<leader>ao",
    function()
      require("avante.api").switch_provider("ollama")
      require("avante.api").ask()
    end,
    desc = "Avante: select ollama and open",
  },
}

local providers = {
  ollama = {
    endpoint = "http://127.0.0.1:11434",
    -- Small model for very limited RAM (~0.4 GB). Pull with `ollama pull qwen2.5:0.5b`.
    -- Bump to llama3.2:1b (~1.3 GB) or llama3.2:3b for more capability — pull the
    -- matching tag first so it matches this value.
    model = "qwen2.5:0.5b",
    -- Small models (0.5–1B) tend to loop / repeat the last paragraph. Nudge Ollama's
    -- repetition penalty above its 1.1 default. Ollama sampling options live under
    -- `options` in the request body; avante forwards them via `extra_request_body`.
    extra_request_body = {
      options = {
        repeat_penalty = 1.3,
      },
    },
  },
}

if is_copilot then
  -- avante's built-in copilot provider; its defaults (endpoint, model) are used as-is.
  providers.copilot = {}
  table.insert(keys, {
    "<leader>ac",
    function()
      require("avante.api").switch_provider("copilot")
      require("avante.api").ask()
    end,
    desc = "Avante: select copilot and open",
  })
end

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
      -- Ollama is the default on every machine (offline, no API key).
      provider = "ollama",
      providers = providers,
    },
    keys = keys,
  },
}
