-- lua/config/copilot_cli.lua
--
-- One-shot GitHub Copilot CLI commands, the Copilot counterpart of claude_cli.
-- Set up from init.lua only when Copilot is the selected agent
-- (lua/config/ai_agent.lua).
--
-- Commands registered by M.setup():
--   :CopilotSuggest   Send the range, visual selection or whole buffer to
--                     `copilot` with a "suggest a shell command" prompt and
--                     show the response in a floating scratch window.
--   :CopilotExplain   Same, with an "explain this code" prompt.
--
-- Keymaps (set in lua/keymaps.lua): <leader>gcs / <leader>gce.
--
-- The CLI runs as `copilot -s --available-tools= -p <prompt>`:
--   -s                  print only the agent's reply
--   --available-tools=  no tools at all, so a one-shot question from the
--                       editor can never edit files or run shell commands
--   -p                  non-interactive prompt mode
-- Flags checked against GitHub Copilot CLI 1.0.54.
--
-- Requires: `copilot` on $PATH (npm install -g @github/copilot, Node 22+),
-- signed in once with `copilot` then `/login`.

local M = {}

---@param subcommand "suggest"|"explain"
---@param input string
local function run_copilot(subcommand, input)
  if vim.fn.executable("copilot") ~= 1 then
    vim.notify(
      "copilot_cli: `copilot` not found on $PATH.\n"
        .. "Install GitHub Copilot CLI: npm install -g @github/copilot  (Node 22+ required)",
      vim.log.levels.ERROR
    )
    return
  end

  local prompt
  if subcommand == "suggest" then
    prompt = "Suggest a shell command for the following context:\n\n" .. input
  else
    prompt = "Explain the following code:\n\n" .. input
  end

  vim.notify("Copilot: running `copilot` CLI …", vim.log.levels.INFO)

  vim.system({ "copilot", "-s", "--available-tools=", "-p", prompt }, { text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        -- The CLI prints some failures (e.g. policy denials) on stdout, not stderr.
        local err = vim.trim(result.stderr or "")
        if err == "" then
          err = vim.trim(result.stdout or "")
        end
        if err == "" then
          err = "(no output)"
        end
        vim.notify("copilot CLI failed (exit " .. result.code .. "):\n" .. err, vim.log.levels.ERROR)
        return
      end

      local lines = vim.split(result.stdout or "", "\n", { plain = true })
      while #lines > 0 and lines[#lines] == "" do
        table.remove(lines)
      end

      require("config.util").open_float("copilot " .. subcommand, lines)
    end)
  end)
end

--- Register :CopilotSuggest and :CopilotExplain.
function M.setup()
  vim.api.nvim_create_user_command("CopilotSuggest", function(args)
    run_copilot("suggest", require("config.util").context_text(args))
  end, { range = true, desc = "Send selection/buffer to `copilot` for a shell command suggestion" })

  vim.api.nvim_create_user_command("CopilotExplain", function(args)
    run_copilot("explain", require("config.util").context_text(args))
  end, { range = true, desc = "Send selection/buffer to `copilot` for a code explanation" })
end

return M
