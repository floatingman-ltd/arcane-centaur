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

--- Build the argv for an opener that takes the URL as a bare argument.
---@param cmd string
---@return fun(url: string): string[]
local function bare_arg(cmd)
  return function(url)
    return { cmd, url }
  end
end

--- Build the argv for PowerShell's `Start-Process`.
--
-- Used under WSL in preference to `explorer.exe`, which refuses to treat a
-- string containing `=` as a URL and silently opens a File Explorer window
-- instead — so a PlantUML URL or any query string lands in the wrong place.
-- `cmd.exe /c start` is worse still: it truncates the URL at the first `&`
-- and opens a *different* page, without reporting anything.
--
-- PowerShell single-quoted strings escape a literal quote by doubling it.
---@param url string
---@return string[]
local function powershell_start(url)
  return {
    "powershell.exe",
    "-NoProfile",
    "-NonInteractive",
    "-Command",
    "Start-Process '" .. url:gsub("'", "''") .. "'",
  }
end

--- Opener candidates in priority order, per platform.
--
-- WSL puts the Windows openers first on purpose. `xdg-open` is present on
-- every Ubuntu install and so always won the old fixed ordering, but with no
-- Linux browser installed it falls through to `w3m` in a detached job with no
-- tty, displays nothing, and still **exits 0** — so falling through on a
-- non-zero exit would not have helped either.
--
-- `explorer.exe` is kept only as a last resort under WSL. It is always present,
-- but mangles any URL containing `=`; `wslview` and PowerShell both handle
-- those correctly.
local OPENERS = {
  wsl = {
    { cmd = "wslview", argv = bare_arg("wslview") },
    { cmd = "powershell.exe", argv = powershell_start },
    { cmd = "explorer.exe", argv = bare_arg("explorer.exe") },
    { cmd = "xdg-open", argv = bare_arg("xdg-open") },
    { cmd = "open", argv = bare_arg("open") },
  },
  other = {
    { cmd = "xdg-open", argv = bare_arg("xdg-open") },
    { cmd = "open", argv = bare_arg("open") },
    { cmd = "wslview", argv = bare_arg("wslview") },
    { cmd = "explorer.exe", argv = bare_arg("explorer.exe") },
  },
}

--- Open a URL in the system's default browser.
--
-- The URL is always written to the `+` register first, and (outside console
-- mode) echoed to the command line, so it survives in `:messages` even if the
-- opener does nothing. That is not paranoia — see the ordering note on
-- `OPENERS` above.
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
  --
  -- WSL is exempt. `is_console` is derived solely from $DISPLAY/$WAYLAND_DISPLAY,
  -- which reads "no X11 display" as "no browser" — false under WSL, where the
  -- Windows openers work whether or not WSLg is exporting a display. Without
  -- this exemption, WSL without WSLg would notify and never open anything.
  local term = require("config.terminal")
  if term.is_console and not term.is_wsl then
    vim.notify("open_url: " .. url, vim.log.levels.INFO)
    return
  end

  vim.api.nvim_echo({ { "open_url: " .. url .. " (copied to clipboard)" } }, true, {})

  local openers = term.is_wsl and OPENERS.wsl or OPENERS.other
  local tried = {}
  for _, opener in ipairs(openers) do
    if vim.fn.executable(opener.cmd) == 1 then
      vim.fn.jobstart(opener.argv(url), { detach = true })
      return
    end
    table.insert(tried, opener.cmd)
  end
  vim.notify(
    "open_url: no browser opener found (tried " .. table.concat(tried, ", ") .. ")\n" .. "Open manually: " .. url,
    vim.log.levels.WARN
  )
end

return M
