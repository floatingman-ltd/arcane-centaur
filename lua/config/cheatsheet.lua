local M = {}

-- Root directory for cheatsheet and guide markdown files.
-- Uses the config directory so paths work regardless of cwd.
local config_dir = vim.fn.stdpath("config")
local sheets_dir = config_dir .. "/cheatsheets"
local guides_dir = config_dir .. "/guides"

-- Filetype → { sheet = "<filename>", guides = { "<slug>", ... } }
-- Multiple filetypes may map to the same sheet file.
local ft_map = {
  lisp    = { sheet = "lisp.md",     guides = { "sbcl-swank", "clojure-nrepl" } },
  clojure = { sheet = "lisp.md",     guides = { "clojure-nrepl" } },
  scheme  = { sheet = "lisp.md",     guides = {} },
  fennel  = { sheet = "lisp.md",     guides = {} },
  janet   = { sheet = "janet.md",    guides = {} },
  fsharp  = { sheet = "fsharp.md",   guides = { "dotnet-fsi" } },
  cs      = { sheet = "fsharp.md",   guides = { "dotnet-fsi" } },
  haskell = { sheet = "haskell.md",  guides = { "ghci-workflow" } },
  markdown = { sheet = "markdown.md", guides = {} },
}

-- Guide slug → { title = "...", file = "<filename>" }
local guide_meta = {
  ["sbcl-swank"]    = { title = "sbcl-swank — Common Lisp Docker REPL",  file = "sbcl-swank.md" },
  ["clojure-nrepl"] = { title = "clojure-nrepl — Clojure nREPL",          file = "clojure-nrepl.md" },
  ["dotnet-fsi"]    = { title = "dotnet-fsi — F# Interactive REPL",       file = "dotnet-fsi.md" },
  ["ghci-workflow"] = { title = "ghci-workflow — GHCi via haskell-tools",  file = "ghci-workflow.md" },
}

local function read_file(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local content = f:read("*a")
  f:close()
  return content
end

local function make_float(lines, title)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"

  local ui = vim.api.nvim_list_uis()[1]
  local width  = math.min(math.floor(ui.width  * 0.80), 90)
  local height = math.min(math.floor(ui.height * 0.80), #lines + 2)
  local row    = math.floor((ui.height - height) / 2)
  local col    = math.floor((ui.width  - width)  / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row      = row,
    col      = col,
    width    = width,
    height   = height,
    style    = "minimal",
    border   = "rounded",
    title    = " " .. title .. " ",
    title_pos = "center",
  })
  vim.wo[win].wrap = true
  vim.wo[win].conceallevel = 2

  -- Dismiss keymaps
  for _, key in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set("n", key, function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end, { buffer = buf, silent = true, nowait = true })
  end

  return buf, win
end

function M.open_guide(slug)
  local meta = guide_meta[slug]
  if not meta then
    vim.notify("Cheatsheet: unknown guide '" .. slug .. "'", vim.log.levels.WARN)
    return
  end
  local path = guides_dir .. "/" .. meta.file
  local content = read_file(path)
  if not content then
    vim.notify("Cheatsheet: guide file not found: " .. path, vim.log.levels.WARN)
    return
  end
  local lines = vim.split(content, "\n", { plain = true })
  make_float(lines, meta.title)
end

function M.open_cheatsheet()
  local ft = vim.bo.filetype
  local entry = ft_map[ft]

  -- Assemble content: core + optional language section
  local core_path = sheets_dir .. "/core.md"
  local core = read_file(core_path)
  if not core then
    vim.notify("Cheatsheet: core.md not found at " .. core_path, vim.log.levels.WARN)
    return
  end

  local combined = core
  local title = "Cheatsheet"

  if entry then
    local lang_path = sheets_dir .. "/" .. entry.sheet
    local lang = read_file(lang_path)
    if lang then
      combined = combined .. "\n\n---\n\n" .. lang
    end
    -- Strip filetype noise from the sheet name for display
    local sheet_label = entry.sheet:gsub("%.md$", "")
    title = "Cheatsheet [" .. sheet_label .. "]"
  end

  local lines = vim.split(combined, "\n", { plain = true })
  local buf = make_float(lines, title)

  -- Wire numbered guide shortcuts if the filetype has guides
  if entry and #entry.guides > 0 then
    for i, slug in ipairs(entry.guides) do
      if i <= 9 then
        vim.keymap.set("n", tostring(i), function()
          -- Close cheatsheet float before opening guide
          local wins = vim.api.nvim_list_wins()
          for _, w in ipairs(wins) do
            if vim.api.nvim_win_get_buf(w) == buf then
              vim.api.nvim_win_close(w, true)
              break
            end
          end
          M.open_guide(slug)
        end, { buffer = buf, silent = true, nowait = true, desc = "Open guide: " .. slug })
      end
    end
  end
end

return M
