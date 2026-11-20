require("options") -- loads options.lua
require("loader") -- loads the loader/init.lua (lazy)
require("keymaps") -- loads keymaps.lua
require("config.lsp") -- LSP server setup and keymaps

-- One AI agent per machine, chosen by $NVIM_AI_AGENT (see lua/config/ai_agent.lua).
if require("config.ai_agent").is_copilot then
  require("config.copilot_cli").setup()
  require("config.copilot_session").setup()
else
  require("config.claude_cli").setup()
end
require("config.openspec").setup()
require("config.research").setup()
require("config.lazygit").setup()
