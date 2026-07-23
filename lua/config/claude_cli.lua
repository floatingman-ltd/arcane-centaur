-- lua/config/claude_cli.lua
--
-- In-editor integration for Claude API via Anthropic SDK.
--
-- Commands registered by M.setup():
--   :ClaudeSuggest    Send the current visual selection (or whole buffer) to
--                     Claude with a "suggest a shell command" prompt and
--                     show the response in a floating scratch window.
--   :ClaudeExplain    Send the current visual selection (or whole buffer) to
--                     Claude with an "explain this code" prompt and show
--                     the explanation in a floating scratch window.
--
-- Keymaps (set in lua/keymaps.lua):
--   <leader>gcs  — ClaudeSuggest (normal + visual)
--   <leader>gce  — ClaudeExplain (normal + visual)
--
-- Requires:
--   ANTHROPIC_API_KEY  — Anthropic API key (set in environment)

local M = {}

--- Extract text from an explicit command range, the active visual selection,
--- or the whole buffer when neither applies.
--
-- `'<` / `'>` marks persist after leaving Visual mode, so they must not be
-- treated as a real selection unless the command was invoked with a range or
-- we are still currently in Visual mode.
--
---@param args? { range?: integer, line1?: integer, line2?: integer }
---@return string  Multi-line text ready to pass to the Claude API.
local function get_context_text(args)
  local buf = vim.api.nvim_get_current_buf()
  local line_count = vim.api.nvim_buf_line_count(buf)

  local sl, el

  if args and args.range and args.range > 0 then
    sl = args.line1
    el = args.line2
  else
    local mode = vim.fn.mode()
    local is_visual_mode = mode == "v" or mode == "V" or mode == "\22"

    if is_visual_mode then
      local start_pos = vim.fn.getpos("'<")
      local end_pos = vim.fn.getpos("'>")
      sl = start_pos[2]
      el = end_pos[2]
    end
  end

  local has_selection = sl ~= nil
    and el ~= nil
    and sl > 0
    and el > 0
    and sl <= el
    and sl <= line_count
    and el <= line_count

  if has_selection then
    local lines = vim.api.nvim_buf_get_lines(buf, sl - 1, el, false)
    return table.concat(lines, "\n")
  end

  -- Fall back to the whole buffer.
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  return table.concat(lines, "\n")
end

--- Call Claude CLI and display the response in a floating window.
--- Uses Claude Code's built-in authentication (no API key needed).
--- Displays the result on success; notifies on error.
--
---@param subcommand string  "suggest" or "explain" (used for the prompt and window title).
---@param input      string  Code or context text to send to Claude.
local function run_claude(subcommand, input)
  if vim.fn.executable("claude") ~= 1 then
    vim.notify(
      "claude_cli: `claude` CLI not found on $PATH.\n" .. "Install Claude Code: https://claude.com/claude-code",
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

  vim.notify("Claude: running `claude` CLI …", vim.log.levels.INFO)

  vim.system({ "claude", "-p", prompt }, {}, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        local err = result.stderr or "(no stderr)"
        vim.notify("claude CLI failed (exit " .. result.code .. "):\n" .. err, vim.log.levels.ERROR)
        return
      end

      local output = result.stdout or ""
      local lines = vim.split(output, "\n", { plain = true })
      -- Strip trailing blank lines.
      while #lines > 0 and lines[#lines] == "" do
        table.remove(lines)
      end

      local title = "claude " .. subcommand
      require("config.util").open_float(title, lines)
    end)
  end)
end

--- Register :ClaudeSuggest and :ClaudeExplain commands.
function M.setup()
  vim.api.nvim_create_user_command("ClaudeSuggest", function(args)
    local text = get_context_text(args)
    run_claude("suggest", text)
  end, { range = true, desc = "Send selection/buffer to Claude for a shell command suggestion" })

  vim.api.nvim_create_user_command("ClaudeExplain", function(args)
    local text = get_context_text(args)
    run_claude("explain", text)
  end, { range = true, desc = "Send selection/buffer to Claude for a code explanation" })
end

return M
