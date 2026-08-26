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
  vim.bo[buf].filetype = "markdown"

  local width = math.floor(vim.o.columns * 0.75)
  local height = math.floor(vim.o.lines * 0.6)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " " .. title .. " ",
    title_pos = "center",
  })

  local close_opts = { buffer = buf, noremap = true, silent = true }
  vim.keymap.set("n", "q", "<cmd>close<CR>", close_opts)
  vim.keymap.set("n", "<Esc>", "<cmd>close<CR>", close_opts)
end

--- Open a URL in the system's default browser.
--
-- The URL is always written to the `+` register first, and (outside console
-- mode) echoed to the command line, so it survives in `:messages` even if the
-- opener does nothing. That is not paranoia: see the ordering note below.
--
-- Opener priority is platform-dependent:
--
--   WSL      — wslview, explorer.exe, xdg-open, open
--   other    — xdg-open, open, wslview, explorer.exe
--
-- WSL puts the Windows openers first on purpose. `xdg-open` is present on
-- every Ubuntu install and so always won the old fixed ordering, but with no
-- Linux browser installed it falls through to `w3m` in a detached job with no
-- tty, displays nothing, and still **exits 0** — so falling through on a
-- non-zero exit would not have helped either. `explorer.exe` is always present
-- under WSL and always reaches the browser on the user's actual desktop.
-- `wslview` (from the wslu package) stays ahead of it where installed, being
-- the purpose-built tool, but is not required.
--
-- Emits a WARN notification with the URL if none of the openers are found so
-- the user can still copy-paste it into their browser manually.
--
---@param url string  The URL to open.
function M.open_url(url)
  -- Surface the URL before doing anything else, so it is recoverable whatever
  -- the opener does. `nvim_echo` with history is used rather than `vim.notify`
  -- so the URL persists in `:messages` instead of vanishing with a toast.
  vim.fn.setreg("+", url)

  -- In a console environment there is no graphical browser; surface the URL
  -- as an INFO notification so the user can act on it (copy, open manually).
  -- No echo here — the notification already carries the URL.
  local term = require("config.terminal")
  if term.is_console then
    vim.notify("open_url: " .. url, vim.log.levels.INFO)
    return
  end

  vim.api.nvim_echo({ { "open_url: " .. url .. " (copied to clipboard)" } }, true, {})

  local openers = term.is_wsl and { "wslview", "explorer.exe", "xdg-open", "open" }
    or { "xdg-open", "open", "wslview", "explorer.exe" }
  for _, cmd in ipairs(openers) do
    if vim.fn.executable(cmd) == 1 then
      vim.fn.jobstart({ cmd, url }, { detach = true })
      return
    end
  end
  vim.notify(
    "open_url: no browser opener found (tried " .. table.concat(openers, ", ") .. ")\n" .. "Open manually: " .. url,
    vim.log.levels.WARN
  )
end

return M
