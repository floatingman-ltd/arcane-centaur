-- General-purpose utility helpers shared across the configuration.

local M = {}

--- Open a floating scratch window and populate it with `lines`.
--
---@param title string   Window title shown in the border.
---@param lines string[] Lines of content to display.
function M.open_float(title, lines)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].filetype   = "markdown"

  local width  = math.floor(vim.o.columns * 0.75)
  local height = math.floor(vim.o.lines * 0.6)
  local row    = math.floor((vim.o.lines - height) / 2)
  local col    = math.floor((vim.o.columns - width) / 2)

  vim.api.nvim_open_win(buf, true, {
    relative  = "editor",
    width     = width,
    height    = height,
    row       = row,
    col       = col,
    style     = "minimal",
    border    = "rounded",
    title     = " " .. title .. " ",
    title_pos = "center",
  })

  local close_opts = { buffer = buf, noremap = true, silent = true }
  vim.keymap.set("n", "q",     "<cmd>close<CR>", close_opts)
  vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", close_opts)
end

--- Open a URL in the system's default browser.
--
-- Tries each of the common browser-opener commands in order and uses the
-- first one that is executable on the current system:
--
--   xdg-open   — standard on most Linux desktops
--   open       — macOS
--   wslview    — WSL (from the wslu package)
--   explorer.exe — WSL fallback when wslu is not installed
--
-- Emits a WARN notification with the URL if none of the openers are found so
-- the user can still copy-paste it into their browser manually.
--
---@param url string  The URL to open.
function M.open_url(url)
  -- In a console environment there is no graphical browser; surface the URL
  -- as an INFO notification so the user can act on it (copy, open manually).
  local term = require("config.terminal")
  if term.is_console then
    vim.notify("open_url: " .. url, vim.log.levels.INFO)
    return
  end

  local openers = { "xdg-open", "open", "wslview", "explorer.exe" }
  for _, cmd in ipairs(openers) do
    if vim.fn.executable(cmd) == 1 then
      vim.fn.jobstart({ cmd, url }, { detach = true })
      return
    end
  end
  vim.notify(
    "open_url: no browser opener found (tried xdg-open, open, wslview, explorer.exe)\n"
      .. "Open manually: " .. url,
    vim.log.levels.WARN
  )
end

return M
