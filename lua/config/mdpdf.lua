-- Markdown → PDF with PlantUML and Mermaid diagram rendering (via Docker + Pandoc)
-- Requires: Docker, PlantUML server running on localhost:8080.
--
-- Uses the pandoc/extra Docker image with two bundled Lua filters:
--   plantuml-filter.lua — renders fenced plantuml blocks via the local PlantUML
--                         Docker server (http://localhost:8080)
--   mermaid-filter.lua  — renders fenced mermaid blocks via the Kroki public API
--                         (https://kroki.io) — requires internet access
--
-- See docs/guides/diagrams.md for the full guide.

local M = {}

local function uid_gid()
  local uid = vim.fn.system("id -u"):gsub("%s+", "")
  local gid = vim.fn.system("id -g"):gsub("%s+", "")
  return uid, gid
end

--- Export the current markdown buffer to PDF, rendering PlantUML diagrams.
function M.convert()
  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.notify("MdToPdf: buffer has no file", vim.log.levels.WARN)
    return
  end

  local dir        = vim.fn.expand("%:p:h")
  local name       = vim.fn.expand("%:t")
  local stem       = vim.fn.expand("%:t:r")
  local config_dir = vim.fn.stdpath("config")
  local uid, gid   = uid_gid()

  local cmd = {
    "docker", "run", "--rm", "--init",
    "--network=host",
    "-v", dir .. ":/data",
    "-v", config_dir .. "/docker/md2pdf:/filters:ro",
    "-e", "HOME=/tmp",
    "--user", uid .. ":" .. gid,
    "pandoc/extra",
    name,
    "--lua-filter=/filters/plantuml-filter.lua",
    "--lua-filter=/filters/mermaid-filter.lua",
    "-o", stem .. ".pdf",
  }

  vim.notify("MdToPdf: converting to PDF…", vim.log.levels.INFO)
  vim.fn.jobstart(cmd, {
    on_exit = function(_, code)
      if code == 0 then
        vim.notify("MdToPdf: exported → " .. dir .. "/" .. stem .. ".pdf", vim.log.levels.INFO)
      else
        vim.notify("MdToPdf: export failed (exit " .. code .. ")", vim.log.levels.ERROR)
      end
    end,
  })
end

--- Register the MdToPdf user command (idempotent — safe to call from ftplugin).
function M.setup()
  if M._loaded then return end
  M._loaded = true

  vim.api.nvim_create_user_command("MdToPdf", M.convert,
    { desc = "Export Markdown to PDF, rendering PlantUML and Mermaid diagrams via Docker" })
end

return M
