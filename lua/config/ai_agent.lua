-- Which AI agent this machine uses: Claude (default) or GitHub Copilot.
--
-- Read once from $NVIM_AI_AGENT at startup. Unset, empty or "claude" selects
-- Claude; "copilot" selects Copilot; anything else warns and falls back to
-- Claude. Matching is case-insensitive. Set it in the shell rc of the machine
-- that should use Copilot:
--
--   export NVIM_AI_AGENT=copilot
--
-- Only the selected agent's plugins, commands and <leader>gc maps are loaded.
-- Changing the agent needs a Neovim restart (and a tmux server restart if
-- Neovim runs inside an older tmux session that never saw the variable).

local M = {}

local LABELS = { claude = "Claude", copilot = "Copilot" }

local raw = vim.env.NVIM_AI_AGENT or ""
local name = raw:lower()
if name == "" then
  name = "claude"
elseif not LABELS[name] then
  vim.schedule(function()
    vim.notify(
      ("NVIM_AI_AGENT=%q is not recognised (expected claude or copilot); using claude"):format(raw),
      vim.log.levels.WARN
    )
  end)
  name = "claude"
end

---@type "claude"|"copilot"
M.name = name
M.is_claude = name == "claude"
M.is_copilot = name == "copilot"
--- Display name, used for the which-key <leader>gc group label.
M.label = LABELS[name]

return M
