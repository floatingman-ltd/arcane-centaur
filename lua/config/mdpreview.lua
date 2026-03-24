-- Markdown project preview via markserv Docker container.
-- Serves all markdown files in the project directory so that cross-page
-- links resolve correctly in the browser.
--
-- Start the Docker container first (from your project root, or set MD_DIR):
--   docker compose -f ~/.config/nvim/docker/markserv/docker-compose.yml up -d
--
-- The server runs at http://localhost:8090.  Live reload on port 35729
-- refreshes the browser automatically when you save a file.
--
-- See docs/guides/markdown.md for the full guide.

local M = {}
local util = require("config.util")

--- Compute the path of the current file relative to cwd.
--- Falls back to just the filename if the file is not under cwd.
local function relative_path()
  local full = vim.fn.expand("%:p")
  local cwd  = vim.fn.getcwd()
  if cwd:sub(-1) ~= "/" then cwd = cwd .. "/" end
  if full:sub(1, #cwd) == cwd then
    return full:sub(#cwd + 1)
  end
  return vim.fn.expand("%:t")
end

--- Open the current markdown file in the markserv preview server.
function M.preview()
  local rel = relative_path()
  if rel == "" then
    vim.notify("MdServerPreview: buffer has no file", vim.log.levels.WARN)
    return
  end
  local url = "http://localhost:8090/" .. rel
  util.open_url(url)
end

--- Register the MdServerPreview user command (idempotent — safe to call from ftplugin).
function M.setup()
  if M._loaded then return end
  M._loaded = true
  vim.api.nvim_create_user_command("MdServerPreview", M.preview,
    { desc = "Open markdown file in markserv Docker preview server" })
end

return M
