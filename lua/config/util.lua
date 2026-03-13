-- General-purpose utility helpers shared across the configuration.

local M = {}

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
