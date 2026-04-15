-- lua/config/openspec.lua
--
-- In-editor integration for the OpenSpec workflow CLI (`openspec`).
--
-- Commands registered by M.setup():
--   :OpenspecNew [name]    Prompt for a change name (or use the supplied
--                          argument) and run `openspec new change "<name>"`.
--                          Output is shown in a bottom split scratch buffer.
--   :OpenspecStatus [name] Run `openspec status` (or `openspec status
--                          --change "<name>"` when a name is given) and show
--                          the result in a bottom split.
--   :OpenspecList          Run `openspec list` and show all changes in a
--                          bottom split.
--
-- Keymaps (set in lua/keymaps.lua):
--   <leader>osn  — OpenspecNew
--   <leader>oss  — OpenspecStatus
--   <leader>osl  — OpenspecList

local M = {}

--- Open a read-only scratch buffer in a bottom split containing `lines`.
--
---@param title string   Label shown in the first line of the buffer.
---@param lines string[] Output lines to display.
local function open_split(title, lines)
  vim.cmd("botright split")
  vim.cmd("resize 15")

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(buf)

  local content = { "── " .. title .. " ──", "" }
  vim.list_extend(content, lines)

  vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
  vim.bo[buf].modifiable = false
  vim.bo[buf].buftype    = "nofile"
  vim.bo[buf].buflisted  = false

  -- Close with q or <Esc>.
  local close_opts = { buffer = buf, noremap = true, silent = true }
  vim.keymap.set("n", "q",     "<cmd>close<CR>", close_opts)
  vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", close_opts)
end

--- Run an openspec command synchronously and display output in a split.
--
---@param cmd   string[]  Full argv list passed to vim.fn.system().
---@param title string    Label for the split header.
local function run_and_show(cmd, title)
  local output = vim.fn.system(cmd)
  local exit_code = vim.v.shell_error
  -- Strip ANSI escape sequences for clean display.
  output = output:gsub("\27%[[%d;]*m", "")
  local lines = vim.split(output, "\n", { plain = true })
  -- Trim trailing blank lines.
  while #lines > 0 and lines[#lines] == "" do
    table.remove(lines)
  end
  if exit_code ~= 0 then
    vim.notify(
      table.concat(cmd, " ") .. " failed (exit " .. exit_code .. ")",
      vim.log.levels.ERROR
    )
    table.insert(lines, 1, "ERROR: exit code " .. exit_code)
  end
  open_split(title, lines)
end

--- Register :OpenspecNew, :OpenspecStatus, and :OpenspecList commands.
function M.setup()
  -- :OpenspecNew [name]
  vim.api.nvim_create_user_command("OpenspecNew", function(args)
    local name = vim.trim(args.args)
    if name == "" then
      name = vim.fn.input("Change name (kebab-case): ")
      name = vim.trim(name)
    end
    if name == "" then
      vim.notify("OpenspecNew: no change name supplied — aborted.", vim.log.levels.WARN)
      return
    end
    run_and_show({ "openspec", "new", "change", name }, "openspec new change " .. name)
  end, { nargs = "?", desc = "Create a new OpenSpec change" })

  -- :OpenspecStatus [name]
  vim.api.nvim_create_user_command("OpenspecStatus", function(args)
    local name = vim.trim(args.args)
    local cmd, title
    if name ~= "" then
      cmd   = { "openspec", "status", "--change", name }
      title = "openspec status --change " .. name
    else
      cmd   = { "openspec", "status" }
      title = "openspec status"
    end
    run_and_show(cmd, title)
  end, { nargs = "?", desc = "Show OpenSpec change status" })

  -- :OpenspecList
  vim.api.nvim_create_user_command("OpenspecList", function(_)
    run_and_show({ "openspec", "list" }, "openspec list")
  end, { desc = "List all OpenSpec changes" })
end

return M
