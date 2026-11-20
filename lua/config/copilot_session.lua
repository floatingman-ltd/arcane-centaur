-- lua/config/copilot_session.lua
--
-- A persistent GitHub Copilot CLI session in a native terminal split: the
-- Copilot counterpart of claudecode.nvim's session, set up from init.lua only
-- when Copilot is the selected agent (lua/config/ai_agent.lua).
--
--   <leader>gcc  toggle the session window (the job keeps running when hidden)
--   <leader>gcf  focus the session, opening it if needed
--   <leader>gcb  type "@<path> " for the current file into the session input
--   <leader>gcv  (visual) type the selected lines into the session input
--
-- Nothing is submitted: text lands on the input line so a question can be
-- added before pressing Enter. Multi-line text is sent as a bracketed paste so
-- its newlines do not submit it line by line.
--
-- <leader>gca / <leader>gcr are not mapped: claudecode.nvim's diff accept/reject
-- runs over its own MCP protocol, which the Copilot CLI does not have.
--
-- The maps are bound eagerly here, not lazily, for the reason given in
-- lua/plugins/claudecode.lua: visual `gc` is a native operator, so the
-- <leader>gc prefix must exist before which-key builds its triggers.

local M = {}

local state = { buf = nil, job = nil, ready = false, pending = {} }

-- Text sent while the CLI is still starting is dropped by its TUI, so sends are
-- queued until the terminal has been quiet for QUIET_MS after its first output
-- (startup banner and MCP loading done), or until READY_CAP_MS has passed.
local QUIET_MS = 600
local READY_CAP_MS = 15000

local function flush()
  state.ready = true
  for _, text in ipairs(state.pending) do
    vim.fn.chansend(state.job, text)
  end
  state.pending = {}
end

local function wait_until_ready()
  local started = vim.uv.now()
  local last_out
  local timer = assert(vim.uv.new_timer())
  timer:start(100, 100, function()
    local now = vim.uv.now()
    last_out = state.last_out or last_out
    if (last_out and now - last_out >= QUIET_MS) or now - started >= READY_CAP_MS or not state.job then
      timer:stop()
      timer:close()
      vim.schedule(function()
        if state.job then
          flush()
        end
      end)
    end
  end)
end

local function job_running()
  return state.job ~= nil and vim.fn.jobwait({ state.job }, 0)[1] == -1
end

--- Window currently showing the session buffer, if any.
---@return integer?
local function session_win()
  if not (state.buf and vim.api.nvim_buf_is_valid(state.buf)) then
    return nil
  end
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    if vim.api.nvim_win_get_buf(win) == state.buf then
      return win
    end
  end
  return nil
end

--- Open the session window, starting `copilot` if it is not running.
--- Returns the window, or nil if `copilot` is not installed.
---@return integer?
local function open()
  local win = session_win()
  if win then
    return win
  end

  if not job_running() and vim.fn.executable("copilot") ~= 1 then
    vim.notify(
      "copilot_session: `copilot` not found on $PATH.\n"
        .. "Install GitHub Copilot CLI: npm install -g @github/copilot  (Node 22+ required)",
      vim.log.levels.ERROR
    )
    return nil
  end

  local origin = vim.api.nvim_get_current_win()
  vim.cmd("botright vsplit")
  win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_width(win, math.floor(vim.o.columns * 0.4))

  if job_running() then
    vim.api.nvim_win_set_buf(win, state.buf)
  else
    state.buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(win, state.buf)
    state.ready, state.pending, state.last_out = false, {}, nil
    state.job = vim.fn.jobstart({ "copilot" }, {
      term = true,
      on_stdout = function()
        state.last_out = vim.uv.now()
      end,
      on_exit = function()
        state.job = nil
      end,
    })
    vim.bo[state.buf].bufhidden = "hide"
    wait_until_ready()
  end

  vim.api.nvim_set_current_win(origin)
  return win
end

function M.toggle()
  local win = session_win()
  if win then
    vim.api.nvim_win_close(win, false)
  else
    open()
  end
end

function M.focus()
  local win = open()
  if win then
    vim.api.nvim_set_current_win(win)
    vim.cmd("startinsert")
  end
end

--- Type `text` into the session input without submitting it.
---@param text string
local function send(text)
  if not open() then
    return
  end
  if text:find("\n", 1, true) then
    text = "\27[200~" .. text .. "\27[201~"
  end
  if state.ready then
    vim.fn.chansend(state.job, text)
  else
    table.insert(state.pending, text)
  end
end

function M.add_buffer()
  local path = vim.fn.expand("%:.")
  if path == "" then
    vim.notify("copilot_session: buffer has no file", vim.log.levels.WARN)
    return
  end
  send("@" .. path .. " ")
end

---@param line1 integer
---@param line2 integer
function M.send_lines(line1, line2)
  local lines = vim.api.nvim_buf_get_lines(0, line1 - 1, line2, false)
  local path = vim.fn.expand("%:.")
  local header = path ~= "" and ("%s:%d-%d"):format(path, line1, line2) or "selection"
  send(header .. "\n```" .. vim.bo.filetype .. "\n" .. table.concat(lines, "\n") .. "\n```\n")
end

function M.setup()
  vim.api.nvim_create_user_command("CopilotSession", M.toggle, { desc = "Copilot: toggle CLI session" })
  vim.api.nvim_create_user_command("CopilotSessionSend", function(args)
    M.send_lines(args.line1, args.line2)
  end, { range = true, desc = "Copilot: send lines to the CLI session" })

  local map = vim.keymap.set
  map("n", "<leader>gcc", M.toggle, { desc = "Copilot: toggle session" })
  map("n", "<leader>gcf", M.focus, { desc = "Copilot: focus session" })
  map("n", "<leader>gcb", M.add_buffer, { desc = "Copilot: add buffer to context" })
  map("v", "<leader>gcv", ":CopilotSessionSend<cr>", { silent = true, desc = "Copilot: send selection" })
end

return M
