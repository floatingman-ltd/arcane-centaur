local M = {}

local config_dir = vim.fn.stdpath("config")
local sheets_dir = config_dir .. "/cheatsheets"
local guides_dir = config_dir .. "/guides"

-- Filetype → { sheet = "<filename>", guides = { "<slug>", ... } }
local ft_map = {
  lisp = { sheet = "lisp.md", guides = { "sbcl-swank", "clojure-nrepl" } },
  clojure = { sheet = "lisp.md", guides = { "clojure-nrepl" } },
  scheme = { sheet = "lisp.md", guides = {} },
  fennel = { sheet = "lisp.md", guides = {} },
  janet = { sheet = "janet.md", guides = {} },
  fsharp = { sheet = "fsharp.md", guides = { "dotnet-fsi" } },
  cs = { sheet = "fsharp.md", guides = { "dotnet-fsi" } },
  haskell = { sheet = "haskell.md", guides = { "ghci-workflow" } },
  markdown = { sheet = "markdown.md", guides = {} },
}

-- Guide slug → file under guides_dir
local guide_files = {
  ["sbcl-swank"] = "sbcl-swank.md",
  ["clojure-nrepl"] = "clojure-nrepl.md",
  ["dotnet-fsi"] = "dotnet-fsi.md",
  ["ghci-workflow"] = "ghci-workflow.md",
}

local function read_file(path)
  local f = io.open(path, "r")
  if not f then
    return nil
  end
  local content = f:read("*a")
  f:close()
  return content
end

-- Delegate rendering to glow.nvim (cmd-loaded so available from any buffer).
local function glow_open(path)
  local ok, err = pcall(vim.cmd, "Glow " .. vim.fn.fnameescape(path))
  if not ok then
    vim.notify("Cheatsheet: " .. tostring(err), vim.log.levels.WARN)
  end
end

function M.open_guide(slug)
  local filename = guide_files[slug]
  if not filename then
    vim.notify("Cheatsheet: unknown guide '" .. slug .. "'", vim.log.levels.WARN)
    return
  end
  local path = guides_dir .. "/" .. filename
  if vim.fn.filereadable(path) == 0 then
    vim.notify("Cheatsheet: guide not found: " .. path, vim.log.levels.WARN)
    return
  end
  glow_open(path)
end

-- Guide picker for the current filetype (or all guides if no ft match).
function M.pick_guide()
  local ft = vim.bo.filetype
  local entry = ft_map[ft]
  local slugs = (entry and #entry.guides > 0) and vim.list_extend({}, entry.guides) or vim.tbl_keys(guide_files)

  table.sort(slugs)

  if #slugs == 0 then
    vim.notify("No guides available for this filetype", vim.log.levels.INFO)
    return
  end

  vim.ui.select(slugs, { prompt = "Open guide:" }, function(choice)
    if choice then
      M.open_guide(choice)
    end
  end)
end

function M.open_cheatsheet()
  local ft = vim.bo.filetype
  local entry = ft_map[ft]

  local core = read_file(sheets_dir .. "/core.md")
  if not core then
    vim.notify("Cheatsheet: core.md not found at " .. sheets_dir, vim.log.levels.WARN)
    return
  end

  local combined = core
  if entry then
    local lang_path = sheets_dir .. "/" .. entry.sheet
    local lang = read_file(lang_path)
    if lang then
      combined = combined .. "\n\n---\n\n" .. lang
    else
      vim.notify(
        "Cheatsheet: mapped sheet for filetype '" .. ft .. "' is missing or unreadable: " .. lang_path,
        vim.log.levels.WARN
      )
    end
  end

  -- Write to a stable cache path (overwritten each call; no cleanup needed).
  local tmpfile = vim.fn.stdpath("cache") .. "/cheatsheet_preview.md"
  local f = io.open(tmpfile, "w")
  if not f then
    vim.notify("Cheatsheet: could not write cache file", vim.log.levels.WARN)
    return
  end
  f:write(combined)
  f:close()

  glow_open(tmpfile)
end

return M
