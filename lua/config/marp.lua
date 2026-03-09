-- MARP presentation support (Markdown → PPTX / HTML / PDF via Docker)
-- Requires Docker with the marpteam/marp-cli image.
-- See docs/presentations.md for the full guide.

local M = {}

local function uid_gid()
  local uid = vim.fn.system("id -u"):gsub("%s+", "")
  local gid = vim.fn.system("id -g"):gsub("%s+", "")
  return uid, gid
end

--- Convert the current buffer to the given format.
---@param format string  "pptx"|"html"|"pdf"
function M.convert(format)
  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.notify("Marp: buffer has no file", vim.log.levels.WARN)
    return
  end

  local dir  = vim.fn.expand("%:p:h")
  local name = vim.fn.expand("%:t")
  local uid, gid = uid_gid()

  local cmd = {
    "docker", "run", "--rm", "--init",
    "-v", dir .. ":/home/marp/app",
    "-e", "LANG=" .. (os.getenv("LANG") or "C.UTF-8"),
    "-e", "MARP_USER=" .. uid .. ":" .. gid,
    "marpteam/marp-cli",
    "--allow-local-files",
    name,
    "--" .. format,
  }

  vim.notify("Marp: converting to " .. format .. "…", vim.log.levels.INFO)
  vim.fn.jobstart(cmd, {
    on_exit = function(_, code)
      if code == 0 then
        local out = vim.fn.expand("%:p:r") .. "." .. format
        vim.notify("Marp: exported → " .. out, vim.log.levels.INFO)
      else
        vim.notify("Marp: export failed (exit " .. code .. ")", vim.log.levels.ERROR)
      end
    end,
  })
end

--- Open the current file in the MARP preview server running via Docker Compose.
function M.preview()
  local name = vim.fn.expand("%:t")
  if name == "" then
    vim.notify("Marp: buffer has no file", vim.log.levels.WARN)
    return
  end
  local url = "http://localhost:8880/" .. name
  vim.fn.jobstart({ "xdg-open", url }, { detach = true })
end

--- Register MARP user commands.
function M.setup()
  vim.api.nvim_create_user_command("MarpPreview", M.preview,
    { desc = "Open file in MARP preview server" })
  vim.api.nvim_create_user_command("MarpToPptx", function() M.convert("pptx") end,
    { desc = "Convert to PPTX via Docker" })
  vim.api.nvim_create_user_command("MarpToHtml", function() M.convert("html") end,
    { desc = "Convert to HTML via Docker" })
  vim.api.nvim_create_user_command("MarpToPdf", function() M.convert("pdf") end,
    { desc = "Convert to PDF via Docker" })
end

return M
