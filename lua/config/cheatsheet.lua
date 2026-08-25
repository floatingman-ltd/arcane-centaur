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

-- Render markdown in a centred float, in-editor. Replaces glow: glow pre-wrapped
-- its output before it ever reached a buffer, and its word-wrap orphans single
-- words onto their own lines at essentially any width. Here the buffer holds the
-- source markdown unwrapped and Neovim wraps at display time, so there is no
-- re-wrap step that can go wrong -- and the content reflows on resize, which
-- pre-rendered output can never do.
--
-- Takes lines rather than a path so it also works for unsaved buffers (see
-- :MarkdownPopup) and needs no temp file.
local function open_float(lines, what)
  -- `#lines == 0` alone would be dead code: nvim_buf_get_lines on an empty buffer
  -- returns { "" }, one empty string, so the count is 1 and the guard never fires.
  -- Check for content, not for entries.
  local has_content = false
  for _, l in ipairs(lines or {}) do
    if l:match("%S") then
      has_content = true
      break
    end
  end
  if not has_content then
    vim.notify("Cheatsheet: nothing to render for " .. (what or "request"), vim.log.levels.WARN)
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"

  -- Geometry matches what glow.nvim used, so the float does not move on screen.
  local width = math.min(math.ceil(vim.o.columns * 0.7), 120)
  local height = math.min(math.ceil(vim.o.lines * 0.7), 80)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.ceil((vim.o.lines - height) / 2 - 1),
    col = math.ceil((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
  })

  vim.wo[win].wrap = true
  vim.wo[win].linebreak = true
  vim.wo[win].breakindent = true
  vim.wo[win].cursorline = false

  -- ORDER MATTERS, do not "tidy" this. render-markdown.nvim does not attach if
  -- the filetype is set before the buffer is displayed in a window -- it silently
  -- renders nothing. Set the filetype *after* nvim_open_win, then ask it to
  -- attach explicitly. Verified in openspec/changes/replace-glow-renderer
  -- (task 1.2): filetype-first gives 0 extmarks, this order gives a full render.
  vim.bo[buf].filetype = "markdown"
  pcall(function()
    require("render-markdown.api").buf_enable()
  end)

  for _, key in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set("n", key, function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end, { buffer = buf, nowait = true, silent = true, desc = "Close cheatsheet float" })
  end

  return win
end

M.open_float = open_float

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
  open_float(vim.fn.readfile(path), "guide '" .. slug .. "'")
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

  -- No temp file: glow needed a path on disk, in-editor rendering does not.
  open_float(vim.split(combined, "\n", { plain = true }), "cheatsheet")
end

return M
