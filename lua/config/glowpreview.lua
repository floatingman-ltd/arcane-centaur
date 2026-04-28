-- CLI markdown preview using glow (https://github.com/charmbracelet/glow).
--
-- Renders the current markdown buffer in a terminal split using glow,
-- providing a rich terminal-based preview without requiring a browser
-- or Docker.  Ideal for SSH sessions, TTY consoles, and headless servers.
--
-- Prerequisites:
--   Install glow: https://github.com/charmbracelet/glow#installation
--     snap:  sudo snap install glow
--     brew:  brew install glow
--     go:    go install github.com/charmbracelet/glow@latest
--
-- See docs/guides/markdown.md for the full guide.

local M = {}

--- Open a terminal split showing the current markdown file rendered by glow.
function M.preview()
  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.notify("GlowPreview: buffer has no file", vim.log.levels.WARN)
    return
  end

  if vim.fn.executable("glow") ~= 1 then
    vim.notify(
      "GlowPreview: 'glow' is not installed.\n"
        .. "Install it: https://github.com/charmbracelet/glow#installation",
      vim.log.levels.ERROR
    )
    return
  end

  -- Save before previewing so glow sees the latest content.
  if vim.bo.modified then
    vim.cmd("silent write")
  end

  -- Open a horizontal split and run glow with pager mode.
  vim.cmd("split")
  vim.cmd("terminal glow -p " .. vim.fn.shellescape(file))
  vim.cmd("startinsert")
end

--- Register the GlowPreview user command (idempotent — safe to call from ftplugin).
function M.setup()
  if M._loaded then return end
  M._loaded = true
  vim.api.nvim_create_user_command("GlowPreview", M.preview,
    { desc = "Preview markdown file in terminal using glow" })
end

return M
