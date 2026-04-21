-- lua/config/copilot_cli.lua
--
-- In-editor integration for the GitHub Copilot CLI (`copilot`).
--
-- Commands registered by M.setup():
--   :CopilotSuggest   Send the current visual selection (or whole buffer) to
--                     `copilot` with a "suggest a shell command" prompt and
--                     show the response in a floating scratch window.
--   :CopilotExplain   Send the current visual selection (or whole buffer) to
--                     `copilot` with an "explain this code" prompt and show
--                     the explanation in a floating scratch window.
--
-- Keymaps (set in lua/keymaps.lua):
--   <leader>gcs  — CopilotSuggest (normal + visual)
--   <leader>gce  — CopilotExplain (normal + visual)
--
-- Requires:
--   copilot  — GitHub Copilot CLI (npm install -g @github/copilot, Node 22+)

local M = {}

--- Extract text from an explicit command range, the active visual selection,
--- or the whole buffer when neither applies.
--
-- `'<` / `'>` marks persist after leaving Visual mode, so they must not be
-- treated as a real selection unless the command was invoked with a range or
-- we are still currently in Visual mode.
--
---@param args? { range?: integer, line1?: integer, line2?: integer }
---@return string  Multi-line text ready to pass to the CLI.
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
      local end_pos   = vim.fn.getpos("'>")
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

--- Open a floating scratch window and populate it with `lines`.
--
---@param title string   Window title shown in the border.
---@param lines string[] Lines of content to display.
local function open_float(title, lines)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype   = "markdown"

  local width  = math.floor(vim.o.columns * 0.75)
  local height = math.floor(vim.o.lines * 0.6)
  local row    = math.floor((vim.o.lines - height) / 2)
  local col    = math.floor((vim.o.columns - width) / 2)

  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width    = width,
    height   = height,
    row      = row,
    col      = col,
    style    = "minimal",
    border   = "rounded",
    title    = " " .. title .. " ",
    title_pos = "center",
  })

  -- Close with q or <Esc>.
  local close_opts = { buffer = buf, noremap = true, silent = true }
  vim.keymap.set("n", "q",     "<cmd>close<CR>", close_opts)
  vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", close_opts)
end

--- Run the GitHub Copilot CLI non-interactively with `input` piped via stdin.
--- The `-s` flag suppresses usage information so only the AI response is shown.
--- Displays the result in a floating window on success; notifies on error.
--
---@param subcommand string  "suggest" or "explain" (used for the prompt and window title).
---@param input      string  Code or context text to pipe as stdin.
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

  vim.notify("Copilot CLI: running `copilot -sp ...` …", vim.log.levels.INFO)

  vim.system(
    { "copilot", "-sp", prompt },
    {},
    function(result)
      vim.schedule(function()
        if result.code ~= 0 then
          local err = result.stderr or "(no stderr)"
          vim.notify(
            "copilot -sp failed (exit " .. result.code .. "):\n" .. err,
            vim.log.levels.ERROR
          )
          return
        end

        local output = result.stdout or ""
        local lines  = vim.split(output, "\n", { plain = true })
        -- Strip trailing blank lines.
        while #lines > 0 and lines[#lines] == "" do
          table.remove(lines)
        end

        local title = "copilot " .. subcommand
        open_float(title, lines)
      end)
    end
  )
end

--- Register :CopilotSuggest and :CopilotExplain commands.
function M.setup()
  vim.api.nvim_create_user_command("CopilotSuggest", function(args)
    local text = get_context_text(args)
    run_copilot("suggest", text)
  end, { range = true, desc = "Send selection/buffer to `copilot` for a shell command suggestion" })

  vim.api.nvim_create_user_command("CopilotExplain", function(args)
    local text = get_context_text(args)
    run_copilot("explain", text)
  end, { range = true, desc = "Send selection/buffer to `copilot` for a code explanation" })
end

return M
