-- Markdown project preview via markserv Docker container.
-- Serves all markdown files in the project directory so that cross-page
-- links resolve correctly in the browser.
--
-- Start the Docker container first (from your project root, or set MD_DIR):
--   docker compose -f ~/.config/nvim/docker/markserv/docker-compose.yml up -d
--
-- The URL path is computed relative to the directory the container mounts at
-- /docs (read with `docker inspect`), so Neovim's cwd does not matter.
--
-- The server runs at http://localhost:8090, and delivers live reload over
-- Server-Sent Events on /__livereload on that same port, so the browser
-- refreshes automatically when you save a file.  Port 35729 is upstream
-- markserv's LiveReload port; this is a local build (docker/markserv/server.js)
-- and never opens it.
--
-- See docs/modules/ROOT/pages/content/markdown.adoc for the full guide.

local M = {}
local util = require("config.util")

local PORT = 8090

--- Return `path` relative to `root`, or nil if `path` is not under `root`.
---@param path string
---@param root string
---@return string?
local function relative_to(path, root)
  if root:sub(-1) ~= "/" then
    root = root .. "/"
  end
  if path:sub(1, #root) == root then
    return path:sub(#root + 1)
  end
  return nil
end

--- Run a command synchronously and return its trimmed stdout, or nil on failure.
---@param cmd string[]
---@return string?
local function run(cmd)
  local ok, res = pcall(function()
    return vim.system(cmd, { text = true }):wait(3000)
  end)
  if not ok or res.code ~= 0 then
    return nil
  end
  local out = vim.trim(res.stdout or "")
  return out ~= "" and out or nil
end

--- Host directory bind-mounted at /docs in the container publishing PORT.
--
-- This is the directory the server treats as `/`, so the URL path must be
-- relative to it. Deriving it from Neovim's cwd instead breaks whenever the
-- two differ, e.g. nvim started in a repo root with MD_DIR set to `docs/`.
---@return string?
local function mount_root()
  if vim.fn.executable("docker") ~= 1 then
    return nil
  end
  local id = run({ "docker", "ps", "-q", "--filter", "publish=" .. PORT })
  if not id then
    return nil
  end
  id = vim.split(id, "\n")[1]
  local src = run({
    "docker",
    "inspect",
    "--format",
    '{{range .Mounts}}{{if eq .Destination "/docs"}}{{.Source}}{{end}}{{end}}',
    id,
  })
  return src and (vim.uv.fs_realpath(src) or src) or nil
end

--- Open the current markdown file in the markserv preview server.
function M.preview()
  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.notify("MdServerPreview: buffer has no file", vim.log.levels.WARN)
    return
  end
  file = vim.uv.fs_realpath(file) or file

  local root = mount_root()
  local rel
  if root then
    rel = relative_to(file, root)
    if not rel then
      vim.notify("MdServerPreview: " .. file .. " is not under the served directory " .. root, vim.log.levels.WARN)
      return
    end
  else
    -- No container found (or no docker CLI): fall back to the cwd-relative path.
    vim.notify(
      "MdServerPreview: no container publishing port " .. PORT .. " found; using path relative to cwd",
      vim.log.levels.WARN
    )
    local cwd = vim.uv.fs_realpath(vim.fn.getcwd()) or vim.fn.getcwd()
    rel = relative_to(file, cwd) or vim.fn.expand("%:t")
  end

  util.open_url("http://localhost:" .. PORT .. "/" .. rel)
end

--- Register the MdServerPreview user command (idempotent — safe to call from ftplugin).
function M.setup()
  if M._loaded then
    return
  end
  M._loaded = true
  vim.api.nvim_create_user_command(
    "MdServerPreview",
    M.preview,
    { desc = "Open markdown file in markserv Docker preview server" }
  )
end

return M
