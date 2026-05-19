local M = {}

-- Root directory for cheatsheet and guide markdown files.
-- Uses the config directory so paths work regardless of cwd.
local config_dir = vim.fn.stdpath("config")
local sheets_dir = config_dir .. "/cheatsheets"
local guides_dir = config_dir .. "/guides"

-- Filetype → { sheet = "<filename>", guides = { "<slug>", ... } }
-- Multiple filetypes may map to the same sheet file.
local ft_map = {
  lisp     = { sheet = "lisp.md",     guides = { "sbcl-swank", "clojure-nrepl" } },
  clojure  = { sheet = "lisp.md",     guides = { "clojure-nrepl" } },
  scheme   = { sheet = "lisp.md",     guides = {} },
  fennel   = { sheet = "lisp.md",     guides = {} },
  janet    = { sheet = "janet.md",    guides = {} },
  fsharp   = { sheet = "fsharp.md",   guides = { "dotnet-fsi" } },
  cs       = { sheet = "fsharp.md",   guides = { "dotnet-fsi" } },
  haskell  = { sheet = "haskell.md",  guides = { "ghci-workflow" } },
  markdown = { sheet = "markdown.md", guides = {} },
}

-- Guide slug → file under guides_dir
local guide_files = {
  ["sbcl-swank"]    = "sbcl-swank.md",
  ["clojure-nrepl"] = "clojure-nrepl.md",
  ["dotnet-fsi"]    = "dotnet-fsi.md",
  ["ghci-workflow"] = "ghci-workflow.md",
}

local function read_file(path)
  local f = io.open(path, "r")
  if not f then return nil end
  local content = f:read("*a")
  f:close()
  return content
end

-- Open a markdown file rendered through glow in a centred floating terminal.
-- If is_temp is true the file is deleted after glow exits.
-- Returns the window handle (or nil on error).
local function open_glow_float(filepath, is_temp, guides)
  if vim.fn.executable("glow") ~= 1 then
    vim.notify("glow not found — install with: sudo apt install glow", vim.log.levels.WARN)
    return nil
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"

  local ui  = vim.api.nvim_list_uis()[1]
  local w   = math.min(math.floor(ui.width  * 0.80), 120)
  local h   = math.min(math.floor(ui.height * 0.85), 80)
  local row = math.floor((ui.height - h) / 2)
  local col = math.floor((ui.width  - w) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative  = "editor",
    row = row, col = col,
    width = w, height = h,
    style  = "minimal",
    border = "rounded",
  })

  vim.fn.termopen("glow --style dark " .. vim.fn.shellescape(filepath), {
    on_exit = function()
      if is_temp then pcall(os.remove, filepath) end
      -- Switch to normal mode and add dismiss + guide keymaps after glow exits.
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(buf) then return end
        vim.cmd("stopinsert")

        local function close()
          if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
          end
        end

        vim.keymap.set("n", "q",     close, { buffer = buf, silent = true, nowait = true })
        vim.keymap.set("n", "<Esc>", close, { buffer = buf, silent = true, nowait = true })

        -- Numbered shortcuts to open mini-guides (1–9)
        if guides and #guides > 0 then
          for i, slug in ipairs(guides) do
            if i <= 9 then
              vim.keymap.set("n", tostring(i), function()
                close()
                M.open_guide(slug)
              end, { buffer = buf, silent = true, nowait = true, desc = "Guide: " .. slug })
            end
          end
        end
      end)
    end,
  })

  vim.cmd("startinsert")
  return win
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
  open_glow_float(path, false, nil)
end

function M.open_cheatsheet()
  local ft    = vim.bo.filetype
  local entry = ft_map[ft]

  -- Assemble content: core + optional language section
  local core_path = sheets_dir .. "/core.md"
  local core = read_file(core_path)
  if not core then
    vim.notify("Cheatsheet: core.md not found at " .. core_path, vim.log.levels.WARN)
    return
  end

  local combined = core

  if entry then
    local lang = read_file(sheets_dir .. "/" .. entry.sheet)
    if lang then
      combined = combined .. "\n\n---\n\n" .. lang
    end
  end

  -- Write to a temp .md file so glow can render it
  local tmpfile = vim.fn.tempname() .. ".md"
  local f = io.open(tmpfile, "w")
  if not f then
    vim.notify("Cheatsheet: could not write temp file", vim.log.levels.WARN)
    return
  end
  f:write(combined)
  f:close()

  open_glow_float(tmpfile, true, entry and entry.guides or nil)
end

return M
