-- AI research assistant with ollama (offline) and copilot (online) backends.
--
-- Keymaps:
--   <leader>aa  open avante with the current provider
--   <leader>ao  switch to ollama provider and open avante
--   <leader>ac  switch to copilot provider and open avante
--
-- Prerequisites:
--   - ollama: start with `docker compose -f docker/ollama/docker-compose.yml up -d`
--             then pull a model: `docker compose exec ollama ollama pull llama3.1:8b`
--   - copilot: requires github/copilot.vim to be authenticated (`:Copilot setup`)
--
-- Version pinned to v0.0.27 — the latest release with prebuilt binaries.
-- The build step (make) downloads prebuilt .so files from the GitHub release.
-- Do NOT update beyond v0.0.27 until a newer release publishes Linux binaries,
-- otherwise `make` will fail with "release not found" and avante will not load.
--
-- See docs/guides/cli-console-mode.md for full setup instructions.

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
      -- Offline-first default: use the local ollama Docker service.
      -- Ollama is a first-class provider in avante.nvim; no __inherited_from
      -- or api_key_name is needed. Endpoint must NOT include /v1.
      provider = "ollama",
      providers = {
        ollama = {
          endpoint = "http://127.0.0.1:11434",
          model = "llama3.1:8b",
        },
      },
      -- The copilot provider reuses the credentials held by github/copilot.vim
      -- automatically — no additional token or login is required.
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
          require("avante").switch_provider("ollama")
          require("avante.api").ask()
        end,
        desc = "Avante: switch to ollama and open",
      },
      {
        "<leader>ac",
        function()
          require("avante").switch_provider("copilot")
          require("avante.api").ask()
        end,
        desc = "Avante: switch to copilot and open",
      },
    },
  },
}
